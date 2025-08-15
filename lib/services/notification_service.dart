import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // INITIALIZE
  Future<void> initialize() async {
    if (_isInitialized) return;

    // android init settings
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/fav_android_launcher_round',
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
    notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await notificationsPlugin.initialize(initSettings);
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
  Future<void> show({int id = 0, String? title, String? body}) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }
}
