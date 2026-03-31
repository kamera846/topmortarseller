# =========================================
# Flutter 기본 (WAJIB)
# =========================================
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# =========================================
# Kotlin & Coroutines
# =========================================
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# =========================================
# HTTP (package http)
# =========================================
-dontwarn org.apache.http.**
-dontwarn okhttp3.**

# =========================================
# Shared Preferences
# =========================================
-keep class android.content.SharedPreferences { *; }

# =========================================
# WebView (webview_flutter)
# =========================================
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

# =========================================
# URL Launcher / Intent
# =========================================
-keep class androidx.browser.customtabs.** { *; }
-keep class android.content.Intent { *; }

# =========================================
# Google Fonts
# =========================================
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# =========================================
# Flutter Local Notifications
# =========================================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }

# =========================================
# Permission Handler
# =========================================
-keep class com.baseflow.permissionhandler.** { *; }

# =========================================
# Device Info Plus
# =========================================
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# =========================================
# Share Plus
# =========================================
-keep class dev.fluttercommunity.plus.share.** { *; }

# =========================================
# Path Provider
# =========================================
-keep class io.flutter.plugins.pathprovider.** { *; }

# =========================================
# Image Gallery Saver
# =========================================
-keep class com.example.imagegallerysaver.** { *; }

# =========================================
# QR Code Scanner
# =========================================
-keep class com.journeyapps.barcodescanner.** { *; }
-keep class com.google.zxing.** { *; }

# =========================================
# Upgrader (App update checker)
# =========================================
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# =========================================
# JSON / Serialization safety (general)
# =========================================
-keepattributes *Annotation*
-keepattributes Signature

# =========================================
# Prevent stripping model classes (optional, jika pakai parsing JSON manual)
# =========================================
# -keep class com.topmortar.topmortarseller.model.** { *; }

# =========================================
# Suppress warnings umum
# =========================================
-dontwarn javax.annotation.**
-dontwarn sun.misc.**

# =========================================
# Debugging (optional - hapus saat production final)
# =========================================
# -keepattributes SourceFile,LineNumberTable