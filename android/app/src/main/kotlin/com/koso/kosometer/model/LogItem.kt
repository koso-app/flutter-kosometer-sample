package com.koso.kosometer.model

class LogItem(
    val title: String = "",
    val content: String = "",
    val hex: String = "",
    var timestamp: Long = System.currentTimeMillis(),
    val direction: Int = 0, // send: 1, received: 2, no define: 0
)