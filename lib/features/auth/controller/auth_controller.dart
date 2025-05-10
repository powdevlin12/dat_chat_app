// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dat_chat/features/auth/repository/auth_repository.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  // watch = Provider.of<AuthRepository>(context)
  return AuthController(authRepository: authRepository, ref: ref);
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({
    required this.authRepository,
    required this.ref,
  });

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.singInWithPhone(context, phoneNumber);
  }

  void verifyOTP(
      {required BuildContext context,
      required String verificationId,
      required String userOTP}) {
    authRepository.verifyOTP(
        context: context, userOTP: userOTP, verificationId: verificationId);
  }

  void saveUserdateToFirebase(
      {required BuildContext context,
      required String name,
      required File? profilePic}) async {
    authRepository.saveUserdataToFirebase(
        name: name, profilePic: profilePic, ref: ref, context: context);
  }
}
