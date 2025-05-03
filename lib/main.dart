import 'package:dat_chat/futures/landing/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:dat_chat/colors.dart';
import 'package:dat_chat/screens/mobile_layout_screen.dart';
import 'package:dat_chat/screens/web_layout_screen.dart';
import 'package:dat_chat/utils/responsive_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: LandingScreen(),
    );
  }
}
