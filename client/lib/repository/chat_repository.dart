import 'dart:convert';

import 'package:dodoc/constants.dart';
import 'package:dodoc/models/chat_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../models/error_model.dart';

final chatRepositoryProvider = Provider(
  (ref) => ChatRepository(
    client: Client(),
  ),
);

class ChatRepository {
  final Client _client;
  ChatRepository({required Client client}) : _client = client;

  Future<ErrorModel> getChats(String token, String id) async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      final res = await _client.get(
        Uri.parse("$host/chat/$id"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "x-auth-token": token
        },
      );
      switch (res.statusCode) {
        case 200:
          List<ChatModel> chats = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            chats.add(
              ChatModel.fromJson(
                jsonEncode(jsonDecode(res.body)[i]),
              ),
            );
          }
          errorModel = ErrorModel(errorMessage: null, data: chats);
          break;
        default:
          errorModel =
              ErrorModel(errorMessage: "Something went wrong", data: null);
          break;
      }
    } catch (e) {
      errorModel = ErrorModel(errorMessage: e.toString(), data: null);
    }
    return errorModel;
  }

  Future<ErrorModel> saveChat({
    required String token,
    required String profilePic,
    required String roomId,
    required String content,
    required String username,
  }) async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      final res = await _client.post(
        Uri.parse("$host/chat/newMessage"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "x-auth-token": token
        },
        body: jsonEncode(
          {
            "createdAt": DateTime.now().millisecondsSinceEpoch,
            "profilePic": profilePic,
            "roomId": roomId,
            "content": content,
            "username": username,
          },
        ),
      );
      switch (res.statusCode) {
        case 200:
          errorModel = ErrorModel(
              errorMessage: null, data: ChatModel.fromJson(res.body));
          break;
        default:
          errorModel =
              ErrorModel(errorMessage: "Something went wrong", data: null);
          break;
      }
    } catch (e) {
      errorModel = ErrorModel(errorMessage: e.toString(), data: null);
    }
    return errorModel;
  }
}
