import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/provider/message_reply_provider.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class MessageReply extends ConsumerWidget {
  const MessageReply({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);

    if (messageReply?.message == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Coloors.webAppBarColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Replying to ${messageReply!.username}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(4),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 60,
                ),
                child: Text(
                  messageReply.message,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              ref.read(chatControllerProvider).clearReplyMessage();
            },
            child: Icon(Icons.close),
          )
        ],
      ),
    );
  }
}
