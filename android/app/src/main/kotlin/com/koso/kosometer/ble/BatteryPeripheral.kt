package com.koso.kosometer.ble

import android.annotation.SuppressLint
import android.bluetooth.*
import android.content.Context
import android.util.Log
import com.koso.kosometer.ble.BasePeripheral
import java.nio.charset.Charset
import java.util.*

@SuppressLint("MissingPermission")
class BatteryPeripheral(val context: Context) : BasePeripheral {


    val BATTERY_SERVICE_UUID = UUID.fromString("0000180F-0000-1000-8000-00805f9b34fb")
    val BATTERY_LEVEL_CHAR_UUID = UUID.fromString("00002A19-0000-1000-8000-00805f9b34fb")
    val BATTERY_DESCRIPTOR = UUID.fromString("00002904-0000-1000-8000-00805f9b34fb")

    var bluetoothDevice: BluetoothDevice? = null
    var gattServer: BluetoothGattServer? = null

    private lateinit var batteryService: BluetoothGattService
    private lateinit var batteryLevelCharacteristic: BluetoothGattCharacteristic

    val gattCallback = object: BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice?, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            if (status == BluetoothGatt.GATT_SUCCESS) {
                if (newState == BluetoothGatt.STATE_CONNECTED) {
                    bluetoothDevice = device
                    updateConnectedDevicesStatus()

                } else if (newState == BluetoothGatt.STATE_DISCONNECTED) {
                    updateConnectedDevicesStatus()
                }

//                Timer().schedule(object : TimerTask(){
//                    override fun run() {
//                        sendBatteryLevel(15)
//                    }
//
//                }, 2000, 30000)
            } else {
                bluetoothDevice = null
                updateConnectedDevicesStatus()
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice?,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic?
        ) {
            super.onCharacteristicReadRequest(device, requestId, offset, characteristic)
            gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, characteristic?.value )
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
            gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, value )
        }
    }

    init {
        initGatt()
    }

    private fun initGatt() {
        batteryLevelCharacteristic = BluetoothGattCharacteristic(
            BATTERY_LEVEL_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
        )

        batteryLevelCharacteristic.addDescriptor(
            BluetoothGattDescriptor(
                BATTERY_DESCRIPTOR,
                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
            ).apply {
                setValue(byteArrayOf(0, 0))
            }
        )

//        batteryLevelCharacteristic.addDescriptor(
//            BluetoothGattDescriptor(
//                UUID.fromString("00002901-0000-1000-8000-00805f9b34fb"),
//                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
//            ).apply {
//                setValue("The current charge level of a battery. 100% represents fully charged while 0% represents fully discharged.".toByteArray(
//                    Charset.forName("UTF-8")))
//            }
//        )

        batteryService = BluetoothGattService(
            BATTERY_SERVICE_UUID,
            BluetoothGattService.SERVICE_TYPE_PRIMARY
        )
        batteryService.addCharacteristic(batteryLevelCharacteristic)
    }

    override fun startPeripheral() {
        val bluetoothManager: BluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        gattServer = bluetoothManager.openGattServer(context, gattCallback)
        gattServer?.addService(batteryService)
    }

    var timestamp: Long = 0
    fun postBatteryLevel(level: Int){
        val time = System.currentTimeMillis()
        if(time - timestamp < 30000) return
        if(gattServer != null && bluetoothDevice != null) {
            val descriptor = batteryLevelCharacteristic.getDescriptor(BATTERY_DESCRIPTOR)
            descriptor.value = byteArrayOf((level and 0xFF).toByte())
            batteryLevelCharacteristic.addDescriptor(descriptor)
            batteryLevelCharacteristic.setValue(level, BluetoothGattCharacteristic.FORMAT_UINT8, 0)
//            batteryLevelCharacteristic.setValue(
//                level,
//                BluetoothGattCharacteristic.FORMAT_UINT8,  /* offset */0
//            )
            val indicate = ((batteryLevelCharacteristic.properties
                    and BluetoothGattCharacteristic.PROPERTY_INDICATE)
                    == BluetoothGattCharacteristic.PROPERTY_INDICATE)
            gattServer?.notifyCharacteristicChanged(
                bluetoothDevice,
                batteryLevelCharacteristic,
                indicate
            )
            timestamp = time
        }
    }

    fun updateConnectedDevicesStatus(){

    }

    override fun endPeripheral() {
        gattServer?.close()
        gattServer = null
    }
}