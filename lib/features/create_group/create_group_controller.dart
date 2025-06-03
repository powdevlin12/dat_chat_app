// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dat_chat/features/create_group/create_group_repository.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createGroupControllerProvider = Provider<CreateGroupController>(
  (ref) => CreateGroupController(
    createGroupRepository: ref.read(createGroupRepositoryProvider),
  ),
);

class CreateGroupController {
  final CreateGroupRepository createGroupRepository;

  CreateGroupController({
    required this.createGroupRepository,
  });

  Future<UserModel?> getUserByPhone(String phoneNumber) {
    String phoneProcessing = phoneNumber.replaceFirst('0', '+84');
    return createGroupRepository.findUserByPhoneNumber(phoneProcessing);
  }

  Future<void> createGroup(
      {required BuildContext context,
      required String nameGroup,
      required List<UserModel> members}) async {
    List<String> membersIds = [];
    for (var user in members) {
      membersIds.add(user.uid);
    }
    createGroupRepository.creatGroup(
        context: context, nameGroup: nameGroup, membersIds: membersIds);
  }
}
