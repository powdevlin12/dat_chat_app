import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/features/auth/screens/otp_screen.dart';
import 'package:dat_chat/features/auth/screens/user_information_screen.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:dat_chat/screens/mobile_layout_screen.dart';
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

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

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

  void saveUserdataToFirebase(
      {required String name,
      required File? profilePic,
      required ProviderRef ref,
      required BuildContext context}) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Cristiano_Ronaldo_WC2022_-_02.jpg/250px-Cristiano_Ronaldo_WC2022_-_02.jpg';
      if (profilePic != null) {
        // photoUrl = await ref
        //     .read(CommonFirebaseStorageRepositoryProvider)
        //     .storeFileToFirebase('profilePic/$uid', profilePic);
      }

      var user = UserModel(
        uid: uid,
        name: name,
        profilePic: photoUrl,
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupIds: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MobileLayoutScreen(),
          ),
          (route) => false);
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }

  Stream<UserModel> getUser(String userID) {
    return firestore
        .collection('users')
        .doc(userID)
        .snapshots()
        .map((el) => UserModel.fromMap(el.data()!));
  }
}
