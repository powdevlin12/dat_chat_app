import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/common/utils/utils.dart';
import 'package:dat_chat/models/chat_contact.dart';
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

  void _saveDataToContactsSubcollection(
    UserModel senderUserData,
    UserModel? recieverUserData,
    String text,
    DateTime timeSent,
    String recieverUserId,
  ) async {
    // ** lưu người nhận vào Chat contact
    var recieverChatContact = ChatContactModel(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSend: timeSent.toIso8601String(),
        lastMessage: text,
        phone: senderUserData.phoneNumber);
    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(
          recieverChatContact.toMap(),
        );
    // ** lưu người gửi vào Chat contact
    var senderChatContact = ChatContactModel(
        name: recieverUserData!.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSend: timeSent.toIso8601String(),
        lastMessage: text,
        phone: recieverUserData.phoneNumber);
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .set(
          senderChatContact.toMap(),
        );
  }

  void _saveDataToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required MessageEnum messageType,
    required String? recieverUserName,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
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

      final messageId = Uuid().v1();

      _saveDataToContactsSubcollection(
          senderUser, recieverUserData, text, timeSend, recieverUserId);

      _saveDataToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSend,
        messageId: messageId,
        username: senderUser.name,
        messageType: MessageEnum.text,
        // senderUsername: senderUser.name,
        recieverUserName: recieverUserData.name,
      );
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
