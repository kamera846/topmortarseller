package com.topmortar.topmortarseller

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.ApplicationInfo
import id.co.haloai.halochat.HaloChatConfig
import id.co.haloai.halochat.ui.HaloChatWidget
import id.co.haloai.halochat.ui.HaloChatColor
import id.co.haloai.halochat.ui.HaloChatWidgetConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.topmortar.topmortarseller/halochat")
        val widget = HaloChatWidget.setup(applicationContext,
            HaloChatWidgetConfig().setEnableNotification(false),
            HaloChatColor().setNavigationColor(0xFFB22222.toInt())
                .setNavigationTitleColor(0xFFFFFFFF.toInt()))
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openChat" -> {
                    val token = call.argument<String>("token")
                    val generation = call.argument<Number>("generation")?.toInt() ?: -1
                    val demoPort = call.argument<Number>("demoPort")?.toInt()
                    val resetSession = call.argument<Boolean>("resetSession") == true
                    val debug = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
                    if (demoPort != null && (!debug || demoPort !in 1..65535)) {
                        result.error("invalid_config", "Mode demo hanya tersedia pada build debug.", null)
                    } else if ((resetSession || !widget.isLoggedIn()) &&
                        (token == null || !token.startsWith("hct_") ||
                            (demoPort == null && token.startsWith("hct_demo_")))) {
                        result.error("invalid_token", "Token chat tidak valid.", null)
                    } else {
                        if (resetSession || !widget.isLoggedIn()) {
                            var initialToken: String? = token
                            val config = if (demoPort == null) HaloChatConfig() else HaloChatConfig(
                                baseUrl = "http://localhost:$demoPort",
                                realtimeUrl = "ws://localhost:$demoPort/ws/client")
                            widget.setUser(config) { forceRefresh ->
                                val initial = initialToken
                                initialToken = null
                                if (!forceRefresh && initial != null) initial
                                else fetchToken(channel, forceRefresh, generation)
                            }
                        }
                        try {
                            widget.initiateChat().setRoomTitle(if (demoPort == null) "CS Top Mortar" else "CS Top Mortar — Demo")
                                .startChat(this)
                            result.success(null)
                        } catch (_: Exception) {
                            result.error("open_failed", "Chat belum dapat dibuka.", null)
                        }
                    }
                }
                "clearUser" -> widget.clearUser(Runnable { result.success(null) })
                else -> result.notImplemented()
            }
        }
    }

    private suspend fun fetchToken(channel: MethodChannel, forceRefresh: Boolean, generation: Int): String =
        withTimeout(25000) {
            withContext(Dispatchers.Main) {
                suspendCancellableCoroutine { continuation ->
                    channel.invokeMethod("fetchToken", mapOf("forceRefresh" to forceRefresh,
                        "generation" to generation), object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            if (!continuation.isActive) return
                            if (result is String && result.startsWith("hct_")) continuation.resume(result)
                            else continuation.resumeWithException(IllegalStateException("Invalid chat token"))
                        }
                        override fun error(code: String, message: String?, details: Any?) {
                            if (continuation.isActive) continuation.resumeWithException(
                                IllegalStateException("Chat authentication failed"))
                        }
                        override fun notImplemented() = error("unavailable", null, null)
                    })
                }
            }
        }
}
