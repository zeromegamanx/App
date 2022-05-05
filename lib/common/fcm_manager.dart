import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
}

///firebase cloud messaging
class FCMManager {
  final PublishSubject<RemoteMessage> onMessage = PublishSubject();

  init() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp::: $message");
      onMessage.add(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    ///
    await token;
  }

  Future<String?> get token async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("FCM Token::: $token");
      return token;
    } catch (ex) {
      print("get Token::: ${ex.toString()}");
    }
    return null;
  }

  subscribeTopic(String topic) {
    try {
      FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      print("subscribeTopic Error::: ${e.toString()}");
    }
  }

  unSubscribeTopic(String topic) {
    try {
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      print("subscribeTopic Error::: ${e.toString()}");
    }
  }
}
