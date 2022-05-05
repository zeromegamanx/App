import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final PublishSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    PublishSubject<ReceivedNotification>();
final PublishSubject<String> selectNotificationSubject =
    PublishSubject<String>();

class NotificationLocalManager {
  NotificationLocalManager._internal();
  static final NotificationLocalManager _instance =
      NotificationLocalManager._internal();
  static NotificationLocalManager get instance {
    return _instance;
  }

  bool _isInit = false;
  PublishSubject selectNotificationEvent = PublishSubject<String>();
  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;
    _requestPermissions();
    _configureSelectNotificationSubject();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification:
                (int? id, String? title, String? body, String? payload) async {
              didReceiveLocalNotificationSubject.add(ReceivedNotification(
                  id: id!, title: title!, body: body!, payload: payload!));
            });
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
        selectNotificationEvent.add(payload);
      }
      selectNotificationSubject.add(payload ?? '');
    });
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showNotification(
      {required String title, required String message, String? payload}) async {
    print("run show notification");
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        iOS: iOSPlatformChannelSpecifics,
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        UniqueKey().hashCode, title, message, platformChannelSpecifics,
        payload: payload);
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) {
      //if (selectNotificationEvent != null) selectNotificationEvent(payload);
    });
  }

  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}
