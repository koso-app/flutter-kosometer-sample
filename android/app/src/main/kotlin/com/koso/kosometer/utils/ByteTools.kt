package com.koso.kosometer.utils

class ByteTools {
    companion object{
        fun littleEndianConversion(bytes: ByteArray): Int {
            var result = 0
            for (i in bytes.indices) {
                result = result or (bytes[i].toInt() shl 8 * i)
            }
            return result
        }

        fun littleEndian(value: ByteArray): ByteArray{
            val length: Int = value.size
            val res = ByteArray(length)
            for (i in 0 until length) {
                res[length - i - 1] = value.get(i)
            }
            return res
        }
    }
}