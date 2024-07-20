import 'package:flutter/material.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';
import 'package:firebase_authentication/helper/internet_checker.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PhoneNumberOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String countryCode;
  const PhoneNumberOtpPage({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
  });

  @override
  State<PhoneNumberOtpPage> createState() => PhoneNumberOtpPageState();
}

class PhoneNumberOtpPageState extends State<PhoneNumberOtpPage> {
  // Creating Key for phoneOtpTextfiledFormKey
  final GlobalKey<FormState> _phoneOtpTextfiledFormKey = GlobalKey<FormState>();

  // Declaring Texediting controller for Phone OTP Textfeild globally so it can also be used by Phone OTP ShowDiologBox
  final TextEditingController _phoneOtpController = TextEditingController();

  // variables
  String? errorText;
  late String _phoneOtp;

  // verify OTP Method
  void verifyOTP() {
    FirebaseAuthMethod.verifyPhoneOTP(
      countryCode: widget.countryCode,
      phoneNumber: widget.phoneNumber,
      verificationID: FirebaseAuthMethod.phoneotpVerficatoinID,
      otp: _phoneOtp,
      context: context,
    );
  }

  // resent OTP Method
  void resentOTP() {
    // Restarting the TImer again & and disabling the OTP resent btn
    context.read<TimerAndRadioButtonProvider>().startTimer();
    context.read<TimerAndRadioButtonProvider>().changePhoneOtpBtnValue = false;
    // verify OTP Method get called
    FirebaseAuthMethod.phoneAuthResendOtp(
      phoneNumber: widget.phoneNumber,
      countryCode: widget.countryCode,
      context: context,
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<TimerAndRadioButtonProvider>().startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (value) {
        if (value) {
          //! This method is called when user press back button in middle of filling otp on OTP Page so we have cancel the current timer and disable
          //! Resent Button again if we don't do that the timer() get overlape and timer will run very fast and resent btn will get enable even though
          //! timer is runing.
          context.read<TimerAndRadioButtonProvider>().resetTimerAndBtn();
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _phoneOtpTextfiledFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animation/phone_number_sms.json',
                    fit: BoxFit.contain,
                    width: 100,
                    height: 150,
                  ),
                  const Text(
                    "Verify your Phone Number!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Check your SMS APP, we sent you a OTP on your Phone Number for verification.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // OTP TextFeild for Phone number OTP feild ( Pinput )
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Pinput(
                      length: 6,
                      controller: _phoneOtpController,
                      autofocus: true,
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      androidSmsAutofillMethod:
                          AndroidSmsAutofillMethod.smsUserConsentApi,
                      errorText: errorText,
                      validator: (value) {
                        //! validation of Pinput() widget quiet diffrecnt then FromTextFeild() widget

                        // if Textfield is empty
                        if (value!.isEmpty) {
                          errorText = "OTP required";
                          return "OTP required";
                        }
                        // if otp is lower then 6 digit's
                        else if (value.length < 6) {
                          errorText = "Make sure all OTP fields are filled in";
                          return "Make sure all OTP fields are filled in";
                        }
                        // validating Phone number
                        else if (!RegExp(r"^[0-9]{1,6}$").hasMatch(value)) {
                          errorText = "Only digit are allowed";
                          return "Only digit are allowed";
                        }

                        // else return nothing
                        else {
                          errorText = null;
                          return null;
                        }
                      },
                      onCompleted: (value) async {
                        // storeing interent state in veriable
                        bool isInternet = await InternetChecker.checkInternet();

                        // if OTP Validation Not done then return nothing means nothing will happen
                        if (errorText != null) {
                          return;
                        }
                        // If Internet is not there then...
                        else if (isInternet && context.mounted) {
                          SnackBars.normalSnackBar(
                              context, "Please turn on your Internet");
                        }
                        // if Internt is there & validation is also completed
                        else if (errorText == null) {
                          // assigning OTP to _emailOtp variable.
                          _phoneOtp = _phoneOtpController.text.trim();
                          // call the verify OTP Method
                          verifyOTP();
                        }
                      },
                      errorTextStyle: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 211, 58, 47),
                      ),
                      defaultPinTheme: PinTheme(
                        textStyle: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        width: 54,
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10),
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Send OTP again in"),
                          //! Provider Selector is used
                          Selector<TimerAndRadioButtonProvider, Duration>(
                            selector: (context, otptimer) => otptimer.duration,
                            builder: (context, duration, child) {
                              return Text(
                                " 00:${duration.inSeconds.toString()}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          const Text(" sec")
                        ],
                      ),
                      //! Provider Selector is used
                      Selector<TimerAndRadioButtonProvider, bool>(
                          selector: (context, otpBtn) =>
                              otpBtn.phoneOtpSendBtnEnable,
                          builder: (context, value, child) {
                            return TextButton(
                              // Method that call resent OTP
                              onPressed: () async {
                                // storeing interent state in veriable
                                bool isInternet =
                                    await InternetChecker.checkInternet();

                                // if there is not internet
                                if (isInternet && context.mounted) {
                                  SnackBars.normalSnackBar(
                                      context, "Please turn on your Internet");
                                }
                                // if Internet connection is avaible
                                else {
                                  if (context.mounted) {
                                    if (value) {
                                      resentOTP();
                                    } else {
                                      return;
                                    }
                                  }
                                }
                              },
                              child: Text(
                                "Resend",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: value ? Colors.blue : Colors.grey,
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
