import 'dart:convert';

import 'package:dodoc/constants.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/models/user_model.dart';
import 'package:dodoc/repository/local_storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) {
  const List<String> scopes = <String>[
    'email',
  ];
  return AuthRepository(
    googleSignIn: GoogleSignIn(scopes: scopes),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  );
});
final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel errorModel =
        ErrorModel(errorMessage: "Something went wrong", data: null);
    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        print(user.email);
        print(user.displayName);
        print(user.photoUrl);
        final userAcc = UserModel(
          uid: "",
          token: "",
          name: user.displayName ?? '',
          email: user.email,
          profilePic: user.photoUrl ?? '',
        );

        final res = await _client.post(Uri.parse("$host/api/signup"),
            body: userAcc.toJson(),
            headers: {
              "Content-Type": "application/json; charset=utf-8",
            });
        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            errorModel = ErrorModel(errorMessage: null, data: newUser);
            _localStorageRepository.saveToken(newUser.token);
            break;
          case 500:
            print("ServerSide Error");
            throw Exception("ServerSide Error");
          default:
            print("Error signing up user");
            throw Exception("Error signing up user");
        }
      }
    } catch (e) {
      print(e);
      errorModel = ErrorModel(errorMessage: e.toString(), data: null);
    }
    return errorModel;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      errorMessage: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(
                jsonDecode(res.body)['user'],
              ),
            ).copyWith(token: token);
            error = ErrorModel(errorMessage: null, data: newUser);
            _localStorageRepository.saveToken(newUser.token);
            break;
          default:
            throw Exception("Error getting user data");
        }
      }
    } catch (e) {
      error = ErrorModel(
        errorMessage: e.toString(),
        data: null,
      );
    }
    return error;
  }
}
