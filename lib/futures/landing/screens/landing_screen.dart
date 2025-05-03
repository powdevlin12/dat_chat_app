import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(50),
            Text(
              'Welcome to Whatsapp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.w600),
            ),
            Gap(size.height / 9),
            Image.asset(
              'assets/bg.png',
              width: 340,
              height: 340,
              color: tabColor,
            ),
            Gap(size.height / 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
                style: TextStyle(color: colorGrey),
                textAlign: TextAlign.center,
              ),
            ),
            Gap(size.height / 16),
            SizedBox(
              width: size.width * 0.75,
              child: CustomButton(
                text: 'AGREE AND CONTINUTE',
                onPress: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
