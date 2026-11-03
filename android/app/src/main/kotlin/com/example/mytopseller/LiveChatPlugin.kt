package com.topmortar.topmortarseller

import android.app.Activity
import android.app.Application
import android.graphics.Color
import android.os.Bundle
import id.co.haloai.halochat.HaloChatException
import id.co.haloai.halochat.ui.Avatar
import id.co.haloai.halochat.ui.HaloChatActivity
import id.co.haloai.halochat.ui.HaloChatColor
import id.co.haloai.halochat.ui.HaloChatWidget
import id.co.haloai.halochat.ui.HaloChatWidgetConfig
import id.co.haloai.halochat.ui.RoomSubtitle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.CancellableContinuation
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull

/** Native presentation; the authenticated app API and token cache stay in Dart. */
class LiveChatPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    Application.ActivityLifecycleCallbacks {
    private lateinit var application: Application
    private lateinit var channel: MethodChannel
    private lateinit var widget: HaloChatWidget
    private lateinit var scope: CoroutineScope
    private var activity: Activity? = null
    private var userId: String? = null
    private var sessionVersion = 0L
    private val tokenRequests = mutableSetOf<CancellableContinuation<String>>()
    private val chatActivities = mutableSetOf<Activity>()
    private var openingResult: MethodChannel.Result? = null
    private var openingTimeout: Job? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
        application = binding.applicationContext as Application
        widget = HaloChatWidget.setup(
            application,
            HaloChatWidgetConfig().setEnableNotification(false),
            chatColors(),
        )
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        application.registerActivityLifecycleCallbacks(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setUser" -> {
                val nextUser = call.argument<String>("userId")?.trim()
                if (nextUser.isNullOrEmpty()) {
                    result.error("AUTH_REQUIRED", "Silakan masuk kembali.", null)
                    return
                }
                if (userId != nextUser || widget.client == null) {
                    clearSession()
                    userId = nextUser
                    val version = sessionVersion
                    widget.setUser { refresh -> requestToken(nextUser, version, refresh) }
                }
                result.success(null)
            }
            "openChat" -> openChat(result)
            "clearUser" -> {
                clearSession()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun openChat(result: MethodChannel.Result) {
        val host = activity
        when {
            userId == null || widget.client == null ->
                result.error("AUTH_REQUIRED", "Silakan masuk kembali.", null)
            host == null || host.isFinishing || host.isDestroyed ->
                result.error("CHAT_UNAVAILABLE", "Halaman bantuan belum siap.", null)
            openingResult != null ->
                result.error("CHAT_BUSY", "Halaman bantuan sedang dibuka.", null)
            chatActivities.any { it is HaloChatActivity && !it.isFinishing } ->
                result.success(null)
            else -> {
                openingResult = result
                openingTimeout = scope.launch {
                    delay(10_000)
                    finishOpening("CHAT_UNAVAILABLE", "Halaman bantuan tidak dapat dibuka.")
                }
                try {
                    widget.initiateChat()
                        .setRoomTitle("Bantuan Top Mortar")
                        .setRoomSubtitle(RoomSubtitle.EDITABLE, "Tim layanan pelanggan")
                        .setShowSystemMessage(false)
                        .setAvatar(Avatar.ENABLED)
                        .startChat(host)
                } catch (_: Exception) {
                    finishOpening("CHAT_UNAVAILABLE", "Halaman bantuan tidak dapat dibuka.")
                }
            }
        }
    }

    private suspend fun requestToken(
        expectedUser: String,
        expectedVersion: Long,
        forceRefresh: Boolean,
    ): String = withContext(Dispatchers.Main.immediate) {
        if (userId != expectedUser || sessionVersion != expectedVersion) {
            throw HaloChatException.Unauthorized()
        }
        withTimeoutOrNull(30_000) {
            suspendCancellableCoroutine { continuation ->
                tokenRequests.add(continuation)
                continuation.invokeOnCancellation {
                    scope.launch { tokenRequests.remove(continuation) }
                }
                channel.invokeMethod(
                    "getToken",
                    mapOf("forceRefresh" to forceRefresh, "userId" to expectedUser),
                    object : MethodChannel.Result {
                        private fun complete(token: String? = null, error: Exception? = null) {
                            tokenRequests.remove(continuation)
                            if (!continuation.isActive) return
                            when {
                                userId != expectedUser || sessionVersion != expectedVersion ->
                                    continuation.resumeWithException(HaloChatException.Unauthorized())
                                error != null -> continuation.resumeWithException(error)
                                token.isNullOrBlank() ->
                                    continuation.resumeWithException(IOException("Token bantuan tidak tersedia."))
                                else -> continuation.resume(token)
                            }
                        }

                        override fun success(result: Any?) = complete(token = result as? String)

                        override fun error(code: String, message: String?, details: Any?) = complete(
                            error = if (code == "AUTH_REQUIRED") HaloChatException.Unauthorized()
                            else IOException("Tidak dapat menghubungkan layanan bantuan."),
                        )

                        override fun notImplemented() = complete(
                            error = IOException("Layanan bantuan belum siap."),
                        )
                    },
                )
            }
        } ?: throw IOException("Waktu menghubungkan layanan bantuan habis.")
    }

    private fun clearSession() {
        userId = null
        sessionVersion++
        tokenRequests.toList().forEach {
            if (it.isActive) it.resumeWithException(HaloChatException.Unauthorized())
        }
        tokenRequests.clear()
        finishOpening("AUTH_REQUIRED", "Sesi bantuan telah berakhir.")
        chatActivities.toList().forEach { it.finish() }
        chatActivities.clear()

        // UNDISPATCHED clears the SDK's local client before another user can be set.
        // Server revocation is best effort and never delays the app's logout.
        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            withTimeoutOrNull(3_000) { widget.clearUser() }
        }
    }

