import 'dart:convert';

import 'package:collection/collection.dart';

class UserModel {
  final String uid;
  final String name;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;
  final List<String> groupIds;

  UserModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.isOnline,
    required this.phoneNumber,
    required this.groupIds,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? profilePic,
    bool? isOnline,
    String? phoneNumber,
    List<String>? groupIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      isOnline: isOnline ?? this.isOnline,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      groupIds: groupIds ?? this.groupIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'groupIds': groupIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      groupIds: List<String>.from(map['groupIds']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, profilePic: $profilePic, isOnline: $isOnline, phoneNumber: $phoneNumber, groupIds: $groupIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.isOnline == isOnline &&
        other.phoneNumber == phoneNumber &&
        listEquals(other.groupIds, groupIds);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        profilePic.hashCode ^
        isOnline.hashCode ^
        phoneNumber.hashCode ^
        const DeepCollectionEquality().hash(groupIds);
  }
}
