package com.koso.kosometer.utils

import java.util.*
import kotlin.experimental.and

class StringTools {
    companion object{
        fun Bytes2HexString(b: ByteArray, offset: Int, count: Int): String? {
            if (offset > b.size) {
                return null
            }
            if (offset + count > b.size) {
                return null
            }
            val ret = StringBuilder()
            for (i in 0 until count) {
                var hex = Integer.toHexString(b[offset + i].toInt() and 0xFF)
                if (hex.length == 1) {
                    hex = "0$hex"
                }
                ret.append(hex.uppercase(Locale.getDefault()))
            }
            return ret.toString()
        }

        fun hexStringToByteArray(hexString: String): ByteArray {
            val length = hexString.length
            val byteArray = ByteArray(length / 2)
            for (i in 0 until length step 2) {
                byteArray[i / 2] = hexString.substring(i, i + 2).toInt(16).toByte()
            }
            return byteArray
        }
    }

}