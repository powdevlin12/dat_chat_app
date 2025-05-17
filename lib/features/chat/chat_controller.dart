// ignore_for_file: public_member_api_docs, sort_constructors_first
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
}
