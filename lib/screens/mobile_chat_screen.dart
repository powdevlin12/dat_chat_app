import 'package:dat_chat/common/widgets/bottom_chat_field.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileChatScreen extends ConsumerStatefulWidget {
  static const routeName = 'mobile-chat';
  final String name;
  final String uid;
  const MobileChatScreen({super.key, required this.name, required this.uid});

  @override
  _MobileChatScreenState createState() => _MobileChatScreenState();
}

class _MobileChatScreenState extends ConsumerState<MobileChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: StreamBuilder<UserModel>(
          stream: ref.read(authControllerProvider).getUser(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data!.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(
                  snapshot.data!.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(fontSize: 14),
                )
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Text('List Chat'),
            ),
            SizedBox(
              width: double.infinity,
              child: BottomChatField(),
            ),
            SizedBox(
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }
}
