import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/features/auth/screens/otp_screen.dart';
import 'package:dat_chat/features/auth/screens/user_information_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  void singInWithPhone(BuildContext context, String phoneNumber) async {
    debugPrint('phone is $phoneNumber');
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint('phoneauth is an -------- verifynumber $credential');
            await auth.signInWithCredential(credential);
          },
          verificationFailed: (e) {
            throw Exception(e.message!);
          },
          codeSent: ((String verificationId, int? resendToken) async {
            Navigator.pushNamed(context, OtpScreen.routeName,
                arguments: verificationId);
          }),
          codeAutoRetrievalTimeout: (String verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackbar(context: context, content: e.message ?? "");
    }
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInfomationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackbar(context: context, content: e.message!);
    }
  }
}
