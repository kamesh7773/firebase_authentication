import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetChecker {
  static late List<ConnectivityResult> connectivityResult;

  // Future Method for checking Internet
  static Future<bool> checkInternet() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    // if there is No internet then return "true"
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return true;
    // if internet connectioon is presend then return "false"
    } else {
      return false;
    }
  }
}
