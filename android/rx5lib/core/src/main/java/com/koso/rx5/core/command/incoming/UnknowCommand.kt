package com.koso.rx5.core.command.incoming

import android.util.Log
import com.koso.rx5.core.util.Utility
import java.lang.Exception
import java.nio.ByteBuffer

class UnknowCommand: BaseIncomingCommand() {


    var raw: ByteArray = byteArrayOf()
    var hexString: String = ""

    fun parseData(bytes: ByteArray){
        raw = bytes
        hexString = toString()
    }

    override fun parseData(rawData: MutableList<Byte>) {
        raw = rawData.toByteArray()
        hexString = toString()
    }

    override fun createInstance(): UnknowCommand {
        return UnknowCommand()
    }

    override fun toString(): String {
        return Utility.bytesToHex(raw)
    }

}