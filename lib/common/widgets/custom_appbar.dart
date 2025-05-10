import 'package:dat_chat/colors.dart';
import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final String title;
  const CustomAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      elevation: 0,
      backgroundColor: backgroundColor,
    );
  }
}
