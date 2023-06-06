package com.koso.kosometer.ble

import android.annotation.SuppressLint
import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import com.koso.kosometer.ble.NotificationItem
import com.koso.kosometer.service.BlePeripheralService
import com.koso.kosometer.utils.ByteTools
import com.koso.kosometer.utils.StringTools
import java.lang.Math.min
import java.nio.ByteBuffer
import java.util.*

val ANCS_SERVICE_UUID = UUID.fromString("7905f431-b5ce-4e99-a40f-4b1e122d00d0")
val ANCS_NOTIFICATION_SOURCE_UUID = UUID.fromString("9fbf120d-6301-42d9-8c58-25e699a21dbd")
val ANCS_CONTROL_POINT_UUID = UUID.fromString("69d1d8f3-45e1-49a8-9821-9bbdfdaad9d9")
val ANCS_DATA_SOURCE_UUID = UUID.fromString("22eac6e9-24d6-4bb5-be44-b36ace7c7bfb")
val DESCRIPTOR_CONFIG = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

@SuppressLint("MissingPermission")
class AncsPeripheral(val context: Context) : BasePeripheral {

    private val ADVERTISING_TIMEOUT = 0
    private lateinit var service: BluetoothGattService
    private lateinit var notificationCharacteristic: BluetoothGattCharacteristic
    private lateinit var descriptor: BluetoothGattDescriptor
    private lateinit var controlPointCharacteristic: BluetoothGattCharacteristic
    private lateinit var dataSourceCharacteristic: BluetoothGattCharacteristic
    private var ancsServer: BluetoothGattServer? = null
    private var bluetoothDevice: BluetoothDevice? = null
    private var notifications = HashMap<Int, NotificationItem>()

    private val ancsCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
//                    ancsServer?.connect(device, false)
                    bluetoothDevice = device

