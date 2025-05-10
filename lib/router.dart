import 'package:dat_chat/features/auth/screens/login_screen.dart';
import 'package:dat_chat/features/auth/screens/otp_screen.dart';
import 'package:dat_chat/features/auth/screens/user_information_screen.dart';
import 'package:dat_chat/screens/error_screen.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings setting) {
  switch (setting.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case OtpScreen.routeName:
      final verificationId = setting.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OtpScreen(
          verificationid: verificationId,
        ),
      );
    case UserInfomationScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => UserInfomationScreen(),
      );
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorScreen(error: "This page does't exist"),
              ));
  }
}
