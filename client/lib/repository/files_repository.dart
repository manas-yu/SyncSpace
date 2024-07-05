import 'dart:convert';
import 'dart:typed_data';

import 'package:dodoc/constants.dart';
import 'package:dodoc/models/file_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import '../models/error_model.dart';

final filesRepositoryProvider = Provider(
  (ref) => FilesRepository(
    client: Client(),
  ),
);

class FilesRepository {
  final Client _client;

  FilesRepository({required Client client}) : _client = client;

  Future<ErrorModel> getFiles({
    required String token,
    required String id,
  }) async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      final res = await _client.get(
        Uri.parse("$host/file/$id"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "x-auth-token": token
        },
      );
      switch (res.statusCode) {
        case 200:
          List<FileModel> files = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            files.add(
              FileModel.fromJson(
                jsonEncode(jsonDecode(res.body)[i]),
              ),
            );
          }
          errorModel = ErrorModel(errorMessage: null, data: files);

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

  Future<ErrorModel> uploadFile({
    required String token,
    required String roomId,
    required Uint8List fileBytes,
    required String fileName,
    required String createdAt,
  }) async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      var uri = Uri.parse("$host/file/upload");
      var request = MultipartRequest('POST', uri)
        ..headers.addAll({
          "x-auth-token": token,
          "Content-Type": "multipart/form-data",
        })
        ..fields['createdAt'] = createdAt
        ..fields['roomId'] = roomId
        ..files.add(MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ));

      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData = FileModel.fromJson(response.body);
        errorModel = ErrorModel(errorMessage: null, data: responseData);
      } else {
        errorModel =
            ErrorModel(errorMessage: "Something went wrong", data: null);
      }
    } catch (e) {
      errorModel = ErrorModel(errorMessage: e.toString(), data: null);
    }
    return errorModel;
  }
}
