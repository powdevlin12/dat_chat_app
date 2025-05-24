// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/common/provider/message_reply_provider.dart';
import 'package:dat_chat/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:dat_chat/features/chat/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(ref: ref, chatRepository: chatRepository);
});

class ChatController {
  final ProviderRef ref;
  final ChatRepository chatRepository;

  ChatController({
    required this.ref,
    required this.chatRepository,
  });

  // Add your chat-related methods and properties here
  void sendMessage(
    BuildContext context,
    String text,
    String recieverUserId,
  ) {
    ref.read(userDataAuthProvider).whenData(
          (value) => chatRepository.sendTextMessage(
              context: context,
              text: text,
              recieverUserId: recieverUserId,
              senderUser: value!),
        );
  }

  Stream<List<Message>> getListMessages(String recieverUserId) {
    return chatRepository.getListMessages(recieverUserId);
  }

  void setStatus(bool status) {
    ref.read(chatRepositoryProvider).setStatus(status);
  }

  void onSwipeMessage(
      {required String message,
      required bool isMe,
      required MessageEnum messageEnum}) {
    ref.read(messageReplyProvider.state).update(
          (state) => MessageReplyProvider(
            message: message,
            isMe: isMe,
            messageEnum: messageEnum,
          ),
        );
  }
}
