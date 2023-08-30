package com.koso.rx5.core.command.outgoing

import com.koso.rx5.core.util.Utility


class NaviInfoKawasakiCommand(
    val mode: Int, //0:Under Navigation, 1:Under Routing, 2:Completed, 3:No Navigation
    val seqnum: Int,
    val turndistance: Int,
    val distanceunit: Int, //0:km, 1:m, 2:mile, 3:ft, 4:yd, 5-15:RESERVE
    val turntype: Int,          //int
) : BaseOutgoingKawasakiCommand() {
    val bid = 0x14


    override fun header(): ByteArray {
        val payload = payload()
        return concatenateByteArrays(
            bid.toByteArray(1),
            payload.size.toByteArray(1),
            seqnum.toByteArray(1),
        )
    }

    /**
     * Byte data in the payload is using Big-endian order
     */
    override fun payload(): ByteArray {

        return concatenateByteArrays(
            bid.toByteArray(1),
            seqnum.toByteArray(1),
            byteArrayOf(0x05, 0x70),
            get570(),
            byteArrayOf(0x05, 0x71),
            get571(),
            byteArrayOf(0x05, 0x72),
            get572()
        )
    }

    private fun get570(): ByteArray {
        return concatenateByteArrays(
            byteArrayOf(mode.toByte()),
            ByteArray(7)
        )
    }

    private fun get571(): ByteArray {
        return concatenateByteArrays(
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