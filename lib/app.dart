import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'main_menu.dart';
import 'modules/login/login_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        accentColor: Colors.amber,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Colors.amber,
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        initialRoute: '/',
        theme: theme,
        darkTheme: darkTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        /// Route duoc chay dau tien, co nghia man login duoc khoi tao chay dau tien
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => LoginScreen.create(),

          /// Dau '/' duoc khai bao la route cua man hinh login
          // When navigating to the "/second" route, build the SecondScreen widget.
          '/main-menu': (context) => const MainMenu(),
        },
      ),
    );
  }
}
