import 'package:flutter/foundation.dart';
import 'dart:async';

class TimerAndRadioButtonProvider extends ChangeNotifier {
  // variable's delcartion.
  bool _showPassword = true;
  bool _isChecked = false;
  bool _emailOtpSendBtnEnable = false;
  bool _phoneOtpSendBtnEnable = false;
  bool _forgotLinkBtbEnable = true;
  Duration _duration = const Duration(seconds: 60);
  Timer? _timer;

  // declaring getters.
  bool get showPassword => _showPassword;
  bool get isChecked => _isChecked;
  bool get emailOtpSendBtnEnable => _emailOtpSendBtnEnable;
  bool get phoneOtpSendBtnEnable => _phoneOtpSendBtnEnable;
  bool get forgotLinkBtbEnable => _forgotLinkBtbEnable;
  Duration get duration => _duration;
  Timer? get timer => _timer;

  // declarting setters.
  set changeEmailOtpBtnValue(bool value) {
    _emailOtpSendBtnEnable = value;
    notifyListeners();
  }

  set changePhoneOtpBtnValue(bool value) {
    _phoneOtpSendBtnEnable = value;
    notifyListeners();
  }

  // declarting setters.
  set changeForgotLinkBtnValue(bool value) {
    _forgotLinkBtbEnable = value;
    notifyListeners();
  }

  // Method that hide/show the password.
  void showPasswordMethod() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  // Method that checked/unchecked the RadioBtn.
  void isCheckedMethod() {
    _isChecked = !_isChecked;
    notifyListeners();
  }

  // Method that for OTP Timer.
  void startTimer() {
    _duration = const Duration(seconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration -= const Duration(seconds: 1);
        notifyListeners();
      } else {
        timer.cancel();
        _emailOtpSendBtnEnable = true;
        _phoneOtpSendBtnEnable = true;
        _forgotLinkBtbEnable = true;
        _duration = const Duration(seconds: 60);
        notifyListeners();
      }
    });
  }
}
