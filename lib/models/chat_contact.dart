import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatContactModel {
  String name;
  String profilePic;
  String contactId;
  String timeSend;
  String lastMessage;

  ChatContactModel({
    required this.name,
    required this.profilePic,
    required this.contactId,
    required this.timeSend,
    required this.lastMessage,
  });

  ChatContactModel copyWith({
    String? name,
    String? profilePic,
    String? contactId,
    String? timeSend,
    String? lastMessage,
  }) {
    return ChatContactModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      contactId: contactId ?? this.contactId,
      timeSend: timeSend ?? this.timeSend,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSend': timeSend,
      'lastMessage': lastMessage,
    };
  }

  factory ChatContactModel.fromMap(Map<String, dynamic> map) {
    return ChatContactModel(
      name: map['name'] as String,
      profilePic: map['profilePic'] as String,
      contactId: map['contactId'] as String,
      timeSend: map['timeSend'] as String,
      lastMessage: map['lastMessage'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatContactModel.fromJson(String source) =>
      ChatContactModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatContactModel(name: $name, profilePic: $profilePic, contactId: $contactId, timeSend: $timeSend, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(covariant ChatContactModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePic == profilePic &&
        other.contactId == contactId &&
        other.timeSend == timeSend &&
        other.lastMessage == lastMessage;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePic.hashCode ^
        contactId.hashCode ^
        timeSend.hashCode ^
        lastMessage.hashCode;
  }
}
