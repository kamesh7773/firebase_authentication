import 'package:flutter/material.dart';
import 'package:intl_phone_field2/intl_phone_field.dart';
import 'package:firebase_authentication/pages/auth%20pages/all_login_sign_up_page.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:firebase_authentication/widgets/button_widget.dart';

class PhoneVarifcation extends StatefulWidget {
  const PhoneVarifcation({super.key});

  @override
  State<PhoneVarifcation> createState() => _PhoneVarifcationState();
}

class _PhoneVarifcationState extends State<PhoneVarifcation> {
  // Creating Key for From Widget
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();

  // Creating TextEditing Controller's
  final TextEditingController _phoneNumberController = TextEditingController();

  // varibles
  String countryCode = "91";

  // Method for login user
  void phoneNumberLogin() {
    FirebaseAuthMethod.loginWithPhoneNumber(
      phoneNumber: _phoneNumberController.text.trim(),
      countryCode: countryCode,
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
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _phoneFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      "assets/images/Phone_logo.png",
                      scale: 0.5,
                      color: Colors.black,
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

                    // Phone Number Textfeild
                    IntlPhoneField(
                      initialCountryCode: "IN",
                      invalidNumberMessage: "Please enter valid number",
                      autofocus: true,
                      decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(
                              color: Colors.black, fontSize: 15),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 46, 46, 46),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          )),
                      controller: _phoneNumberController,
                      onCountryChanged: (country) {
                        // initlizing coutray code
                        countryCode = country.dialCode;
                      },
                      validator: (p0) {
                        if (p0!.number.isEmpty) {
                          return "Please enter a number";
                        }
                        // validating Phone number
                        else if (!RegExp(
                                r"^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}$")
                            .hasMatch(p0.number)) {
                          return "Please enter valid number";
                        }

                        // else return nothing
                        else {
                          return null;
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    // sign in button
                    ButtonWidget(
                      onTap: () {
                        //! Handling validation of "intl_phone_number_field" package is little bit diffrent then FormTextfeild() widget

                        // If Phone Number feild is not validated then...
                        if (_phoneFormKey.currentState!.validate() == false) {
                          // clog.warning("Not valited");
                          return;
                        }
                        // if Phone Textfield is empty then return nothing..
                        if (_phoneNumberController.text.isEmpty) {
                          // clog.warning("Phone Feild is empty please enter Number");
                          return;
                        }
                        // if phoneFeild is validated & Text feild is notEmpty then only run the PhoneLogin function
                        if (_phoneFormKey.currentState!.validate() == true &&
                            _phoneNumberController.text.isNotEmpty) {
                          // clog.warning(countryCode + _phoneNumberController.text);
                          phoneNumberLogin();
                        }
                      },
                      color: Colors.greenAccent,
                      image: "assets/images/Phone_logo.png",
                      text: "Phone Number Sign in",
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
