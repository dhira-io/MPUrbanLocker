import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
      const AndroidInitializationSettings androidInitializationSetting =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Use your app icon

    const DarwinInitializationSettings iosInitializationSetting =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,   // 🔥 REQUIRED
          defaultPresentBadge: true,   // 🔥 REQUIRED
          defaultPresentSound: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitializationSetting,
      iOS: iosInitializationSetting,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final filePath = response.payload;
        if (filePath != null && filePath.isNotEmpty) {
          OpenFilex.open(filePath);
        }
      },
    );

      if (Platform.isIOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
        >()
            ?.requestPermissions(alert: true, badge: true, sound: true);

      } else if (Platform.isAndroid) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
        >();

        await android?.requestNotificationsPermission();
      }
  }

  // static Future<void> requestNotificationPermission() async {
  //   final android = _plugin
  //       .resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin>();
  //
  //   await android?.requestNotificationsPermission();
  // }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String filePath,
  }) async {
    print("show noti");
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'download_channel', // Channel ID is required for Android 8.0+
          'Downloads',
          channelDescription: 'Download notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails( presentAlert: true,   // 🔥 REQUIRED
          presentBadge: true,
          presentSound: true,);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/
          1000, // Unique ID for the notification
      title,
      body,
      notificationDetails,
      payload: filePath,
    );
  }
}
