import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/models/chat_contact.dart';
import 'package:dat_chat/models/group_model.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listChatRepositoryProvider = Provider<ListChatRepository>(
  (ref) => ListChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);

class ListChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ListChatRepository({
    required this.firestore,
    required this.auth,
  });

  Stream<List<ChatContactModel>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .orderBy('timeSend', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<ChatContactModel> contacts = [];
      for (var doc in event.docs) {
        var chatContact = ChatContactModel.fromMap(doc.data());
        var userData = await firestore
            .collection('users')
            .doc(chatContact.contactId)
            .get();
        var user = UserModel.fromMap(userData.data()!);

        contacts.add(
          ChatContactModel(
              name: user.name,
              profilePic: user.profilePic,
              contactId: chatContact.contactId,
              timeSend: chatContact.timeSend,
              lastMessage: chatContact.lastMessage,
              phone: chatContact.phone),
        );
      }
      return contacts;
    });
  }

  Stream<List<GroupModel>> getGroupsChat() {
    try {
      return firestore.collection('groups').snapshots().asyncMap((event) {
        List<GroupModel> listGroup = [];
        for (var document in event.docs) {
          debugPrint('Group data: ${document.data()}');
          GroupModel group = GroupModel.fromMap(document.data());
          listGroup.add(group);
        }
        return listGroup;
      });
    } catch (e) {
      debugPrint('Error getting groups chat: $e');
      return Stream.value([]);
    }
  }

  // Thêm hàm này để test trực tiếp
  Future<void> testDirectQuery() async {
    final uid = auth.currentUser!.uid;
    debugPrint('Testing with UID: $uid');

    try {
      // Kiểm tra user document
      final userDoc = await firestore.collection('users').doc(uid).get();
      debugPrint('User exists: ${userDoc.exists}');
      if (userDoc.exists) {
        debugPrint('User data: ${userDoc.data()}');
      }

      // Kiểm tra chats collection
      final chatsSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('chats')
          .get();

      debugPrint('Chats count: ${chatsSnapshot.docs.length}');
      for (var doc in chatsSnapshot.docs) {
        debugPrint('Chat ID: ${doc.id}, data: ${doc.data()}');
      }
    } catch (e) {
      debugPrint('Error testing direct query: $e');
    }
  }
}
