import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_to/swipe_to.dart';

class SendMessageCard extends ConsumerWidget {
  final String message;
  final String time;
  final String username;
  const SendMessageCard(
      {super.key,
      required this.message,
      required this.time,
      required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeTo(
      onRightSwipe: (details) {
        ref.read(chatControllerProvider).onSwipeMessage(
            message: message,
            isMe: false,
            messageEnum: MessageEnum.text,
            username: username);
      },
      iconOnRightSwipe: Icons.reply,
      swipeSensitivity: 8,
      animationDuration: const Duration(milliseconds: 120),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: senderMessageColor,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