    private fun finishOpening(code: String? = null, message: String? = null) {
        val result = openingResult
        openingResult = null
        openingTimeout?.cancel()
        openingTimeout = null
        if (code == null) result?.success(null) else result?.error(code, message, null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        clearSession()
        channel.setMethodCallHandler(null)
        application.unregisterActivityLifecycleCallbacks(this)
        scope.cancel()
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (activity is HaloChatActivity || activity.javaClass.name == IMAGE_ACTIVITY) {
            if (userId == null) activity.finish() else chatActivities.add(activity)
        }
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity is HaloChatActivity && activity in chatActivities && !activity.isFinishing) {
            finishOpening()
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
        chatActivities.remove(activity)
    }

    override fun onActivityStarted(activity: Activity) = Unit
    override fun onActivityPaused(activity: Activity) = Unit
    override fun onActivityStopped(activity: Activity) = Unit
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) = Unit

    private fun chatColors(): HaloChatColor {
        val primary = Color.rgb(178, 34, 34)
        val background = Color.rgb(243, 242, 237)
        val text = Color.rgb(32, 33, 36)
        val secondaryText = Color.rgb(104, 104, 104)
        return HaloChatColor()
            .setNavigationColor(primary)
            .setNavigationTitleColor(Color.WHITE)
            .setSendContainerColor(primary)
            .setSendContainerBackgroundColor(Color.WHITE)
            .setFieldChatBorderColor(Color.rgb(218, 220, 224))
            .setSystemEventTextColor(secondaryText)
            .setLeftBubbleColor(Color.WHITE)
            .setLeftBubbleTextColor(text)
            .setRightBubbleColor(Color.rgb(252, 232, 232))
            .setRightBubbleTextColor(text)
            .setTimeLabelTextColor(secondaryText)
            .setTimeBackgroundColor(Color.WHITE)
            .setBaseColor(background)
            .setEmptyTextColor(secondaryText)
            .setEmptyBackgroundColor(background)
    }

    private companion object {
        const val CHANNEL_NAME = "com.topmortar.seller/live_chat"
        const val IMAGE_ACTIVITY = "id.co.haloai.halochat.ui.HaloChatImageActivity"
    }
}
