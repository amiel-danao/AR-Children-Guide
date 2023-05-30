import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationAPI {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings("@mipmap/ic_launcher");
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  static Future showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return _notifications.show(id, title, body, await _notificationDetails(),
        payload: payload);
  }

  static Future _notificationDetails() async {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
          "armobile_location_track", "Armobile is tracking your location",
          importance: Importance.max),
    );
  }
}
