import Flutter
import HaloChat
import UIKit

/// Owns the native chat screen. App authentication and token fetching stay in Dart.
@MainActor
final class LiveChatBridge {
    private struct TokenRequest {
        let continuation: CheckedContinuation<String, Error>
        let timeout: DispatchWorkItem
    }

    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private var widget: HaloChatWidget?
    private var userId: String?
    private var sessionId = UUID()
    private var chatNavigationController: UINavigationController?
    private var tokenRequests: [UUID: TokenRequest] = [:]

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        channel = FlutterMethodChannel(
            name: "com.topmortar.seller/live_chat",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler { [weak self] call, result in
            Task { @MainActor in
                guard let self else {
                    result(FlutterError(code: "CHAT_UNAVAILABLE", message: "Chat belum siap.", details: nil))
                    return
                }
                self.handle(call, result: result)
            }
        }
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setUser":
            guard let arguments = call.arguments as? [String: Any],
                  let userId = arguments["userId"] as? String,
                  !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                result(FlutterError(code: "AUTH_REQUIRED", message: "Silakan masuk kembali.", details: nil))
                return
            }
            setUser(userId)
            result(nil)
        case "openChat":
            openChat(result: result)
        case "clearUser":
            clearUser()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setUser(_ newUserId: String) {
        if userId == newUserId, widget != nil { return }
        clearUser()
        userId = newUserId
        let currentSession = sessionId
        let newWidget = HaloChatWidget(color: makeColors())
        newWidget.setUser(tokenProvider: HaloChatClosureTokenProvider { [weak self] forceRefresh in
            guard let self else { throw HaloChatError.unauthorized }
            return try await self.requestToken(
                userId: newUserId,
                sessionId: currentSession,
                forceRefresh: forceRefresh
            )
        })
        widget = newWidget
    }

    private func openChat(result: @escaping FlutterResult) {
        guard let widget, widget.isLoggedIn() else {
            result(FlutterError(code: "AUTH_REQUIRED", message: "Silakan masuk kembali.", details: nil))
            return
        }
        if let navigation = chatNavigationController,
           navigation.presentingViewController != nil || navigation.isBeingPresented {
            result(nil)
            return
        }
        guard let presenter = registrar.viewController,
              presenter.viewIfLoaded?.window != nil,
              presenter.presentedViewController == nil else {
            result(FlutterError(code: "CHAT_UNAVAILABLE", message: "Tutup layar lain lalu coba lagi.", details: nil))
            return
        }

        let chat = widget.initiateChat()
            .setRoomTitle(title: "Bantuan Top Mortar")
            .setRoomSubTitle(enableSubtitle: .editable, subTitle: "Tim layanan pelanggan")
            .makeViewController()
        let navigation = LiveChatNavigationController(rootViewController: chat)
        navigation.modalPresentationStyle = .fullScreen
        // Keep the app's light palette readable even when the device uses dark mode.
        navigation.overrideUserInterfaceStyle = .light
        chatNavigationController = navigation
        presenter.present(navigation, animated: true) { result(nil) }
    }

    private func clearUser() {
        let previousWidget = widget
        widget = nil
        userId = nil
        sessionId = UUID()
        // Dismiss the whole chat stack, including an open attachment picker.
        chatNavigationController?.presentingViewController?.dismiss(animated: false)
        chatNavigationController = nil

        // Late callbacks from the previous account must never sign in the next account.
        for requestId in Array(tokenRequests.keys) {
            finishTokenRequest(requestId, with: .failure(HaloChatError.unauthorized))
        }

        guard let previousWidget else { return }
        // Revoke the SDK's cached session when possible; logout is immediate locally.
        let cleanup = Task { try? await previousWidget.clearUser() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { cleanup.cancel() }
    }

    private func requestToken(userId: String, sessionId: UUID, forceRefresh: Bool) async throws -> String {
        guard self.userId == userId, self.sessionId == sessionId else {
            throw HaloChatError.unauthorized
        }
        try Task.checkCancellation()
        let requestId = UUID()

        return try await withCheckedThrowingContinuation { continuation in
            let timeout = DispatchWorkItem { [weak self] in
                self?.finishTokenRequest(requestId, with: .failure(URLError(.timedOut)))
            }
            tokenRequests[requestId] = TokenRequest(continuation: continuation, timeout: timeout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 35, execute: timeout)

            channel.invokeMethod("getToken", arguments: [
                "userId": userId,
                "forceRefresh": forceRefresh,
            ]) { [weak self] response in
                Task { @MainActor in
                    guard let self else { return }
                    guard self.userId == userId, self.sessionId == sessionId else {
                        self.finishTokenRequest(requestId, with: .failure(HaloChatError.unauthorized))
                        return
                    }
                    if let error = response as? FlutterError {
                        let nativeError: Error = error.code == "AUTH_REQUIRED"
                            ? HaloChatError.unauthorized
                            : NSError(
                                domain: "LiveChatToken",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: error.message ?? "Chat belum dapat terhubung."]
                            )
                        self.finishTokenRequest(requestId, with: .failure(nativeError))
                    } else if let token = response as? String, !token.isEmpty {
                        self.finishTokenRequest(requestId, with: .success(token))
                    } else {
                        self.finishTokenRequest(requestId, with: .failure(HaloChatError.invalidResponse))
                    }
                }
            }
        }
    }

    private func finishTokenRequest(_ requestId: UUID, with result: Result<String, Error>) {
        guard let request = tokenRequests.removeValue(forKey: requestId) else { return }
        request.timeout.cancel()
        request.continuation.resume(with: result)
    }

    private func makeColors() -> HaloChatColor {
        let primary = color(0xB22222)
        let background = color(0xF3F2ED)
        let text = color(0x202124)
        let secondaryText = color(0x686868)
        return HaloChatColor()
            .setNavigationColor(primary)
            .setNavigationTitleColor(.white)
            .setSendContainerColor(primary)
            .setSendContainerBackgroundColor(.white)
            .setFieldChatBorderColor(color(0xDDDDDD))
            .setSystemEventTextColor(secondaryText)
            .setLeftBubbleColor(.white)
            // The SDK shares timestamps and read-tick colors between both sides.
            .setRightBubbleColor(color(0xFCE8E8))
            .setLeftBubbleTextColor(text)
            .setRightBubbleTextColor(text)
            .setTimeLabelTextColor(secondaryText)
            .setTimeBackgroundColor(.white)
            .setBaseColor(background)
            .setEmptyTextColor(secondaryText)
            .setEmptyBackgroundColor(background)
    }

    private func color(_ hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

private final class LiveChatNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
