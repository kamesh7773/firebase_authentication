import 'package:flutter/material.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';
import 'package:firebase_authentication/helper/internet_checker.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class EmailOtpPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String userName;
  final String password;
  const EmailOtpPage({
    super.key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.password,
  });

  @override
  State<EmailOtpPage> createState() => EmailOtpPageOtpPageState();
}

class EmailOtpPageOtpPageState extends State<EmailOtpPage> {
  // Creating Key for phoneOtpTextfiledFormKey
  final GlobalKey<FormState> _emailOtpTextfiledFormKey = GlobalKey<FormState>();

  // Declaring Texediting controller for Phone OTP Textfeild globally so it can also be used by Phone OTP ShowDiologBox
  final TextEditingController _emailOtpController = TextEditingController();

  // variables
  String? errorText;
  late String _emailOtp;

// getting the otpBtnvalue from provider

  // verify OTP Method
  void verifyOTP() {
    FirebaseAuthMethod.verifyEmailOTP(
      email: widget.email,
      emailOTP: _emailOtp,
      firstName: widget.firstName,
      lastName: widget.lastName,
      userName: widget.userName,
      password: widget.password,
      context: context,
    );
  }

  // resent OTP Method
  void resentOTP() {
    // Restarting the TImer again & and disabling the OTP resent btn
    context.read<TimerAndRadioButtonProvider>().startTimer();
    context.read<TimerAndRadioButtonProvider>().changeEmailOtpBtnValue = false;

    FirebaseAuthMethod.emailAuthResentOTP(
      email: widget.email,
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
              key: _emailOtpTextfiledFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animation/mail_inbox.json',
                    fit: BoxFit.contain,
                    width: 300,
                    height: 200,
                  ),
                  const Text(
                    "Verify your email address!",
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
                      widget.email,
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
                      "Check your mail box, we sent you a OTP on your email for verification.Once you verify your email, your account will be successfully created.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // OTP TextFeild for Phone number OTP feild ( Pinput )
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Pinput(
                      length: 6,
                      controller: _emailOtpController,
                      autofocus: true,
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
                      androidSmsAutofillMethod:
                          AndroidSmsAutofillMethod.smsUserConsentApi,
                      errorText: errorText,
                      validator: (value) {
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
                          _emailOtp = _emailOtpController.text.trim();
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
                            otpBtn.emailOtpSendBtnEnable,
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
                        },
                      )
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
