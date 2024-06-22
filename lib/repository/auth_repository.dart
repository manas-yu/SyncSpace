import 'dart:convert';

import 'package:dodoc/constants.dart';
import 'package:dodoc/models/error_model.dart';
import 'package:dodoc/models/user_model.dart';
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
  );
});
final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  AuthRepository({required GoogleSignIn googleSignIn, required Client client})
      : _googleSignIn = googleSignIn,
        _client = client;

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
            final newUser =
                userAcc.copyWith(uid: jsonDecode(res.body)['user']['_id']);
            errorModel = ErrorModel(errorMessage: null, data: newUser);
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
}
