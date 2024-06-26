import 'package:flutter/material.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';
import 'package:firebase_authentication/helper/internet_checker.dart';

class AllSignUpAndLoginPage extends StatefulWidget {
  const AllSignUpAndLoginPage({super.key});

  @override
  State<AllSignUpAndLoginPage> createState() => _AllSignUpAndLoginPageState();
}

class _AllSignUpAndLoginPageState extends State<AllSignUpAndLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        title: const Text(
          "F I R E B A S E   A U T H E T I C A T I O N",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // -----------------------
              // E-Mail Password Sign UP
              // -----------------------
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/signUpWithEmailPassword");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Email_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Email/Password Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ---------------------
              // E-Mail Password Login
              // ---------------------
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/loginWithEmailPassword");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Email_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Email/Password Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --------------------
              // Phone Number Sign in
              // --------------------
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/PhoneVarifcation");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Phone_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Phone Number Sign in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --------------
              // Google Sign in
              // --------------
              GestureDetector(
                onTap: () async {
                  // storeing interent state in veriable
                  bool isInternet = await InternetChecker.checkInternet();

                  // if there is no interent then..
                  if (isInternet && context.mounted) {
                    SnackBars.normalSnackBar(
                        context, "Please turn on your Internet");
                  }
                  // if internet connection available
                  else {
                    if (context.mounted) {
                      // Google SignIn/SignUp Method
                      FirebaseAuthMethod.signInWithGoogle(context: context);
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Google_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Sign in with Google",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ----------------
              // Facebook Sign in
              // ----------------
              GestureDetector(
                onTap: () {
                  FirebaseAuthMethod.signInwithFacebook(context: context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(90, 143, 248, 1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Facebook_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Sign in with Facebook",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ---------------
              // Twitter Sign in
              // ---------------
              GestureDetector(
                onTap: () {
                  //! Method that SingInWithTwitter
                  FirebaseAuthMethod.singInwithTwitter(context: context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(29, 161, 242, 1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Twitter_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Sign in with Twitter",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // --------------
              // Github Sign in
              // --------------
              GestureDetector(
                onTap: () {
                  FirebaseAuthMethod.signInWithGitHub(context: context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 83, 80, 80),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Github_logo.png",
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Sign in with Github",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ----------------
              // Anonymos Sign in
              // ----------------
              GestureDetector(
                onTap: () {
                  FirebaseAuthMethod.singInAnonymously(context: context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 68, 196),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          "assets/images/Anonymous_logo.png",
                          color: Colors.white,
                          width: 60,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          "Anonymos Sign in",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(""),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
