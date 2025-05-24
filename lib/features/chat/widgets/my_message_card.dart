import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/common/provider/message_reply_provider.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends ConsumerWidget {
  final String message;
  final String time;
  final String username;

  const MyMessageCard({
    super.key,
    required this.message,
    required this.time,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeTo(
      onLeftSwipe: (details) {
        ref.read(chatControllerProvider).onSwipeMessage(
              message: message,
              isMe: true,
              messageEnum: MessageEnum.text,
            );
      },
      iconOnLeftSwipe: Icons.reply,
      swipeSensitivity: 8,
      animationDuration: const Duration(milliseconds: 120),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: messageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 5,
                bottom: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
