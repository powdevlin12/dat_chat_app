import 'package:dat_chat/colors.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;

  const BottomChatField({super.key, required this.recieverUserId});

  @override
  _BottomChatFieldState createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  FocusNode focusNode = FocusNode();
  bool isSendIcon = false;
  final TextEditingController _messageController = TextEditingController();
  bool isShowEmoji = false;

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  void initState() {
    super.initState();
    _messageController.text = '';

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isShowEmoji = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
  }

  void sendMessage() {
    ref
        .read(chatControllerProvider)
        .sendMessage(context, _messageController.text, widget.recieverUserId);
    hideKeyboard();
    setState(() {
      _messageController.text = '';
      isSendIcon = false;
    });
  }

  void _handleToggeShowEmoji() {
    setState(() {
      isShowEmoji = !isShowEmoji;
    });
    if (isShowEmoji) {
      hideKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    onChanged: ((val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          isSendIcon = true;
                        });
                      } else {
                        setState(() {
                          isSendIcon = false;
                        });
                      }
                    }),
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter your message ...',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          width: 0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          width: 0,
                        ),
                      ),
                      fillColor: chatBarMessage,
                      filled: true,
                      prefixIcon: Container(
                        padding: EdgeInsets.only(left: 8),
                        width: 68,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: _handleToggeShowEmoji,
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                color: colorGrey,
                                size: 24,
                              ),
                            ),
                            Gap(8),
                            Icon(
                              Icons.gif,
                              color: colorGrey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      suffixIcon: SizedBox(
                        width: 68,
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              color: colorGrey,
                              size: 24,
                            ),
                            Gap(8),
                            Icon(
                              Icons.camera_alt_outlined,
                              color: colorGrey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(12),
                InkWell(
                  onTap: isSendIcon ? sendMessage : () {},
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: CircleAvatar(
                      backgroundColor: tabColor,
                      child: Icon(
                        isSendIcon ? Icons.send : Icons.mic,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          isShowEmoji
              ? SizedBox(
                  height: 310,
                  child: EmojiPicker(
                    textEditingController: _messageController,
                    onEmojiSelected: (category, emoji) {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                      setState(() {
                        isSendIcon = true;
                      });
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
