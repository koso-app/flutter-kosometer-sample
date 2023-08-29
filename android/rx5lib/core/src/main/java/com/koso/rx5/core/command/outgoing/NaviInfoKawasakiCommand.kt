package com.koso.rx5.core.command.outgoing

import com.koso.rx5.core.util.Utility


class NaviInfoKawasakiCommand(
    val seq: Int, //Sequence number from 0 to 255
    val turndistance: Int,
    val distanceunit: Int,//int          nextdist;  //下條轉彎道路距離 單位 : 公尺   an.nextdist = 200;
    val turntype: Int,          //int          nextturn; //下條轉彎方向i=nextturn%100,道路型態bbb=(int)(nextturn/100) an.nextdist = 0;(直行),an.nextdist = 100;(橋梁)
) : BaseOutgoingKawasakiCommand() {
    val bid = 0x14

    override fun header(): ByteArray {
        val payload = payload()
        return concatenateByteArrays(
            bid.toByteArray(1),
            payload.size.toByteArray(1),
            seq.toByteArray(1),
        )
    }

    override fun payload(): ByteArray {
        return concatenateByteArrays(
            bid.toByteArray(1),
            seq.toByteArray(1),
            byteArrayOf(0x05, 0x70).reversedArray(),
            get570(),
            byteArrayOf(0x05, 0x71).reversedArray(),
            get571(),
            byteArrayOf(0x05, 0x72).reversedArray(),
            get572()
        )
    }

    private fun get570(): ByteArray {
        return concatenateByteArrays(
            byteArrayOf(0x00), // under navigation
            ByteArray(7)
        )
    }

    private fun get571(): ByteArray {
        return concatenateByteArrays(
            byteArrayOf(0x05, 0x71).reversedArray(),
            turntype.toByteArray(1),
            distanceunit.toByteArray(1),
            turndistance.toByteArray(3),
            ByteArray(3)
        )
    }

    private fun get572(): ByteArray {
        return ByteArray(8)
    }

}