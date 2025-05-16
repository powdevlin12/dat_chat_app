// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:dat_chat/screens/mobile_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:riverpod/riverpod.dart';

final selectContactRepositoryProvider = Provider((ref) {
  return SelectContactRepository(firestore: FirebaseFirestore.instance);
});

class SelectContactRepository {
  final FirebaseFirestore firestore;
  SelectContactRepository({
    required this.firestore,
  });

  Future<List<Contact>> getContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint('--------------$e');
    }
    debugPrint('------------ ${contacts.toString()}');
    return contacts;
  }

  void selectContact(String phoneNumber, BuildContext context) async {
    bool isFound = false;
    UserModel? user;
    try {
      var users = await firestore.collection('users').get();
      for (var userDoc in users.docs) {
        user = UserModel.fromMap(userDoc.data());
        debugPrint(phoneNumber.replaceAll(' ', ''));
        debugPrint(user.phoneNumber);

        if (phoneNumber.replaceAll(' ', '') == user.phoneNumber ||
            phoneNumber.replaceAll(' ', '').replaceAll('0', '+84') ==
                user.phoneNumber) {
          isFound = true;
          break;
        }
      }
      if (isFound) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                MobileChatScreen(name: user!.name, uid: user.uid),
          ),
        );
      } else {
        showSnackbar(
            context: context, content: 'This phone  is not found in system');
      }
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
