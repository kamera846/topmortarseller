import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/services/live_chat_api.dart';
import 'package:topmortarseller/util/enum.dart';

/// Owns the short-lived chat session. Tokens stay in memory and are cleared on logout.
class LiveChatService {
  LiveChatService({
    LiveChatApi? api,
    MethodChannel? channel,
    Future<ContactModel?> Function()? readContact,
    bool Function()? platformSupported,
    DateTime Function()? now,
  }) : _api = api ?? LiveChatApi(),
       _channel =
           channel ?? const MethodChannel('com.topmortar.seller/live_chat'),
       _readContact = readContact ?? _signedInContact,
       _platformSupported = platformSupported ?? _isMobile,
       _now = now ?? DateTime.now;

  static final instance = LiveChatService();
  final LiveChatApi _api;
  final MethodChannel _channel;
  final Future<ContactModel?> Function() _readContact;
  final bool Function() _platformSupported;
  final DateTime Function() _now;

  String? _userId;
  ContactModel? _contact;
  LiveChatSession? _session;
  String? _lastProvidedToken;
  Future<LiveChatSession>? _tokenRequest;
  Future<void>? _clearing;
  int _generation = 0;
  bool _opening = false;
  bool _initialized = false;

  bool get isSupported => _platformSupported();

  static bool _isMobile() =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<ContactModel?> _signedInContact() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(GlobalEnum.isLoggedIn.toString()) != true) {
      return null;
    }
    return getContactModel();
  }

  void initialize() {
    if (_initialized || !isSupported) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method != 'getToken') throw MissingPluginException();
    final arguments = call.arguments;
    if (arguments is! Map ||
        arguments['userId'] != _userId ||
        _userId == null) {
      throw PlatformException(code: 'AUTH_REQUIRED');
    }
    try {
      final userId = _userId!;
      final generation = _generation;
      if ((await _readContact())?.idContact != userId) throw _loginRequired;
      _checkSession(generation, userId);
      // Reopening may have prefetched a newer token while the native SDK still
      // holds the previous one. Let it use that fresh token before minting again.
      final cached = _session;
      final hasUnusedToken =
          cached != null &&
          cached.token != _lastProvidedToken &&
          cached.canReuse(_now());
      final session = await _getToken(
        forceRefresh: arguments['forceRefresh'] == true && !hasUnusedToken,
      );
      _checkSession(generation, userId);
      _lastProvidedToken = session.token;
      return session.token;
    } on LiveChatException catch (error) {
      throw PlatformException(
        code: error.requiresLogin ? 'AUTH_REQUIRED' : 'TOKEN_UNAVAILABLE',
        message: error.message,
      );
    } catch (_) {
      throw PlatformException(
        code: 'TOKEN_UNAVAILABLE',
        message: 'Chat belum dapat terhubung. Silakan coba lagi.',
      );
    }
  }

  /// The native screen takes over after connecting. Cancellation stops presentation.
  Future<void> openChat({bool Function()? isActive}) async {
    if (!isSupported) {
      throw const LiveChatException(
        'Chat tersedia di aplikasi Android dan iOS.',
      );
    }
    if (_opening) {
      throw const LiveChatException(
        'Chat masih disiapkan. Silakan coba lagi sebentar.',
      );
    }
    _opening = true;
    try {
      initialize();
      final generationBeforeLogin = _generation;
      await _clearing;
      final contact = await _readContact();
      final userId = contact?.idContact;
      if (userId == null || userId.trim().isEmpty) throw _loginRequired;
      if (_generation != generationBeforeLogin) throw _loginRequired;
      if (isActive?.call() == false) return;
      if (_userId != null && _userId != userId) {
        final generationAfterClear = _generation + 1;
        await clearUser();
        if (_generation != generationAfterClear) throw _loginRequired;
      }
      _userId = userId;
      _contact = contact;
      final generation = _generation;
      await _getToken();
      _checkSession(generation, userId);
      if (isActive?.call() == false) return;
      await _channel
          .invokeMethod<void>('setUser', {'userId': userId})
          .timeout(const Duration(seconds: 10));
      _checkSession(generation, userId);
      if (isActive?.call() == false) return;
      await _channel
          .invokeMethod<void>('openChat')
          .timeout(const Duration(seconds: 10));
    } on MissingPluginException {
      throw const LiveChatException(
        'Chat belum tersedia pada versi aplikasi ini. Silakan perbarui aplikasi.',
      );
    } on PlatformException catch (error) {
      if (error.code == 'AUTH_REQUIRED') throw _loginRequired;
      throw const LiveChatException(
        'Chat belum dapat dibuka. Silakan coba lagi.',
      );
    } on TimeoutException {
      throw const LiveChatException(
        'Chat terlalu lama merespons. Silakan coba lagi.',
      );
    } finally {
      _opening = false;
    }
  }

  Future<LiveChatSession> _getToken({bool forceRefresh = false}) async {
    final userId = _userId;
    if (userId == null) throw _loginRequired;
    final generation = _generation;
    final cached = _session;
    if (!forceRefresh && cached != null && cached.canReuse(_now())) {
      return cached;
    }
    if (forceRefresh) _session = null;
    // Concurrent native callbacks share one request; a failed request can be retried.
    final request = _tokenRequest ??= _api.getToken(contact: _contact!);
    try {
      final session = await request;
      _checkSession(generation, userId);
      _session = session;
      return session;
    } finally {
      if (identical(_tokenRequest, request)) _tokenRequest = null;
    }
  }

  void _checkSession(int generation, String userId) {
    if (_generation != generation || _userId != userId) throw _loginRequired;
  }

  static const _loginRequired = LiveChatException(
    'Sesi Anda berakhir. Silakan masuk kembali untuk menggunakan chat.',
    requiresLogin: true,
  );

  Future<void> clearUser() {
    // Invalidate pending requests before waiting for any platform/network operation.
    _generation++;
    _userId = null;
    _contact = null;
    _session = null;
    _lastProvidedToken = null;
    _tokenRequest = null;
    return _clearing ??= _clearNativeUser().whenComplete(
      () => _clearing = null,
    );
  }

  Future<void> _clearNativeUser() async {
    if (!isSupported) return;
    try {
      await _channel
          .invokeMethod<void>('clearUser')
          .timeout(const Duration(seconds: 3));
    } on MissingPluginException {
      // A platform without the bridge still needs to finish the application's logout.
    } on PlatformException {
      // Native clears local state first; remote revocation is best effort offline.
    } on TimeoutException {
      // Signing out of the seller app must not depend on the chat network.
    }
  }
}