                    //todo: for testing data
//                    Timer().schedule(object : TimerTask() {
//                        override fun run() {
//                            if (ancsServer != null && bluetoothDevice != null && notificationCharacteristic != null) {
//                                val noti = NotificationItem(0, ANCS_CATEGORY_SOCIAL_EVENT, "測試訊息標題", "測試副標題", "測試內容測試內容測試內容測試內容")
//                                noti.notify(
//                                    ancsServer!!,
//                                    bluetoothDevice!!,
//                                    notificationCharacteristic,
//                                )
//                                notifications.put(noti.notifyUid, noti)
//                            }
//
//                        }
//                    }, 1000, 10000)
                    if (device?.getBondState() != BluetoothDevice.BOND_BONDED) {
                        device?.createBond();
                    }
                }
                BluetoothProfile.STATE_DISCONNECTED -> {
                    bluetoothDevice = null

                }

            }

        }


        override fun onServiceAdded(status: Int, service: BluetoothGattService?) {
            super.onServiceAdded(status, service)
        }


        override fun onMtuChanged(device: BluetoothDevice?, mtu: Int) {
            super.onMtuChanged(device, mtu)
        }


        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice?,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {

            super.onCharacteristicWriteRequest(
                device,
                requestId,
                characteristic,
                preparedWrite,
                responseNeeded,
                offset,
                value
            )
            if (ancsServer == null) {
                return
            }

            if (characteristic?.uuid.toString() == ANCS_CONTROL_POINT_UUID.toString()) {
                if (value == null) return
                val notiUid =
                    ByteBuffer.wrap(byteArrayOf(value[1], value[2], value[3], value[4])).int

                val attributes = HashMap<Int, Int>()
                var index = 5
                while (index < value.size) {
                    val id = value[index].toInt()
                    when (id) {
                        1, 2, 3 -> {
                            attributes[id] = ByteTools.littleEndianConversion(
                                byteArrayOf(
                                    value[index + 1],
                                    value[index + 2]
                                )
                            )
                            index += 3
                        }
                        else -> {
                            attributes[id] = 0
                            index += 1
                        }
                    }
                }

                val noti = notifications[notiUid]
                if (noti != null) {
                    noti.moreInfo(
                        ancsServer!!,
                        bluetoothDevice!!,
                        dataSourceCharacteristic,
                        attributes
                    )
                }


            }

            if (responseNeeded) {
                ancsServer!!.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, value)
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic?
        ) {
            super.onCharacteristicReadRequest(device, requestId, offset, characteristic)
            if (ancsServer == null) {
                return
            }

            ancsServer!!.sendResponse(
                device,
                requestId,
                BluetoothGatt.GATT_SUCCESS,
                offset,
                characteristic?.value
            )
        }

        override fun onDescriptorReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            descriptor: BluetoothGattDescriptor?
        ) {
            super.onDescriptorReadRequest(device, requestId, offset, descriptor)
            if (ancsServer == null) {
                return
            }

            ancsServer!!.sendResponse(
                device,
                requestId,
                BluetoothGatt.GATT_SUCCESS,
                offset,
                descriptor?.value
            )
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice?,
            requestId: Int,
            descriptor: BluetoothGattDescriptor?,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            super.onDescriptorWriteRequest(
                device,
                requestId,
                descriptor,
                preparedWrite,
                responseNeeded,
                offset,
                value
            )
            ancsServer!!.sendResponse(
                device,
                requestId,
                BluetoothGatt.GATT_SUCCESS,
                offset,
                value
            )

        }


    }


    private val advertisingCallback = object : AdvertiseCallback() {
        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
            BlePeripheralService.end(context)
        }

        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            super.onStartSuccess(settingsInEffect)
        }

    }

    init {
        initAncs()
    }


    override fun startPeripheral() {
        val bluetoothManager: BluetoothManager =
            context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        ancsServer = bluetoothManager.openGattServer(context, ancsCallback)
        ancsServer?.addService(service)

//        advertise(bluetoothManager)
    }

    private fun advertise(mgr: BluetoothManager) {
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_POWER)
            .setConnectable(true)
            .setTimeout(ADVERTISING_TIMEOUT)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(ANCS_SERVICE_UUID))
            .build()
        mgr.adapter.bluetoothLeAdvertiser.startAdvertising(settings, data, advertisingCallback)
    }

    var timestamp: Long = 0
    val postQueue: Queue<NotificationItem> = LinkedList<NotificationItem>()
    fun postAncsNotification(
        eventId: Int,
        categoryId: Int,
        title: String,
        subTitle: String = "",
        message: String = ""
    ) {
        val notifyItem = NotificationItem(
            eventId,
            categoryId,
            title.substring(0, min(10, title.length)),
            subTitle.substring(0, min(30, subTitle.length)),
            message.substring(0, min(30, message.length))
        )

        notifications[notifyItem.notifyUid] = notifyItem
        if (postQueue.size == 0 && !isBusy()) {
            if (ancsServer != null && bluetoothDevice != null) {
                notifyItem.notify(
                    ancsServer!!,
                    bluetoothDevice!!,
                    notificationCharacteristic,
                )
                timestamp = System.currentTimeMillis()
            }
        } else {
            postQueue.add(notifyItem)

            Thread {
                while (postQueue.size > 0) {
                    Thread.sleep(10000)

                    if (!isBusy() && ancsServer != null && bluetoothDevice != null) {

                        try {
                            val n = postQueue.remove()
                            n.notify(
                                ancsServer!!,
                                bluetoothDevice!!,
                                notificationCharacteristic,
                            )
                            timestamp = System.currentTimeMillis()
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }

                    } else {
                        postQueue.clear()
                    }
                }

            }.start()

        }

    }

    private fun isBusy(): Boolean {
        val time = System.currentTimeMillis()
        return time - timestamp < 10000
    }

    override fun endPeripheral() {
        notifications.clear()
        ancsServer?.close()
        ancsServer = null
    }

    private fun initAncs() {
        // 創建一個 GATT Service
        service = BluetoothGattService(
            ANCS_SERVICE_UUID,
            BluetoothGattService.SERVICE_TYPE_PRIMARY
        )

        // 創建一個 Notification Source Characteristic
        notificationCharacteristic = BluetoothGattCharacteristic(
            ANCS_NOTIFICATION_SOURCE_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattCharacteristic.PERMISSION_READ
        )

        // 添加描述符
        val descriptor = BluetoothGattDescriptor(
            DESCRIPTOR_CONFIG,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )

        notificationCharacteristic.addDescriptor(descriptor)
        service.addCharacteristic(notificationCharacteristic)

        // 創建一個 Control Point Characteristic
        controlPointCharacteristic = BluetoothGattCharacteristic(
            ANCS_CONTROL_POINT_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
            BluetoothGattCharacteristic.PERMISSION_WRITE
        )

        controlPointCharacteristic.addDescriptor(
            BluetoothGattDescriptor(
                DESCRIPTOR_CONFIG,
                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
            )
        )
        service.addCharacteristic(controlPointCharacteristic)

        // 創建一個 Data Source Characteristic
        dataSourceCharacteristic = BluetoothGattCharacteristic(
            ANCS_DATA_SOURCE_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )
        dataSourceCharacteristic.addDescriptor(
            BluetoothGattDescriptor(
                DESCRIPTOR_CONFIG,
                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
            )
        )
        service.addCharacteristic(dataSourceCharacteristic)
    }

    companion object {
        val ANCS_CATEGORY_INCOMING_CALL = 1
        val ANCS_CATEGORY_MISSING_CALL = 2
        val ANCS_CATEGORY_SOCIAL_EVENT = 4
        val ANCS_CATEGORY_EMAIL_EVENT = 6

        val ANCS_EVENT_ADDED = 0
        val ANCS_EVENT_REMOVED = 2

    }
}