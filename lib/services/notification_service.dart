import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:topmortarseller/main.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Future<void>? _initializing;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initialize() {
    if (_isInitialized) return Future.value();
    return _initializing ??= _initialize().whenComplete(
      () => _initializing = null,
    );
  }

  Future<void> _initialize() async {
    // android init settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@drawable/notification_icon',
    );

    // ios init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // init settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // initialize plugin
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) =>
          notificationResponse(response),
    );
    _isInitialized = true;
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // NOTIFICATION DETAILS
  NotificationDetails details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'apps_point_channel_id',
        'Notifikasi Poin',
        channelDescription: 'Saluran Notifikasi Poin Aplikasi',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // SHOW NOTIFICATION
  Future<void> show({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await initialize();
    return notificationsPlugin.show(
      id,
      title,
      body,
      details(),
      payload: payload,
    );
  }

  // ONCLICK NOTIFICATION
  void notificationResponse(NotificationResponse response) {
    final payload = response.payload;

    if (payload != null) {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/',
        (route) => false,
        arguments: payload,
      );
    }
  }
}
