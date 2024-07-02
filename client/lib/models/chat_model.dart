// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatModel {
  final String id;
  final String username;
  final DateTime createdAt;
  final String content;
  final String profilePic;
  final String uid;
  final String roomId;
  ChatModel({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.content,
    required this.profilePic,
    required this.uid,
    required this.roomId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'username': username,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'content': content,
      'profilePic': profilePic,
      'uid': uid,
      'roomId': roomId,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['_id'] as String,
      username: map['username'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      content: map['content'] as String,
      profilePic: map['profilePic'] as String,
      uid: map['uid'] as String,
      roomId: map['roomId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ChatModel copyWith({
    String? id,
    String? username,
    DateTime? createdAt,
    String? content,
    String? profilePic,
    String? uid,
    String? roomId,
  }) {
    return ChatModel(
      id: id ?? this.id,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      roomId: roomId ?? this.roomId,
    );
  }
}
