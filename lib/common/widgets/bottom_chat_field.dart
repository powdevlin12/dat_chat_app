import 'package:dat_chat/colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key});

  @override
  _BottomChatFieldState createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  FocusNode focusNode = FocusNode();
  bool isSendIcon = false;

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
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
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: colorGrey,
                        size: 24,
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
            onTap: () {},
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
    );
  }
}
