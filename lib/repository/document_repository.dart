import 'dart:convert';

import 'package:dodoc/constants.dart';
import 'package:dodoc/models/document_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../models/error_model.dart';

final documentRepositoryProvider = Provider(
  (ref) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;
  DocumentRepository({required Client client}) : _client = client;
  Future<ErrorModel> createDocument(String token) async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      final res = await _client.post(
        Uri.parse("$host/doc/create"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "x-auth-token": token
        },
        body: jsonEncode(
          {
            "createdAt": DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
      switch (res.statusCode) {
        case 200:
          errorModel = ErrorModel(
              errorMessage: null, data: DocumentModel.fromJson(res.body));
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
