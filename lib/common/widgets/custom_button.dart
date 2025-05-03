import 'package:dat_chat/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  const CustomButton({super.key, required this.text, this.onPress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: tabColor,
        minimumSize: Size(
          double.infinity,
          50,
        ),
        shape: RoundedRectangleBorder(
          // Add this shape property
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: blackColor),
      ),
    );
  }
}
