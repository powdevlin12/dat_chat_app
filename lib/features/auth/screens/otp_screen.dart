import 'package:dat_chat/colors.dart';
import 'package:dat_chat/constant/size.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class OtpScreen extends ConsumerWidget {
  static const String routeName = '/otp-screen';
  final String verificationid;
  const OtpScreen({super.key, required this.verificationid});

  void verifyOTP(
      {required BuildContext context,
      required WidgetRef ref,
      required String userOTP}) {
    ref.read(authControllerProvider).verifyOTP(
        context: context, verificationId: verificationid, userOTP: userOTP);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = getSize(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OTP verifying your number',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(16),
            Text(
              'We have send an SMS with a code',
              style: TextStyle(fontSize: 18),
            ),
            Gap(16),
            SizedBox(
              width: size.width * 0.6,
              child: TextField(
                decoration: InputDecoration(
                  hintText: '- - - - - -',
                  hintStyle: TextStyle(fontSize: 22),
                ),
                textAlign: TextAlign.center,
                onChanged: (val) {
                  if (val.length == 6) {
                    verifyOTP(context: context, ref: ref, userOTP: val);
                  }
                },
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }
}
