package com.koso.kosometer

import com.koso.kosometer.channel.Talkie
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    override fun onStart() {
        super.onStart()
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Talkie.ofEngine(this, flutterEngine)
    }

    override fun onDestroy() {
        super.onDestroy()
        Talkie._instance?.onDestory()
    }

}
