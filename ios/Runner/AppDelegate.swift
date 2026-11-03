import UIKit
import Flutter

/// -- flutter local notifications setup
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var liveChatBridge: LiveChatBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    /// -- flutter local notifications setup
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in 
      GeneratedPluginRegistrant.register(with: registry)
    }
    /// -- 

    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "TopMortarLiveChat") {
      liveChatBridge = LiveChatBridge(registrar: registrar)
    }

    /// -- flutter local notifications setup
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    /// -- 
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
