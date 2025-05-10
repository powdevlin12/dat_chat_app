import 'dart:io';

import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/utils/size_screen.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

class UserInfomationScreen extends ConsumerStatefulWidget {
  static const routeName = '/user-information';
  const UserInfomationScreen({super.key});

  @override
  _UserInfomationScreenState createState() => _UserInfomationScreenState();
}

class _UserInfomationScreenState extends ConsumerState<UserInfomationScreen> {
  File? image;
  final nameController = TextEditingController();

  void selectImage() async {
    debugPrint('click select');
    File? imagePicked = await pickImageFromGallery(context);
    setState(() {
      image = imagePicked;
    });
  }

  void storeUserData() async {
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      ref.read(authControllerProvider).saveUserdateToFirebase(
          context: context, name: name, profilePic: image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Gap(24),
            Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: image != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(image!),
                        )
                      : CircleAvatar(
                          backgroundColor: colorGrey,
                          child: Icon(
                            Iconsax.user,
                            size: 80,
                            color: blackColor,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: selectImage,
                    child: Icon(
                      Iconsax.add_circle,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
            Gap(24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: getSize(context).width * 0.7,
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Enter your name'),
                    controller: nameController,
                  ),
                ),
                Gap(16),
                InkWell(
                  onTap: storeUserData,
                  child: Icon(
                    Icons.check,
                    color: colorGrey,
                    size: 30,
                  ),
                )
              ],
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
