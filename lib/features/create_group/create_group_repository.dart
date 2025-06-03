// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/models/group_model.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final createGroupRepositoryProvider = Provider<CreateGroupRepository>(
  (ref) => CreateGroupRepository(
      firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance),
);

class CreateGroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CreateGroupRepository({required this.firestore, required this.auth});

  Future<UserModel?> findUserByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1) // Chỉ lấy 1 kết quả để tối ưu
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // Không tìm thấy người dùng
      }

      final doc = querySnapshot.docs.first;
      return UserModel.fromMap(doc.data());
    } catch (e) {
      print('Lỗi khi tìm user: $e');
      rethrow;
    }
  }

  Future<void> creatGroup(
      {required BuildContext context,
      required String nameGroup,
      required List<String> membersIds}) async {
    final groupId = const Uuid().v1();
    try {
      GroupModel group = GroupModel(
        senderId: auth.currentUser!.uid,
        name: nameGroup,
        groupId: groupId,
        lastMessage: '',
        groupPic:
            'https://icdn.sempreinter.com/wp-content/uploads/2025/01/Lautaro-Martinez-Inter-Milan-6.jpg',
        membersUid: [...membersIds, auth.currentUser!.uid],
        timeSent: DateTime.now().toIso8601String(),
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
