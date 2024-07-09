// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DocumentModel {
  final String title;
  final String uid;
  final List content;
  final DateTime createdAt;
  final String id;
  final List<String> sharedWith;
  DocumentModel({
    required this.sharedWith,
    required this.title,
    required this.uid,
    required this.content,
    required this.createdAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'uid': uid,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      '_id': id,
      'sharedWith': sharedWith,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      title: map['title'] as String,
      uid: map['uid'] as String,
      content: List.from(map['content'] as List),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      id: map['_id'] as String,
      sharedWith: List<String>.from(map['sharedWith'] as List<dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  DocumentModel copyWith({
    String? title,
    String? uid,
    List? content,
    DateTime? createdAt,
    String? id,
    List<String>? sharedWith,
  }) {
    return DocumentModel(
      title: title ?? this.title,
      uid: uid ?? this.uid,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  @override
  String toString() {
    return 'DocumentModel(title: $title, uid: $uid, content: $content, createdAt: $createdAt, id: $id, sharedWith: $sharedWith)';
  }
}
