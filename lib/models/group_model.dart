// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GroupModel {
  final String senderId;
  final String name;
  final String groupId;
  final String lastMessage;
  final String groupPic;
  final List<String> membersUid;
  final String timeSent;
  GroupModel({
    required this.senderId,
    required this.name,
    required this.groupId,
    required this.lastMessage,
    required this.groupPic,
    required this.membersUid,
    required this.timeSent,
  });

  GroupModel copyWith({
    String? senderId,
    String? name,
    String? groupId,
    String? lastMessage,
    String? groupPic,
    List<String>? membersUid,
    String? timeSent,
  }) {
    return GroupModel(
      senderId: senderId ?? this.senderId,
      name: name ?? this.name,
      groupId: groupId ?? this.groupId,
      lastMessage: lastMessage ?? this.lastMessage,
      groupPic: groupPic ?? this.groupPic,
      membersUid: membersUid ?? this.membersUid,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'name': name,
      'groupId': groupId,
      'lastMessage': lastMessage,
      'groupPic': groupPic,
      'membersUid': membersUid,
      'timeSent': timeSent,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      senderId: map['senderId'] as String,
      name: map['name'] as String,
      groupId: map['groupId'] as String,
      lastMessage: map['lastMessage'] as String,
      groupPic: map['groupPic'] as String,
      membersUid: List<String>.from((map['membersUid'] as List<String>)),
      timeSent: map['timeSent'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupModel.fromJson(String source) =>
      GroupModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GroupModel(senderId: $senderId, name: $name, groupId: $groupId, lastMessage: $lastMessage, groupPic: $groupPic, membersUid: $membersUid, timeSent: $timeSent)';
  }

  @override
  bool operator ==(covariant GroupModel other) {
    if (identical(this, other)) return true;

    return other.senderId == senderId &&
        other.name == name &&
        other.groupId == groupId &&
        other.lastMessage == lastMessage &&
        other.groupPic == groupPic &&
        listEquals(other.membersUid, membersUid) &&
        other.timeSent == timeSent;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
        name.hashCode ^
        groupId.hashCode ^
        lastMessage.hashCode ^
        groupPic.hashCode ^
        membersUid.hashCode ^
        timeSent.hashCode;
  }
}
