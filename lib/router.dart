import 'package:dat_chat/features/auth/screens/login_screen.dart';
import 'package:dat_chat/features/auth/screens/otp_screen.dart';
import 'package:dat_chat/features/auth/screens/user_information_screen.dart';
import 'package:dat_chat/features/select_contacts/screens/select_contact_screen.dart';
import 'package:dat_chat/screens/error_screen.dart';
import 'package:dat_chat/features/chat/mobile_chat_screen.dart';
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
    case SelectContactScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => SelectContactScreen(),
      );
    case MobileChatScreen.routeName:
      final args = setting.arguments as Map<String, dynamic>;
      String name = args['name'];
      String uid = args['uid'];
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
        ),
      );
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorScreen(error: "This page does't exist"),
              ));
  }
}
