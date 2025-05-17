import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/models/message_model.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  void _saveDataToContactsSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String senderUsername,
    required String? recieverUserName,
  }) async {
    final message = Message(
      senderId: senderUsername,
      recieverid: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
    );

    // users -> sender id -> reciever id -> messages -> message id -> store message
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );

    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(
          message.toMap(),
        );
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required UserModel senderUser,
  }) async {
    try {
      final timeSend = DateTime.now();
      UserModel? recieverUserData;

      final userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieverUserData = UserModel.fromMap(userDataMap.data()!);

      final messageId = Uuid().v4();

      _saveDataToContactsSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSend,
        messageId: messageId,
        username: senderUser.name,
        messageType: MessageEnum.text,
        senderUsername: senderUser.name,
        recieverUserName: recieverUserData.name,
      );
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
