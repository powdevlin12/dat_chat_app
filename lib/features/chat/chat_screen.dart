import 'package:dat_chat/common/widgets/bottom_chat_field.dart';
import 'package:dat_chat/features/auth/controller/auth_controller.dart';
import 'package:dat_chat/features/chat/chat_controller.dart';
import 'package:dat_chat/features/chat/widgets/my_message_card.dart';
import 'package:dat_chat/features/chat/widgets/send_message_card.dart';
import 'package:dat_chat/models/message_model.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const routeName = 'mobile-chat';
  final String name;
  final String uid;
  const ChatScreen({super.key, required this.name, required this.uid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final ScrollController messageController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(chatControllerProvider).setStatus(true);
    } else {
      ref.read(chatControllerProvider).setStatus(false);
    }
  }

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
              child: StreamBuilder<List<Message>>(
                stream: ref
                    .watch(chatControllerProvider)
                    .getListMessages(widget.uid),
                builder: (context, snapshot) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    messageController
                        .jumpTo(messageController.position.maxScrollExtent);
                  });
                  return ListView.builder(
                      controller: messageController,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong'),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Say hi to your friend'),
                          );
                        }
                        final message = snapshot.data![index];
                        String time = DateFormat.Hm().format(message.timeSent);

                        if (message.senderId != widget.uid) {
                          return MyMessageCard(
                            message: message.text,
                            time: time,
                            username: widget.name,
                          );
                        }

                        return SendMessageCard(
                            message: message.text,
                            time: time,
                            username: message.recieverid);
                      });
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: BottomChatField(
                recieverUserId: widget.uid,
              ),
            ),
            SizedBox(
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
