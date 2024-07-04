import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class FileModel {
  String id;
  String uid;
  String roomId;
  String filename;
  String originalname;
  String mimetype;
  int size;
  String path;
  int createdAt;

  FileModel({
    required this.id,
    required this.uid,
    required this.roomId,
    required this.filename,
    required this.originalname,
    required this.mimetype,
    required this.size,
    required this.path,
    required this.createdAt,
  });

  FileModel copyWith({
    String? id,
    String? uid,
    String? roomId,
    String? filename,
    String? originalname,
    String? mimetype,
    int? size,
    String? path,
    int? createdAt,
  }) {
    return FileModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      roomId: roomId ?? this.roomId,
      filename: filename ?? this.filename,
      originalname: originalname ?? this.originalname,
      mimetype: mimetype ?? this.mimetype,
      size: size ?? this.size,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'uid': uid,
      'roomId': roomId,
      'filename': filename,
      'originalname': originalname,
      'mimetype': mimetype,
      'size': size,
      'path': path,
      'createdAt': createdAt,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      id: map['_id'] as String,
      uid: map['uid'] as String,
      roomId: map['roomId'] as String,
      filename: map['filename'] as String,
      originalname: map['originalname'] as String,
      mimetype: map['mimetype'] as String,
      size: map['size'] as int,
      path: map['path'] as String,
      createdAt: map['createdAt'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory FileModel.fromJson(String source) =>
      FileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FileModel(id: $id, uid: $uid, roomId: $roomId, filename: $filename, originalname: $originalname, mimetype: $mimetype, size: $size, path: $path, createdAt: $createdAt)';
  }
}
