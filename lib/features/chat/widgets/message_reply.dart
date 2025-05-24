import 'package:dat_chat/common/provider/message_reply_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageReply extends ConsumerWidget {
  const MessageReply({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    if (messageReply?.message == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Text(messageReply!.message),
    );
  }
}
