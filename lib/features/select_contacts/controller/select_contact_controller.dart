// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dat_chat/features/select_contacts/repository/select_contact_repository.dart';

final getContactProvider = FutureProvider(
  (ref) {
    final selectContactRepository = ref.watch(selectContactRepositoryProvider);
    return selectContactRepository.getContacts();
  },
);

final selectContactControllerProvder = Provider((ref) {
  final selectContactRepository = ref.watch(selectContactRepositoryProvider);
  return SelectContactController(
      selectContactRepository: selectContactRepository);
});

class SelectContactController {
  SelectContactRepository selectContactRepository;
  SelectContactController({required this.selectContactRepository});

  void selectContact(String phoneNumber, BuildContext context) {
    selectContactRepository.selectContact(phoneNumber, context);
  }
}
