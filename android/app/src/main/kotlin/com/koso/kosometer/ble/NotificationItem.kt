package com.koso.kosometer.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattServer
import android.util.Log
import com.koso.kosometer.ble.DESCRIPTOR_CONFIG
import com.koso.kosometer.extension.toByteArray
import com.koso.kosometer.utils.ByteTools
import com.koso.kosometer.utils.StringTools

var globalUid = 1
fun getNewNotificationUid(): Int{
    globalUid += 1
    if(globalUid > Int.MAX_VALUE){
        globalUid = 0
    }
    return globalUid
}
@SuppressLint("MissingPermission")
class NotificationItem(val eventId: Int, val categoryId: Int, val title: String, val subTitle: String = "", val message: String = "") {
    val notifyUid: Int = getNewNotificationUid()

    fun notify(gattServer: BluetoothGattServer, device: BluetoothDevice, notifychar: BluetoothGattCharacteristic){
        var payload = byteArrayOf()

        payload += eventId.toByte() //event id
        payload += 0.toByte() //event flags
        payload += categoryId.toByte() //category id
        payload += 1.toByte() //category count
        payload += notifyUid.toByteArray(4)

        notifychar.value = payload
        val desp = notifychar.getDescriptor(DESCRIPTOR_CONFIG)
        desp.value = payload
        notifychar.addDescriptor(desp)
        gattServer.notifyCharacteristicChanged(device, notifychar, false)

    }

    fun moreInfo(gattServer: BluetoothGattServer, device: BluetoothDevice, datachar: BluetoothGattCharacteristic, attributes: Map<Int, Int>){

        var payload = byteArrayOf()
        payload += 0.toByte() //command id
        payload += notifyUid.toByteArray(4)

        if(attributes.containsKey(0)){
            // todo
        }

        if(attributes.containsKey(1)) {
            //title
            val bytes = title.toByteArray(Charsets.UTF_8)
            payload += 1.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes
        }

        if(attributes.containsKey(2)) {
            //sub title
            val bytes = subTitle.toByteArray(Charsets.UTF_8)
            payload += 2.toByte() //NotificationAttributeIDTitle = 1
            payload += bytes.size.toByteArray(2) //length
            payload += bytes
        }

        if(attributes.containsKey(3)) {
            // message
            val bytes = message.toByteArray(Charsets.UTF_8)
            payload += 3.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes
        }

        if(attributes.containsKey(4)) {
            // message size
            val bytes = message.length.toByteArray(1)
            payload += 4.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes.size.toByteArray(1)
        }

        if(attributes.containsKey(5)){
            // date
            val bytes = "20230101".toByteArray(Charsets.UTF_8)
            payload += 5.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes
        }

        if(attributes.containsKey(6)){
            // positive action
            val bytes = "OK".toByteArray(Charsets.UTF_8)
            payload += 6.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes
        }

        if(attributes.containsKey(7)){
            // negtive action
            val bytes = "CANCEL".toByteArray(Charsets.UTF_8)
            payload += 7.toByte() //NotificationAttributeIDTitle = 1
            payload += ByteTools.littleEndian(bytes.size.toByteArray(2)) //length
            payload += bytes
        }

        datachar.value = payload
        gattServer.notifyCharacteristicChanged(device, datachar, false)
    }


}