package com.koso.kosometer.extension

import java.nio.ByteBuffer

fun Int.toByteArray(size: Int):ByteArray{
    val buffer = ByteBuffer.allocate(size)
    if(size == 4) {
        buffer.putInt(this)
    }
    if(size == 2) {
        buffer.putShort(this.toShort())
    }
    return buffer.array()
}
