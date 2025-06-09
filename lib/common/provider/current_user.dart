import 'package:dat_chat/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<UserModel?>((ref) => null);
