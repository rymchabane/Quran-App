import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'quran_audio';
  static const _notifId = 888;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // Créer le canal
    const channel = AndroidNotificationChannel(
      _channelId,
      'Quran Audio',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await androidPlugin?.createNotificationChannel(channel);
  }

  static Future<void> show({
    required String surahName,
    required String reciterName,
  }) async {
    await _plugin.show(
      _notifId,
      surahName,
      reciterName,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Quran Audio',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          ongoing: false,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> cancel() async {
    await _plugin.cancel(_notifId);
  }
}