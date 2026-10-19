import UIKit
import Flutter
import HaloChat

/// -- flutter local notifications setup
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let chatWidget = HaloChatWidget(
    color: HaloChatColor()
      .setNavigationColor(UIColor(red: 178/255, green: 34/255, blue: 34/255, alpha: 1))
      .setNavigationTitleColor(.white))
  private var chatChannel: FlutterMethodChannel?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    /// -- flutter local notifications setup
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in 
      GeneratedPluginRegistrant.register(with: registry)
    }
    /// -- 

    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "HaloChatBridge") {
      let channel = FlutterMethodChannel(
        name: "com.topmortar.topmortarseller/halochat", binaryMessenger: registrar.messenger())
      chatChannel = channel
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          result(FlutterError(code: "unavailable", message: "Chat belum dapat dibuka.", details: nil))
          return
        }
        switch call.method {
        case "openChat":
          guard let controller = registrar.viewController else {
            result(FlutterError(code: "unavailable", message: "Chat belum dapat dibuka.", details: nil))
            return
          }
          guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "invalid_token", message: "Token chat tidak valid.", details: nil))
            return
          }
          let token = arguments["token"] as? String
          let demoPort = arguments["demoPort"] as? Int
          let resetSession = arguments["resetSession"] as? Bool == true
          var configuration = HaloChatConfiguration()
          if let port = demoPort {
            #if DEBUG
            guard (1...65535).contains(port) else {
              result(FlutterError(code: "invalid_config", message: "Port demo tidak valid.", details: nil))
              return
            }
            configuration = HaloChatConfiguration(
              baseURL: URL(string: "http://localhost:\(port)")!,
              realtimeURL: URL(string: "ws://localhost:\(port)/ws/client")!)
            #else
            result(FlutterError(code: "invalid_config", message: "Mode demo hanya tersedia pada build debug.", details: nil))
            return
            #endif
          }
          guard controller.presentedViewController == nil else {
            result(FlutterError(code: "busy", message: "Tutup layar saat ini terlebih dahulu.", details: nil))
            return
          }
          if resetSession || !self.chatWidget.isLoggedIn() {
            guard let token = token, token.hasPrefix("hct_"),
                  demoPort != nil || !token.hasPrefix("hct_demo_") else {
              result(FlutterError(code: "invalid_token", message: "Token chat tidak valid.", details: nil))
              return
            }
            let provider = FlutterChatTokenProvider(channel: channel, initialToken: token,
              generation: arguments["generation"] as? Int ?? -1)
            self.chatWidget.setUser(tokenProvider: provider, configuration: configuration)
          }
          self.chatWidget.initiateChat().setRoomTitle(title: demoPort == nil ? "CS Top Mortar" : "CS Top Mortar — Demo").startChat { chat in
            let navigation = UINavigationController(rootViewController: chat)
            navigation.modalPresentationStyle = .fullScreen
            controller.present(navigation, animated: true)
            result(nil)
          }
        case "clearUser":
          Task {
            try? await self.chatWidget.clearUser()
            await MainActor.run { result(nil) }
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

  }
}

// Kept in this compiled source so the storyboard scene needs no extra build-file entry.
@objc class SceneDelegate: FlutterSceneDelegate {}

private actor FlutterChatTokenProvider: HaloChatTokenProvider {
  private let channel: FlutterMethodChannel
  private var initialToken: String?
  private let generation: Int

  init(channel: FlutterMethodChannel, initialToken: String, generation: Int) {
    self.channel = channel
    self.initialToken = initialToken
    self.generation = generation
  }

  func token(forceRefresh: Bool) async throws -> String {
    if !forceRefresh, let token = initialToken {
      initialToken = nil
      return token
    }
    initialToken = nil
    return try await withCheckedThrowingContinuation { continuation in
      DispatchQueue.main.async {
        self.channel.invokeMethod("fetchToken", arguments: [
          "forceRefresh": forceRefresh, "generation": self.generation
        ]) { value in
          if let token = value as? String, token.hasPrefix("hct_") {
            continuation.resume(returning: token)
          } else {
            continuation.resume(throwing: HaloChatError.unauthorized)
          }
        }
      }
    }
  }
}
