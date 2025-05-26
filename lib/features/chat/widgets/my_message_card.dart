import 'package:dat_chat/colors.dart';
import 'package:dat_chat/common/enum/message_enum.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:swipe_to/swipe_to.dart';

class MyMessageCard extends ConsumerWidget {
  final String message;
  final String time;
  final String username;
  final String? replyMessage;
  final bool isSeen;

  const MyMessageCard(
      {super.key,
      required this.message,
      required this.time,
      required this.username,
      this.replyMessage,
      required this.isSeen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipeTo(
      onLeftSwipe: (details) {
        ref.read(chatControllerProvider).onSwipeMessage(
              message: message,
              isMe: true,
              messageEnum: MessageEnum.text,
              username: username,
            );
      },
      iconOnLeftSwipe: Icons.reply,
      swipeSensitivity: 8,
      animationDuration: const Duration(milliseconds: 120),
      child: Stack(
        children: [
          if (replyMessage != '')
            Positioned(
              top: 2,
              right: 16,
              child: Container(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 6, bottom: 16),
                decoration: BoxDecoration(
                  color: Coloors.bgMessageReply,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reply to Dat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      replyMessage ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.white60),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          Column(
            children: [
              if (replyMessage != '') Gap(40),
              Align(
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
                    color: Coloors.messageColor,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Padding(
                      padding: EdgeInsets.only(
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
                          SizedBox(
                            width: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  time,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white60,
                                      fontWeight: FontWeight.w700),
                                ),
                                Gap(4),
                                if (isSeen)
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.white60,
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
