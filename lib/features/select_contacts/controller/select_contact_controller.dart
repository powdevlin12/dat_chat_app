import 'package:dat_chat/features/select_contacts/repository/select_contact_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getContactProvider = FutureProvider(
  (ref) {
    final selectContactRepository = ref.watch(selectContactRepositoryProvider);
    return selectContactRepository.getContacts();
  },
);
