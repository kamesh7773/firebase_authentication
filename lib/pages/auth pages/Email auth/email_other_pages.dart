import 'package:flutter/material.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';
import 'package:firebase_authentication/helper/form_validators.dart';
import 'package:firebase_authentication/helper/internet_checker.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:firebase_authentication/widgets/textformfeild_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// --------------------------------------------------------------------------------
// varification page that display to User when their email is verifeid successfully
// --------------------------------------------------------------------------------

class VerficationCompleted extends StatelessWidget {
  const VerficationCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animation/varification_complete.json',
                  repeat: false,
                  width: 300,
                  height: 300,
                ),
                const Text(
                  "Verification Completed\n",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Your email verification was successful, your account has been created, and now you can login using your new account.",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popAndPushNamed("/loginWithEmailPassword");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                    backgroundColor: const Color.fromARGB(255, 71, 140, 219),
                    foregroundColor: Colors.black,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue login",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------
// Page for forgeting Email password
// ---------------------------------

// Global Texediting controller for Forgot Password Textfeild so it can also be used by ForgotPasswordHoldPage
late TextEditingController _forgotPasswordController;

class ForgotEmailPasswordPage extends StatefulWidget {
  const ForgotEmailPasswordPage({super.key});

  @override
  State<ForgotEmailPasswordPage> createState() =>
      _ForgotEmailPasswordPageState();
}

class _ForgotEmailPasswordPageState extends State<ForgotEmailPasswordPage> {
  // Creating Key for forgot password FormTextFeild()
  final GlobalKey<FormState> forgotpasswordKey = GlobalKey<FormState>();

  // variables
  String btnText = "Sent Forgot Password Link";

  // resent OTP Method
  void resentOTP() async {
    // send the fortgot passoword link
    bool result = await FirebaseAuthMethod.forgotEmailPassword(
      email: _forgotPasswordController.text,
      context: context,
    );

    if (result) {
      // Restarting the TImer again & and disabling the OTP resent btn
      if (mounted) {
        context.read<TimerAndRadioButtonProvider>().startTimer();
        context.read<TimerAndRadioButtonProvider>().changeForgotLinkBtnValue =
            false;
      }
    } else {
      return;
    }
  }

  // initlizing forgotpassword controllers
  @override
  void initState() {
    super.initState();
    _forgotPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: forgotpasswordKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Don't worray sometimes people can forgot too.enter your email and we will send you a password reset link.",
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormFeildWidget(
                    labelText: "E-mail",
                    obscureText: false,
                    prefixIcon: const Icon(Icons.email),
                    validator: FormValidator.emailValidator,
                    textEditingController: _forgotPasswordController,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //! Provider Selector is used
                      child: Selector<TimerAndRadioButtonProvider, bool>(
                        selector: (context, emailForgotLinkBtn) =>
                            emailForgotLinkBtn.forgotLinkBtbEnable,
                        builder: (context, value, child) {
                          return ElevatedButton(
                            // Method that call resent OTP
                            onPressed: () async {
                              // storeing interent state in veriable
                              bool isInternet =
                                  await InternetChecker.checkInternet();

                              // If Form Validation get completed only then call the forgot link method
                              if (forgotpasswordKey.currentState!.validate() &&
                                  context.mounted) {
                                // if there is not internet
                                if (isInternet) {
                                  SnackBars.normalSnackBar(
                                      context, "Please turn on your Internet");
                                }
                                // if Internet connection is avaible
                                else if (!isInternet && context.mounted) {
                                  if (context
                                      .read<TimerAndRadioButtonProvider>()
                                      .forgotLinkBtbEnable) {
                                    resentOTP();
                                  }
                                  // else return nothing
                                  else {
                                    return;
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: context
                                      .read<TimerAndRadioButtonProvider>()
                                      .forgotLinkBtbEnable
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 184, 181, 181),
                              foregroundColor: Colors.black,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              btnText,
                              style: TextStyle(
                                color: context
                                        .read<TimerAndRadioButtonProvider>()
                                        .forgotLinkBtbEnable
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        },
                      )),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const Text(" sec")
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
