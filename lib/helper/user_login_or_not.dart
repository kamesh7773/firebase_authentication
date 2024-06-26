import 'package:shared_preferences/shared_preferences.dart';

class UserLoginStatus {
  //! Method that check user is login or Not with any Provider.
  static Future<bool> isUserLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;
    return isLogin;
  }
}
