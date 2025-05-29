// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dat_chat/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createGroupRepositoryProvider = Provider<CreateGroupRepository>(
  (ref) => CreateGroupRepository(firestore: FirebaseFirestore.instance),
);

class CreateGroupRepository {
  final FirebaseFirestore firestore;

  CreateGroupRepository({
    required this.firestore,
  });

  Future<UserModel?> findUserByPhoneNumber(String phoneNumber) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1) // Chỉ lấy 1 kết quả để tối ưu
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // Không tìm thấy người dùng
      }

      final doc = querySnapshot.docs.first;
      return UserModel.fromMap(doc.data());
    } catch (e) {
      print('Lỗi khi tìm user: $e');
      rethrow;
    }
  }
}
