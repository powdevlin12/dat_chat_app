import 'package:dat_chat/features/list_chat/list_chat_repository.dart';
import 'package:dat_chat/models/chat_contact.dart';
import 'package:dat_chat/models/group_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listChatControllerProvider = Provider<ListChatController>((ref) {
  final listChatRepository = ref.watch(listChatRepositoryProvider);
  return ListChatController(
    listChatRepository: listChatRepository,
    ref: ref,
  );
});

class ListChatController {
  final ListChatRepository listChatRepository;
  final ProviderRef ref;
  ListChatController({
    required this.listChatRepository,
    required this.ref,
  });

  Stream<List<ChatContactModel>> getChatContacts() {
    return listChatRepository.getChatContacts();
  }

  Stream<List<GroupModel>> getGroupChat() {
    return listChatRepository.getGroupsChat();
  }
}
