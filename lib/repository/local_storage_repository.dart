import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  void saveToken(String token) async {
    // Save token to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', token);
    print('saving token $token ');
  }

  Future<String?> getToken() async {
    // Get token from local storage

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token');
    print('getting token $token  ');
    return token;
  }
}
