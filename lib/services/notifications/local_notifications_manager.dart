import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationsManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late InitializationSettings initializationSettings;

  LocalNotificationsManager._init() {
    tz.initializeTimeZones();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid) {
      requestAndroidPermission();
    }
    initializePlatform();
  }

  void requestAndroidPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  void initializePlatform() {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('app_notification_icon');
    initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendNotification(LocalNotification notification) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'instant_notifications',
      'instant_notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'TICKER',
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      notificationDetails,
      payload: notification.payload,
    );
  }

  Future<void> scheduleNotification(
      LocalNotification notification, DateTime dateTime) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'scheduled_notifications',
      'scheduled_notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'TICKER',
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      tz.TZDateTime.from(dateTime, tz.local),
      notificationDetails,
      payload: notification.payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

LocalNotificationsManager localNotificationsManager =
    LocalNotificationsManager._init();

class LocalNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  LocalNotification(this.id, this.title, this.body, this.payload);
}
