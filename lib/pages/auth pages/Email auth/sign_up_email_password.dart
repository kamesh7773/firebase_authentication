import 'package:flutter/material.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';
import 'package:firebase_authentication/helper/form_validators.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:firebase_authentication/widgets/button_widget.dart';
import 'package:firebase_authentication/widgets/textformfeild_widget.dart';
import 'package:provider/provider.dart';

class SignUpWithEmailPassword extends StatefulWidget {
  const SignUpWithEmailPassword({super.key});

  @override
  State<SignUpWithEmailPassword> createState() =>
      _SignUpWithEmailPasswordState();
}

class _SignUpWithEmailPasswordState extends State<SignUpWithEmailPassword> {
  // Creating Key for TextFromFeild()'s presents in SignUp Screen
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  // Creating TextEditing Controller's
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method for Register
  void signUpMethod() {
    FirebaseAuthMethod.signUpWithEmail(
      fname: _firstNameController.text.trim(),
      lname: _lastNameController.text.trim(),
      userName: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Form(
              key: _signUpFormKey,
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

                  Row(
                    children: [
                      // ----------------------------
                      // TextFormField for First Name
                      // ----------------------------
                      Expanded(
                        child: TextFormFeildWidget(
                          labelText: "First name",
                          obscureText: false,
                          validator: FormValidator.userNameValidator,
                          textEditingController: _firstNameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ----------------------------
                      // TextFormField for last Name
                      // ----------------------------
                      Expanded(
                        child: TextFormFeildWidget(
                          labelText: "Last name",
                          obscureText: false,
                          validator: FormValidator.userNameValidator,
                          textEditingController: _lastNameController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // -------------------
                  // UserName textfeild
                  // -------------------
                  TextFormFeildWidget(
                    labelText: "Username",
                    obscureText: false,
                    validator: FormValidator.userNameValidator,
                    textEditingController: _userNameController,
                  ),

                  const SizedBox(height: 10),

                  // ---------------
                  // email textfeild
                  // ---------------
                  TextFormFeildWidget(
                    labelText: "Email",
                    obscureText: false,
                    validator: FormValidator.emailValidator,
                    textEditingController: _emailController,
                  ),

                  const SizedBox(height: 10),

                  // ------------------
                  // password textfeild
                  // ------------------
                  //! Provider Selector is used
                  Selector<TimerAndRadioButtonProvider, bool>(
                    selector: (context, password) => password.showPassword,
                    builder: (context, value, child) {
                      return TextFormFeildWidget(
                        labelText: "Password",
                        obscureText: value,
                        suffixIcon: IconButton(
                          icon: Icon(
                              value ? Icons.visibility_off : Icons.visibility),
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

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      // Sizebox is used to set the alignment of checkbox
                      SizedBox(
                        width: 26,
                        height: 24,
                        //! Provider Selector is used
                        child: Selector<TimerAndRadioButtonProvider, bool>(
                          selector: (context, raidoValue) =>
                              raidoValue.isChecked,
                          builder:
                              (BuildContext context, value, Widget? child) {
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
                      const Text("I agree to "),
                      const Text(
                        "Privicy Policy ",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                      const Text("and "),
                      const Text(
                        "Term of use",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  // SignUp in button
                  ButtonWidget(
                    onTap: () {
                      // First we check the Form Validation
                      _signUpFormKey.currentState!.validate();

                      // if FormValidation is checked & Privicy Policy checkbox is not checked
                      if (_signUpFormKey.currentState!.validate() &&
                          !context
                              .read<TimerAndRadioButtonProvider>()
                              .isChecked) {
                        SnackBars.normalSnackBar(
                          context,
                          "Please accept the Privicy Policy & Term of use",
                        );
                      }

                      // If FormValidation is checked & Privicy Policy checkbox is also checked then only we fire the SignUP method.
                      if (_signUpFormKey.currentState!.validate() &&
                          context
                              .read<TimerAndRadioButtonProvider>()
                              .isChecked) {
                        signUpMethod();
                      }
                    },
                    color: Colors.red[400]!,
                    image: "assets/images/Email_logo.png",
                    text: "Email/Password Sign Up",
                  ),

                  const SizedBox(height: 20),

                  // don't have an account ? Register here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/loginWithEmailPassword");
                        },
                        child: const Text(
                          "Login Here",
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
    );
  }
}
