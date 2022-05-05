import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/common/notification_local_manager.dart';

import 'app.dart';
// Uncomment lines 7 and 10 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: firebaseOptionOptions);
  NotificationLocalManager.instance.init();
  // debugPaintSizeEnabled = true;
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'EN'),
        Locale('vi', 'VI'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi', 'VI'),
      assetLoader: YamlAssetLoader(),
      child: const App(),
    ),
  );
}

FirebaseOptions get firebaseOptionOptions {
  if (Platform.isIOS) {
    // iOS and MacOS
    return const FirebaseOptions(
      appId: '',
      apiKey: '',
      projectId: '',
      messagingSenderId: '',
    );
  } else {
    // Android
    return const FirebaseOptions(
      appId: '1:879865302345:android:733d6bc89b8bea59205e98',
      apiKey: 'AIzaSyAxoeyi7LGho7fEvnYmSP6Sj2A4I74XL7s',
      projectId: 'newapp-c9f67',
      messagingSenderId: '879865302345',
    );
  }
}
