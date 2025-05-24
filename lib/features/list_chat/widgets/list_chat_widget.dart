import 'package:cached_network_image/cached_network_image.dart';
import 'package:dat_chat/features/list_chat/list_chat_controller.dart';
import 'package:dat_chat/features/select_contacts/repository/select_contact_repository.dart';
import 'package:dat_chat/models/chat_contact.dart';
import 'package:dat_chat/screens/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ListChatWidget extends ConsumerWidget {
  const ListChatWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<ChatContactModel>>(
              stream: ref.watch(listChatControllerProvider).getChatContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];

                      return InkWell(
                        onTap: () {
                          ref
                              .read(selectContactRepositoryProvider)
                              .selectContact(chatContactData.phone, context);
                        },
                        child: ListTile(
                          title: Text(
                            chatContactData.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: Text(
                              chatContactData.lastMessage,
                              style: const TextStyle(fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          leading: CachedNetworkImage(
                            imageUrl: chatContactData.profilePic,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) {
                              debugPrint(url);
                              return CircularProgressIndicator();
                            },
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Text(
                  'Không có dữ liệu',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
