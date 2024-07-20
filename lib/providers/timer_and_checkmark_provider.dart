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

  // Method reset the Timer & Button to default when click back button for chnage value or he/she by mistake press the back button.
  // This method is called when user press back button in middle of filling otp on OTP Page so we have cancel the current timer and disable
  // Resent Button again if we don't do that the timer() get overlape and timer will run very fast and resent btn will get enable even though
  // timer is runing.
  void resetTimerAndBtn() {
    _timer!.cancel();
    _emailOtpSendBtnEnable = false;
    _forgotLinkBtbEnable = true;
    _phoneOtpSendBtnEnable = false;
    _duration = const Duration(seconds: 60);
  }
}
