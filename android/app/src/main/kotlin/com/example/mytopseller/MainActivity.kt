package com.topmortar.topmortarseller

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(LiveChatPlugin::class.java)) {
            flutterEngine.plugins.add(LiveChatPlugin())
        }
    }
}
