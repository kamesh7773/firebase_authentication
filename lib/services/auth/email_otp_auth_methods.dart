import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailAuth {
  // Method for sending OTP
  static Future<Map<String, dynamic>> sendEmail({required String email}) async {
    try {
      var url =
          Uri.https("direct-robbi-kamesh-cc8a724a.koyeb.app", "/otp-login");

      var res = await http.Client().post(
        url,
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "email": email,
        }),
      );

      Map<String, dynamic> mapData = jsonDecode(res.body);
      return mapData;
    } catch (error) {
      throw error.toString();
    }
  }

  // Method for verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String hash,
    required String otp,
  }) async {
    try {
      var url =
          Uri.https("direct-robbi-kamesh-cc8a724a.koyeb.app", "/otp-verify");

      var res = await http.Client().post(
        url,
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({
          "email": email,
          "hash": hash,
          "otp": otp,
        }),
      );

      Map<String, dynamic> mapData = jsonDecode(res.body);
      return mapData;
    } catch (error) {
      throw error.toString();
    }
  }
}
