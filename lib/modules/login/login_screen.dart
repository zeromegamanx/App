import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modules/login_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../common/fcm_manager.dart';
import '../../common/notification_local_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => LoginManager(),
      child: const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ///Dầu tiên e phải nhìn desgin trên figma để xây dựng bố cục
  late FCMManager _fcmManager;
  bool _passwordVisible = false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    _fcmManager = FCMManager();
    _passwordVisible = false;
    super.initState();
    _fcmManager.init();
    _fcmManager.onMessage.listen((message) {
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      if (title != null && body != null) {
        NotificationLocalManager.instance
            .showNotification(title: title, message: body);
      }
    });

    print("FCM Token::: ${FCMManager().token}");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xff3C4457),

      ///Dung SafeArea để nó không đè ảnh lên thanh status bar
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: height / 3,
              child: _buildHeader(context),
            ),
            SizedBox(
              child: _buildLogin(context),
            ),
            Expanded(
              child: _buildFooter(context),
            ),
          ],
        ),
      ),
    );
  }

  ///Em hien thi anh background phan nay len
  _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 40,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/theme.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xff343842).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/avatar.png"),
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  _buildLogin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.fromLTRB(width / 18.75, 0, width / 18.75, 0),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              "login.title".tr(),
              style: const TextStyle(
                fontSize: 24,
                fontStyle: FontStyle.normal,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xff252933),
            ),
            child: TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(
                  Iconsax.user_tick,
                  color: Colors.white,
                ),
                hintText: "email",
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: const Color(0xff252933),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                border: InputBorder.none,
                icon: const Icon(
                  Iconsax.lock,
                  color: Colors.white,
                ),
                hintText: "login.password".tr(),
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Iconsax.eye_slash : Iconsax.eye,
                    color: const Color(0xffFFFFFF),
                  ),
                  onPressed: () {
                    setState(
                      () {
                        _passwordVisible = !_passwordVisible;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: width / 7.8,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      context
                          .read<LoginManager>()
                          .doLogin(context, email, password);
                    },
                    child: Text(
                      "login.button1".tr(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: SizedBox(
                  height: width / 7.8,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: const Icon(Iconsax.finger_scan),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            "login.ForgotPassword".tr(),
            style: const TextStyle(color: Colors.blue),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(width / 10, 10, width / 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "login.DontHaveAccount".tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "login.Sign-in".tr(),
                  style: const TextStyle(color: Colors.blue),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildFooter(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
        margin: EdgeInsets.fromLTRB(width / 20, 10, width / 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Container(
                  height: height / 10,
                  width: width / 8,
                  decoration: const BoxDecoration(
                    color: Color(0xff343842),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/images/group.png",
                    color: AdaptiveTheme.of(context).theme.canvasColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    "login.line1".tr(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  height: height / 10,
                  width: width / 8,
                  decoration: const BoxDecoration(
                    color: Color(0xff343842),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "assets/images/phone_in_talk.png",
                    color: Colors.white,
                  ),
                ),
                Text(
                  "login.line2".tr(),
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            InkWell(
              onTap: () {
                if (context.locale.languageCode == 'en') {
                  context.setLocale(const Locale('vi', 'VI'));
                  // nếu ngôn ngữ hiện tại có mã là tiếng anh thì chuyển sang tiếng việt và ngược lại
                } else {
                  context.setLocale(const Locale('en', 'EN'));
                }
              },
              child: Column(
                children: [
                  Container(
                    height: height / 10,
                    width: width / 8,
                    decoration: const BoxDecoration(
                      color: Color(0xff343842),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      "assets/images/language.png",
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "login.line3".tr(),
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                var isLight = AdaptiveTheme.of(context).mode.isLight;
                if (isLight) {
                  AdaptiveTheme.of(context)
                      .setThemeMode(AdaptiveThemeMode.dark);
                } else {
                  AdaptiveTheme.of(context)
                      .setThemeMode(AdaptiveThemeMode.light);
                }
              },
              child: Column(
                children: [
                  Container(
                    height: height / 10,
                    width: width / 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.people3,
                    ),
                  ),
                  const Text(
                    "Smart OTP",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

//for textbox
}
