import 'package:flutter/material.dart';
import 'package:firebase_authentication/helper/form_validators.dart';
import 'package:firebase_authentication/pages/auth%20pages/all_login_sign_up_page.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:firebase_authentication/widgets/button_widget.dart';
import 'package:firebase_authentication/widgets/textformfeild_widget.dart';
import 'package:provider/provider.dart';

class LoginWithEmailPassword extends StatefulWidget {
  const LoginWithEmailPassword({super.key});

  @override
  State<LoginWithEmailPassword> createState() => _LoginWithEmailPasswordState();
}

class _LoginWithEmailPasswordState extends State<LoginWithEmailPassword> {
  // Creating Key for From Widget
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  // Creating TextEditing Controller's
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // disposing TextEditingController's
  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  // Method for login user
  void loginUser() {
    FirebaseAuthMethod.singInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        if (!value) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return const AllSignUpAndLoginPage();
              },
            ),
            ModalRoute.withName('/AllSignUpAndLoginPage'),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      "assets/images/Email_logo.png",
                      scale: 0.5,
                    ),

                    const SizedBox(height: 25),

                    // app name
                    const Text(
                      "F I R E B A S E    A U T H E N T I C A T I O N",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // email textfeild
                    TextFormFeildWidget(
                      labelText: "Email",
                      obscureText: false,
                      validator: FormValidator.emailValidator,
                      textEditingController: _emailController,
                    ),

                    const SizedBox(height: 10),

                    // password textfeild
                    //! Provider Selector is used
                    Selector<TimerAndRadioButtonProvider, bool>(
                      selector: (context, password) => password.showPassword,
                      builder: (context, value, child) {
                        return TextFormFeildWidget(
                          labelText: "Password",
                          obscureText: value,
                          suffixIcon: IconButton(
                            icon: Icon(value
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              context
                                  .read<TimerAndRadioButtonProvider>()
                                  .showPasswordMethod();
                            },
                          ),
                          validator: FormValidator.passwordValidator,
                          textEditingController: _passwordController,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // forgot password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Sizebox is used to set the alignment of checkbox
                            SizedBox(
                              width: 26,
                              height: 24,
                              child:
                                  //! Provider Selector is used
                                  Selector<TimerAndRadioButtonProvider, bool>(
                                selector: (context, raidoValue) =>
                                    raidoValue.isChecked,
                                builder: (BuildContext context, value,
                                    Widget? child) {
                                  return Checkbox(
                                    value: value,
                                    onChanged: (value) {
                                      context
                                          .read<TimerAndRadioButtonProvider>()
                                          .isCheckedMethod();
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Remember me",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/ForgotEmailPasswordPage");
                          },
                          child: const Text(
                            "Forgot Password ?",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // sign in button
                    ButtonWidget(
                      onTap: () {
                        // Method that call all textfiled validator method
                        _loginFormKey.currentState!.validate();
                        // If Form Validation get completed only then call the Login() method
                        if (_loginFormKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      color: Colors.red[400]!,
                      image: "assets/images/Email_logo.png",
                      text: "Email/Password Login",
                    ),

                    const SizedBox(height: 20),

                    // don't have an account ? Register here
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("You don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed("/signUpWithEmailPassword");
                          },
                          child: const Text(
                            "Register Here",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
