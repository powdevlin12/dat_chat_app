// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReplyProvider {
  final String message;
  final bool isMe;
  final MessageEnum messageEnum;

  MessageReplyProvider({
    required this.message,
    required this.isMe,
    required this.messageEnum,
  });
}

final messageReplyProvider =
    StateProvider<MessageReplyProvider?>((ref) => null);
