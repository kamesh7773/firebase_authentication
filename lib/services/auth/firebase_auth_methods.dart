import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_authentication/helper/internet_checker.dart';
import 'package:firebase_authentication/helper/progress_indicator.dart';
import 'package:firebase_authentication/pages/auth%20pages/Email%20auth/email_otp_page.dart';
import 'package:firebase_authentication/pages/auth%20pages/Phone%20auth/phone_otp_page.dart';
import 'package:firebase_authentication/services/auth/email_otp_auth_methods.dart';
import 'package:firebase_authentication/helper/firebase_auth_error_snackbar.dart';

class FirebaseAuthMethod {
  // varible related Firebase instance related
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // variable's for Email Auth
  static late String _emailOtpHashKey;

  // creating getter for _emailOtpHashKey veriable so it can be read by EmailOTP Page also
  // (makeing EmailverficationId id getter so it can be read by phoneOTP Page so when we resend the OTP then vericationID also genrated new so we have to pass again to
  //  OTP Page by Consturtor so if we do that again then Because we already present on OTP Page so OTP Page will again will redirected (Pop to user) and we don't wnat that)
  static String get emailHash => _emailOtpHashKey;

  // variable's for Phone Auth
  static late String _phoneOtpVerficationID;

  // creating getter for verficationID  veriable so it can be read by PhoneOTP Page also
  // (makeing verficationId id getter so it can be read by phoneOTP Page so when we resend the OTP then vericationID also genrated new so we have to pass again to
  //  OTP Page by Consturtor so if we do that again then Because we already present on OTP Page so OTP Page will again will redirected (Pop to user) and we don't wnat that)
  static String get phoneotpVerficatoinID => _phoneOtpVerficationID;

  // ---------------------------
  // Method's Related Email Auth
  // ---------------------------

  //! Email & Password SignUp Method
  static Future<void> signUpWithEmail({
    required String fname,
    required String lname,
    required String userName,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    //? Try & catch block for checking email address already present & its provider is "Email & Password" in Firebase "users" collection.
    try {
      // showing Progress Indigator
      ProgressIndicators.showProgressIndicator(context);
      //* 1st We check if the entered email address already present & its provider is "Email & Password" in "users" collection
      //* by querying FireStore's "users" Collection.
      // searching for Email Address & "Email & Password" provider in "users" collection at once
      QuerySnapshot queryForEmailAndProvider = await _db
          .collection('users')
          .where("email", isEqualTo: email)
          .where("provider", isEqualTo: "Email & Password")
          .get();

      // if the entered Email address already present in "users" collection and Provider is "Email & Password"
      // it's means that entered email is already have account in Fireabase.
      if (queryForEmailAndProvider.docs.isNotEmpty && context.mounted) {
        Navigator.of(context).pop();
        SnackBars.normalSnackBar(
          context,
          "The email address is already in use by another account.",
        );
      }
      // if the entered Email address is not present in "users" collection or Entered email is present in "users" collection but
      // provider is not "Email & password" only then...
      else {
        if (context.mounted) {
          //* 2nd sentOTP Method get called.
          //? Try & catch block for sending OTP to user Email Address.
          try {
            var res = await EmailAuth.sendEmail(email: email);
            _emailOtpHashKey = res['data'];
            // Poping out Progress Indicator
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
          //? Handling E-mail OTP error's
          catch (error) {
            if (error ==
                "ClientException with SocketException: Failed host lookup: 'direct-robbi-kamesh-cc8a724a.koyeb.app' (OS Error: No address associated with hostname, errno = 7), uri=https://direct-robbi-kamesh-cc8a724a.koyeb.app/otp-login") {
              if (context.mounted) {
                // poping out the progress indicator
                Navigator.pop(context);
                SnackBars.normalSnackBar(
                    context, "Please turn on your Internet");
              }
            } else {
              if (context.mounted) {
                // poping out the progress indicator
                Navigator.pop(context);
                SnackBars.normalSnackBar(context, error.toString());
              }
            }
          }

          //* 3rd after sending OTP we redirect user to Email OTP PAGE
          //*     (we are also sending the fname , lname , userName & password to OTP Page so when verifyOTP method get called then we pass these value to verfiyOTP method because
          //*      verifyOTP Method also responsible for storeing userForm Data in FireStore DB. You will be thinking why we are passing these information to OTP page then we again
          //*      pass this info to verifyOTP method why taking too much hustle ? why don't we simply store userForm info into some varible and use them ? because we cannot do this
          //*      when verfy otp method get called from OTP page then FirebaseAUthMethod called also called when we try to store user form data into varibale and when we use these
          //*      variables then these varible only contains null values.)
          // storeing interent state in veriable
          bool isInternet = await InternetChecker.checkInternet();
          // if Internet connection is Not presented then..
          if (isInternet && context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          }
          // if Internet connect is presented then..
          else if (!isInternet && context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return EmailOtpPage(
                  email: email,
                  firstName: fname,
                  lastName: lname,
                  userName: userName,
                  password: password,
                );
              },
            ));
          }
        }
      }
    }
    //? Handling Exceptions of  email address already present & its provider is "Email & Password" in Firebase "users" collection.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        // Navigator.pop(context);
        Navigator.popUntil(
            context, ModalRoute.withName("/signUpWithEmailPassword"));
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          // Navigator.pop(context);
          Navigator.popUntil(
              context, ModalRoute.withName("/signUpWithEmailPassword"));
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  //! Verifying Email OTP & if OTP get succesfully get verfied then create user account on firebase and store user info on FireStore DB
  static Future<void> verifyEmailOTP({
    required email,
    required emailOtpHash,
    required emailOTP,
    required firstName,
    required lastName,
    required userName,
    required password,
    required BuildContext context,
  }) async {
    try {
      ProgressIndicators.showProgressIndicator(context);
      //! Method that verify Email OTP
      var res = await EmailAuth.verifyOtp(
        email: email,
        hash: emailOtpHash,
        otp: emailOTP,
      );
      if (context.mounted) {
        Navigator.pop(context);
      }
      //* 4th if user get verifed with Email OTP then we create thier account on Firebase Auth & Save the User Info on Fireabase Store
      if (res["message"] == "OTP Verified") {
        //? Try & catch block for (creating the user account with Email-Password and storing user info at firebase auth server)
        try {
          // creating user account on Firebase auth
          await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // storing user's auth data into "users" collection in FireStore for storing user spefic data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": "$firstName $lastName",
            "userName": userName,
            "email": email,
            "phoneNumber": "empty",
            "imageUrl":
                "https://img.freepik.com/vektoren-premium/maenner-symbol-trendiger-avatar-charakter-froehliche-glueckliche-menschen-flachbild-vector-illustration-runder-rahmen-maennerportraits-gruppe-team-entzueckende-jungs-isoliert-auf-weissem-hintergrund_275421-281.jpg",
            "provider": "Email & Password",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          //* 5th Redircting user to Verification completed Screen.
          if (context.mounted) {
            Navigator.of(context).pushNamed("/VerficationCompleted");
          }
        }

        //? handling createUserWithEmailAndPassword & Storing user info at firebase.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            // Navigator.pop(context);
            Navigator.popUntil(
                context, ModalRoute.withName("/signUpWithEmailPassword"));
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              // Navigator.pop(context);
              Navigator.popUntil(
                  context, ModalRoute.withName("/signUpWithEmailPassword"));
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }
      } else if (res["data"] == "Invalid OTP" && context.mounted) {
        SnackBars.normalSnackBar(context, "Invalid OTP");
      } else if (res["data"] == "OTP Expired" && context.mounted) {
        SnackBars.normalSnackBar(context, "OTP Expired");
      }
    }
    //? Handling E-mail OTP error's
    catch (error) {
      if (error ==
          "ClientException with SocketException: Failed host lookup: 'direct-robbi-kamesh-cc8a724a.koyeb.app' (OS Error: No address associated with hostname, errno = 7), uri=https://direct-robbi-kamesh-cc8a724a.koyeb.app/_emailOtp-login") {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, "Please turn on your Internet");
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, error.toString());
        }
      }
    }
  }

  //! Resend OTP on Email Method
  static Future<void> emailAuthResentOTP(
      {required email, required BuildContext context}) async {
    try {
      // Showing the progress Indicator
      ProgressIndicators.showProgressIndicator(context);
      var res = await EmailAuth.sendEmail(email: email);
      // Poping of the Progress Indicator
      if (context.mounted) {
        Navigator.pop(context);
      }
      _emailOtpHashKey = res['data'];
    }
    //? Handling E-mail OTP error's
    catch (error) {
      if (error ==
          "ClientException with SocketException: Failed host lookup: 'direct-robbi-kamesh-cc8a724a.koyeb.app' (OS Error: No address associated with hostname, errno = 7), uri=https://direct-robbi-kamesh-cc8a724a.koyeb.app/otp-login") {
        if (context.mounted) {
          // poping out the progress indicator
          SnackBars.normalSnackBar(context, "Please turn on your Internet");
        }
      } else {
        if (context.mounted) {
          // poping out the progress indicator
          SnackBars.normalSnackBar(context, error.toString());
        }
      }
    }
  }

  //! Email & Password Login Method
  static Future<void> singInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // showing CircularProgressIndicator
      ProgressIndicators.showProgressIndicator(context);

      // Method for sing in user with email & password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // fetching current userId info from "users" collection.
      final currentUserInfo =
          await _db.collection("users").doc(_auth.currentUser!.uid).get();

      final userData = currentUserInfo.data();

      // creating instace of Shared Preferences.
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // writing current User info data to SharedPreferences.
      await prefs.setString("name", userData!["name"]);
      await prefs.setString("userName", userData["userName"]);
      await prefs.setString("email", userData["email"]);
      await prefs.setString("phoneNumber", userData["phoneNumber"]);
      await prefs.setString("imageUrl", userData["imageUrl"]);
      await prefs.setString("provider", userData["provider"]);
      await prefs.setString("userID", userData["userID"]);

      // setting isLogin to "true"
      await prefs.setBool('isLogin', true);

      // After login successfully redirecting user to HomePage
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.of(context).popAndPushNamed("/HomePage");
      }
    }
    // Handling Login auth Exceptions
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else if (error.message ==
              "The supplied auth credential is incorrect, malformed or has expired." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Invaild email or password");
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  //! Email & Password ForgorPassword/Reset Method
  static Future<bool> forgotEmailPassword({
    required String email,
    required BuildContext context,
  }) async {
    // variable declartion
    late bool associatedEmail;
    try {
      // showing Progress Indigator
      ProgressIndicators.showProgressIndicator(context);
      //* 1st We check if the entered email address already present & its provider is "Email & Password" in "users" collection
      //* by querying FireStore's "users" Collection.
      // searching for Email Address & "Email & Password" provider in "users" collection at once
      QuerySnapshot queryForEmailAndProvider = await _db
          .collection('users')
          .where("email", isEqualTo: email)
          .where("provider", isEqualTo: "Email & Password")
          .get();

      // if the entered Email address already present in "users" collection and Provider is "Email & Password"
      // it's means that user is entered corrent email address it's mean we can send that Forgot password link to user Email Address.
      if (queryForEmailAndProvider.docs.isNotEmpty && context.mounted) {
        // Method for sending forgot password link to user
        await _auth.sendPasswordResetEmail(email: email);
        // Poping of the Progress Indicator
        if (context.mounted) {
          Navigator.pop(context);
        }
        // Redirect user to ForgotPasswordHoldPage
        if (context.mounted) {
          SnackBars.normalSnackBar(
              context, "Forgot Password Link sended to your Email address");
        }

        associatedEmail = true;
      }
      // if the entered Email address is not present in "users" collection or Entered email Provider is not "Email & Password" is present in "users" collection
      // that means user entered Email does not have associat account in Firebase realted to "Email & Password" Provider.
      else {
        if (context.mounted) {
          // Poping of the Progress Indicator
          Navigator.of(context).pop();

          SnackBars.normalSnackBar(
            context,
            "There is no associated account found with entered Email.",
          );
        }
        associatedEmail = false;
      }
    }
    // Handling forgot password auth Exceptions
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else if (error.message ==
              "The supplied auth credential is incorrect, malformed or has expired." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Invaild email");
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }

    // returning email value
    return associatedEmail;
  }

  // ---------------------------
  // Method's Related Phone Auth
  // ---------------------------

  // ! Method that send OTP to user's PhoneNumber and Redirect Them to OTP Screen
  static Future<void> loginWithPhoneNumber({
    required phoneNumber,
    required countryCode,
    required BuildContext context,
  }) async {
    //? Try & catch block for Phone verification for Android & IOS only
    try {
      // showing circular progress Indicator
      ProgressIndicators.showProgressIndicator(context);

      //* 1st Send OTP Method get called that sends the OTP to user
      await _auth.verifyPhoneNumber(
        // asigning textfeild Phone number to phonenumber propertie (It it very IMP to add "+" before county code)
        phoneNumber: "+$countryCode$phoneNumber",

        // if varfication get completed then we run our own login
        verificationCompleted: (PhoneAuthCredential credential) async {},

        //! handling send OTP error (in this we don't have to use on FirebaseAuthException )
        verificationFailed: (e) {
          if (e.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            Navigator.of(context).pop();
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            Navigator.of(context).pop();
            SnackBars.normalSnackBar(context, e.message!);
          }
        },

        //? It is very imp to set timeout to zero if are usieng "SMS User Consent API" for OTP Autofill.
        //? otherwise application will get crashed everyTime when OTP arrived.
        timeout: const Duration(seconds: 0),

        // codeSend : propertie method is sends the OTP to user device
        codeSent: ((String verificationId, int? resentToken) async {
          // Assigning OTP verfificaitonID to static veriable
          // (varfication ID is genrated uniquly for each OTP if they get match then OTP get verifed)
          _phoneOtpVerficationID = verificationId;

          //* 2nd After succesfully sending OTP to user we show OTP screen to user
          // poping of the progress indicator
          Navigator.of(context).pop();
          // redirecting user to OTP Page
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return PhoneNumberOtpPage(
                phoneNumber: phoneNumber,
                countryCode: countryCode,
              );
            },
          ));
        }),

        // if OTP got expired then we can run our own logic
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackBars.normalSnackBar(context, e.toString());
      }
    }
  }

  //! Method that verify's the user's PhoneNumber OTP
  static Future<void> verifyPhoneOTP({
    required countryCode,
    required phoneNumber,
    required verificationID,
    required otp,
    required BuildContext context,
  }) async {
    //? try & catch blcok for verifing Phone number OTP
    try {
      // showing circular progress Indicator
      ProgressIndicators.showProgressIndicator(context);

      //* 3rd OTP verfication method get called from OTP page, (This is the method that verfiy the OTP with VerficationID)
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: otp);

      //* 4th singIn the user with credential.
      await FirebaseAuth.instance.signInWithCredential(credential);

      //* 5th stroing user info inside the FireStore "users" collection.
      // ? Try & catch block for storing user info at Firestore in "users" collections
      try {
        // creating "users" collection so we can store user specific user data
        await _db.collection("users").doc(_auth.currentUser!.uid).set({
          "name": "empty",
          "userName": "empty",
          "email": "empty",
          "phoneNumber": "+$countryCode $phoneNumber",
          "imageUrl":
              "https://dayproof.com.au/wp-content/uploads/sites/5/2023/10/testimonial-1.png",
          "provider": "PhoneNumber",
          "userID": _auth.currentUser!.uid,
        }).then((value) {
          debugPrint("User data saved in Firestore users collection");
        }).catchError((error) {
          debugPrint("User data not saved!");
        });

        // fetching current userId info from "users" collection.
        final currentUserInfo =
            await _db.collection("users").doc(_auth.currentUser!.uid).get();

        final userData = currentUserInfo.data();

        // creating instace of Shared Preferences.
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        //* 6th writing current User info data to SharedPreferences.
        await prefs.setString("name", userData!["name"]);
        await prefs.setString("userName", userData["userName"]);
        await prefs.setString("email", userData["email"]);
        await prefs.setString("phoneNumber", userData["phoneNumber"]);
        await prefs.setString("imageUrl", userData["imageUrl"]);
        await prefs.setString("provider", userData["provider"]);
        await prefs.setString("userID", userData["userID"]);

        //* 7th setting isLogin to "true"
        await prefs.setBool('isLogin', true);
      }

      //? Handling Excetion for Storing user info at FireStore DB.
      on FirebaseAuthException catch (error) {
        if (error.message ==
                "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
            context.mounted) {
          SnackBars.normalSnackBar(context, "Please turn on your Internet");
        } else {
          if (context.mounted) {
            SnackBars.normalSnackBar(context, error.message!);
          }
        }
      }

      //* 8th After succresfully SingIn redirecting user to HomePage
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed("/HomePage");
      }
    } on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else if (error.message ==
              "The verification code from SMS/TOTP is invalid. Please check and enter the correct verification code again." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(
            context, "The verification OTP from SMS is invalid");
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  //! Methdo that resend the OTP to user's PhoneNumber
  static Future<void> phoneAuthResendOtp({
    required phoneNumber,
    required countryCode,
    required BuildContext context,
  }) async {
    //? Try & catch block for Phone verification for Android & IOS only
    try {
      // showing circular progress Indicator
      ProgressIndicators.showProgressIndicator(context);

      await _auth.verifyPhoneNumber(
        // asigning textfeild Phone number to phonenumber propertie (It it very IMP to add "+" before county code)
        phoneNumber: "+$countryCode$phoneNumber",

        // if varfication get completed then we run our own login
        verificationCompleted: (PhoneAuthCredential credential) async {},

        // handling send OTP error (in this we don't have to use on FirebaseAuthException )
        verificationFailed: (e) {
          if (e.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            Navigator.of(context).pop();
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            Navigator.of(context).pop();
            SnackBars.normalSnackBar(context, e.message!);
          }
        },

        //? it is very imp to set timeout to zero if are usieng "SMS User Consent API" for OTP Autofill.
        //? otherwise application will get crashed.d
        timeout: const Duration(seconds: 0),

        // codeSend : propertie method is sends the OTP to user device
        codeSent: ((String verificationId, int? resentToken) async {
          // showing user to OTP screen diologBox
          // (varfication ID is genrated uniquly for each OTP if they get match then OTP get verifed)
          _phoneOtpVerficationID = verificationId;

          // poping out the progress indicator after sending the OTP
          Navigator.of(context).pop();
        }),

        // if OTP got expired then we can run our own logic
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        SnackBars.normalSnackBar(context, e.toString());
      }
    }
  }

  // --------------------------------------
  // Method related Google Auth (OAuth 2.0)
  // --------------------------------------

  //! Method for Google SingIn/SignUp (For Google We don't have two method for signIn/signUp)
  static Future<void> signInWithGoogle({required BuildContext context}) async {
    try {
      //? ------------------------
      //? Google Auth code for Web
      //? ------------------------
      // (For runing Google Auth on Web Browser We need add the Web Clint ID (Web Clint ID is avaible on Google Clound Console
      //  Index.html file ex : <meta name="google-signin-client_id" content="152173321595-lb4qla2alg7q3010hrip1p1i1ok997n9.apps.googleusercontent.com.apps.googleusercontent.com"> )
      //  Google Auth Only run on specific "Port 5000" for runing application ex : "flutter run -d edge --web-hostname localhost --web-port 5000"
      if (kIsWeb) {
        //* 1st creating googleProvider instance with help of GoogleAuthProvider class contructor
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        //* 2nd Provider that need some kind user google acocunt info for singIn purpopse.
        //*     There are multiple provider are there in google office web site you can check it out.
        googleProvider.addScope("email");

        //* 3rd this code pop the google signIn/signUp interface/UI like showing google id that is loged in user's browser
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        //* 4th stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredential.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": userCredential.additionalUserInfo!.profile!["email"],
            "phoneNumber": "empty",
            "imageUrl": userCredential.additionalUserInfo!.profile!["picture"],
            "provider": "Google",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 5th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 6th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 7th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }

        // if "userCredential.additionalUserInfo!.isNewUser" is "isNewUser" it's mean user account is not presented on our firebase signin
        // console it mean's user is being SingIn/SingUp with Google for fisrt time so we can store the information in fireStore "users" collection.
        // This code used to detected when user login with Google Provider for first time and we can run some kind of logic on in.

        // if (userCredential.additionalUserInfo!.isNewUser) {}
      }
      //? --------------------------------
      //? Google Auth code for Android/IOS
      //? --------------------------------
      else {
        //* 1st this code pop the google signIn/signUp interface/UI like showing google id that is loged in user's devices
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        //* 2nd When user clicks on the Pop Google Account then this code retirve the GoogleSignInTokenData (accesToken/IdToken)
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        // if accessToken or idToken null the return nothing. ( accessToken get null when user dismis the Google account Pop Menu)
        if (googleAuth?.accessToken == null && googleAuth?.idToken == null) {
          return;
        }
        // if accessToken and idToken is not null only then we process to login
        else {
          //* 3rd In upper code (2nd code ) we are ritrieving the "GoogleSignInTokenData" Instance (googleAuth) now with the help googleAuth instance we gonna
          //* retrive the "accessToken" and idToken
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );

          //* 4th This code help user to singIn/SingUp the user with Google Account.
          // when user click on the Popup google id's then this code will return all the User google account information
          // (Info like : Google account user name, user IMG, user email is verfied etc)
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          //* 5th stroing user info inside the FireStore "users" collection.
          // ? Try & catch block for storing user info at Firestore in "users" collections
          try {
            // creating "users" collection so we can store user specific user data
            await _db.collection("users").doc(_auth.currentUser!.uid).set({
              "name": userCredential.additionalUserInfo!.profile!["name"],
              "userName": "empty",
              "email": userCredential.additionalUserInfo!.profile!["email"],
              "phoneNumber": "empty",
              "imageUrl":
                  userCredential.additionalUserInfo!.profile!["picture"],
              "provider": "Google",
              "userID": _auth.currentUser!.uid,
            }).then((value) {
              debugPrint("User data saved in Firestore users collection");
            }).catchError((error) {
              debugPrint("User data not saved!");
            });

            // fetching current userId info from "users" collection.
            final currentUserInfo =
                await _db.collection("users").doc(_auth.currentUser!.uid).get();

            final userData = currentUserInfo.data();

            // creating instace of Shared Preferences.
            final SharedPreferences prefs =
                await SharedPreferences.getInstance();

            //* 6th writing current User info data to SharedPreferences.
            await prefs.setString("name", userData!["name"]);
            await prefs.setString("userName", userData["userName"]);
            await prefs.setString("email", userData["email"]);
            await prefs.setString("phoneNumber", userData["phoneNumber"]);
            await prefs.setString("imageUrl", userData["imageUrl"]);
            await prefs.setString("provider", userData["provider"]);
            await prefs.setString("userID", userData["userID"]);

            //* 7th setting isLogin to "true"
            await prefs.setBool('isLogin', true);
          }

          //? Handling Excetion for Storing user info at FireStore DB.
          on FirebaseAuthException catch (error) {
            if (error.message ==
                    "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
                context.mounted) {
              SnackBars.normalSnackBar(context, "Please turn on your Internet");
            } else {
              if (context.mounted) {
                SnackBars.normalSnackBar(context, error.message!);
              }
            }
          }

          //* 8th After succresfully SingIn redirecting user to HomePage
          if (context.mounted) {
            Navigator.of(context).pushNamed("/HomePage");
          }

          // if "userCredential.additionalUserInfo!.isNewUser" is "isNewUser" it's mean user account is not presented on our firebase signin
          // console it mean's user is being SingIn/SingUp with Google for fisrt time so we can store the information in fireStore "users" collection.
          // This code used to detected when user login with Google Provider for first time and we can run some kind of logic on in.

          // if (userCredential.additionalUserInfo!.isNewUser) {}
        }
      }
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        Navigator.pop(context);
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  // ----------------------------
  // Method related FaceBook Auth
  // ----------------------------

  //! Method for Facebook SingIn/SignUp
  static Future<void> signInwithFacebook(
      {required BuildContext context}) async {
    try {
      //* 1st this code pop the Facebook signIn/signUp page in browser On Android
      //* and if we are web app then open Pop-Up Facebook signIn/signUp interface/UI In web browser
      final LoginResult loginResult = await FacebookAuth.instance.login();

      //* 2nd When user get login after entering their login password then this code retirve the FacebookTokenData.
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // if accessToken or idToken null the return nothing.
      if (loginResult.accessToken == null) {
        return;
      }
      // if accessToken and idToken is not null only then we process to login
      else {
        //* 3rd this method singIn the user with credetial
        final UserCredential userCredentail =
            await _auth.signInWithCredential(facebookAuthCredential);

        //* 4th stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredentail.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": userCredentail.additionalUserInfo!.profile!["email"],
            "phoneNumber": "empty",
            "imageUrl": userCredentail.additionalUserInfo!.profile!["picture"]
                ["data"]["url"],
            "provider": "Facebook",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 5th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 6th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 7th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }
      }
    }

    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else if (error.message ==
              "[firebase_auth/account-exists-with-different-credential] An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address." &&
          context.mounted) {
        SnackBars.normalSnackBar(
            context, "The email address is already in use by another account.");
      } else {
        if (context.mounted) {
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  // ---------------------------
  // Method related Twitter Auth
  // ---------------------------

  //! Method for Twitter SingIn/SignUp
  static Future<void> singInwithTwitter({required BuildContext context}) async {
    try {
      //? --------------------------
      //? Twitter Auth code for Web
      //? --------------------------
      if (kIsWeb) {
        //* 1st creating twitterProvider instance with help of TwitterAuthProvider class construtor
        TwitterAuthProvider twitterProvider = TwitterAuthProvider();

        //* 2nd this code pop the Twitter signIn/signUp interface/UI in user's browser
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(twitterProvider);

        //* 3rd stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredential.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": userCredential.additionalUserInfo!.profile!["email"],
            "phoneNumber": "empty",
            "imageUrl": userCredential
                .additionalUserInfo!.profile!["profile_image_url_https"],
            "provider": "Twitter",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 4th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 5th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 6th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }
      }
      //? ---------------------------------
      //? Twitter Auth code for Android/IOS
      //? ---------------------------------
      else {
        //* 1st creating twitterProvider instance with help of TwitterAuthProvider class construtor
        TwitterAuthProvider twitterProvider = TwitterAuthProvider();

        //* 2nd this code pop the Twitter signIn/signUp interface/UI in user's browser
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithProvider(twitterProvider);

        //* 3rd stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredential.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": userCredential.additionalUserInfo!.profile!["email"],
            "phoneNumber": "empty",
            "imageUrl": userCredential
                .additionalUserInfo!.profile!["profile_image_url_https"],
            "provider": "Twitter",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 4th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 5th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 6th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }
      }
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  // --------------------------
  // Method related Github Auth
  // --------------------------
  //! Method for Github SingIn/SignUp
  static Future<void> signInWithGitHub({required BuildContext context}) async {
    try {
      //? ------------------------
      //? Github Auth code for Web
      //? ------------------------
      if (kIsWeb) {
        //* 1st creating githubProvider instance with help of TwitterAuthProvider class construtor
        GithubAuthProvider githubProvider = GithubAuthProvider();

        githubProvider.addScope('user:email');

        //* 2nd this code pop the Github signIn/signUp interface/UI in user's browserJ
        final UserCredential userCredential =
            await _auth.signInWithPopup(githubProvider);

        //! Method that fetch the user's Email by AccessToken by useing GitHub Api
        //! (The reasone for fetching email by AccessToken becuase "userCredential" is returning "email == null"
        //!  I don't know the exact reasone.)
        final url = Uri.https('api.github.com', 'user/emails');
        final response = await http.get(url, headers: {
          'Accept-Language': 'en-us',
          'Accept': 'application/json',
          'Authorization': 'token ${userCredential.credential!.accessToken}',
          'Accept-Encoding': 'gzip, deflate'
        });

        final mapData = jsonDecode(response.body);

        //* 3rd stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredential.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": mapData[0]["email"],
            "phoneNumber": "empty",
            "imageUrl":
                userCredential.additionalUserInfo!.profile!["avatar_url"],
            "provider": "GitHub",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 4th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 5th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 6th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }
      }
      //? --------------------------------
      //? Github Auth code for Android/IOS
      //? --------------------------------
      else {
        //* 1st creating githubProvider instance with help of TwitterAuthProvider class construtor
        GithubAuthProvider githubProvider = GithubAuthProvider();

        githubProvider.addScope('user:email');

        //* 2nd this code pop the Github signIn/signUp interface/UI in user's browser
        final UserCredential userCredential =
            await _auth.signInWithProvider(githubProvider);

        //! Method that fetch the user's Email by AccessToken by useing GitHub Api
        //! (The reasone for fetching email by AccessToken becuase "userCredential" is returning "email == null"
        //!  I don't know the exact reasone.)
        final url = Uri.https('api.github.com', 'user/emails');
        final response = await http.get(url, headers: {
          'Accept-Language': 'en-us',
          'Accept': 'application/json',
          'Authorization': 'token ${userCredential.credential!.accessToken}',
          'Accept-Encoding': 'gzip, deflate'
        });

        final mapData = jsonDecode(response.body);

        //* 3rd stroing user info inside the FireStore "users" collection.
        // ? Try & catch block for storing user info at Firestore in "users" collections
        try {
          // creating "users" collection so we can store user specific user data
          await _db.collection("users").doc(_auth.currentUser!.uid).set({
            "name": userCredential.additionalUserInfo!.profile!["name"],
            "userName": "empty",
            "email": mapData[0]["email"],
            "phoneNumber": "empty",
            "imageUrl":
                userCredential.additionalUserInfo!.profile!["avatar_url"],
            "provider": "GitHub",
            "userID": _auth.currentUser!.uid,
          }).then((value) {
            debugPrint("User data saved in Firestore users collection");
          }).catchError((error) {
            debugPrint("User data not saved!");
          });

          // fetching current userId info from "users" collection.
          final currentUserInfo =
              await _db.collection("users").doc(_auth.currentUser!.uid).get();

          final userData = currentUserInfo.data();

          // creating instace of Shared Preferences.
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          //* 4th writing current User info data to SharedPreferences.
          await prefs.setString("name", userData!["name"]);
          await prefs.setString("userName", userData["userName"]);
          await prefs.setString("email", userData["email"]);
          await prefs.setString("phoneNumber", userData["phoneNumber"]);
          await prefs.setString("imageUrl", userData["imageUrl"]);
          await prefs.setString("provider", userData["provider"]);
          await prefs.setString("userID", userData["userID"]);

          //* 5th setting isLogin to "true"
          await prefs.setBool('isLogin', true);
        }

        //? Handling Excetion for Storing user info at FireStore DB.
        on FirebaseAuthException catch (error) {
          if (error.message ==
                  "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
              context.mounted) {
            SnackBars.normalSnackBar(context, "Please turn on your Internet");
          } else {
            if (context.mounted) {
              SnackBars.normalSnackBar(context, error.message!);
            }
          }
        }

        //* 6th After succresfully SingIn redirecting user to HomePage
        if (context.mounted) {
          Navigator.of(context).pushNamed("/HomePage");
        }
      }
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  // ----------------------------
  // Method related Anonymos Auth
  // ----------------------------

  //! Method for Anonymos login
  static Future<void> singInAnonymously({required BuildContext context}) async {
    try {
      //* 1st This method singIn user Anonymously
      await _auth.signInAnonymously();

      //* 2th stroing user info inside the FireStore "users" collection.
      // ? Try & catch block for storing user info at Firestore in "users" collections
      try {
        // creating "users" collection so we can store user specific user data
        await _db.collection("users").doc(_auth.currentUser!.uid).set({
          "name": "Anonymous",
          "userName": "empty",
          "email": "empty",
          "phoneNumber": "empty",
          "imageUrl":
              "https://www.shutterstock.com/image-vector/default-avatar-profile-icon-social-600nw-1677509740.jpg",
          "provider": "Anonymous",
          "userID": _auth.currentUser!.uid,
        }).then((value) {
          debugPrint("User data saved in Firestore users collection");
        }).catchError((error) {
          debugPrint("User data not saved!");
        });

        // fetching current userId info from "users" collection.
        final currentUserInfo =
            await _db.collection("users").doc(_auth.currentUser!.uid).get();

        final userData = currentUserInfo.data();

        // creating instace of Shared Preferences.
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        //* 3rd writing current User info data to SharedPreferences.
        await prefs.setString("name", userData!["name"]);
        await prefs.setString("userName", userData["userName"]);
        await prefs.setString("email", userData["email"]);
        await prefs.setString("phoneNumber", userData["phoneNumber"]);
        await prefs.setString("imageUrl", userData["imageUrl"]);
        await prefs.setString("provider", userData["provider"]);
        await prefs.setString("userID", userData["userID"]);

        //* 4th setting isLogin to "true"
        await prefs.setBool('isLogin', true);
      }

      //? Handling Excetion for Storing user info at FireStore DB.
      on FirebaseAuthException catch (error) {
        if (error.message ==
                "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
            context.mounted) {
          SnackBars.normalSnackBar(context, "Please turn on your Internet");
        } else {
          if (context.mounted) {
            SnackBars.normalSnackBar(context, error.message!);
          }
        }
      }

      //* 3rd After succresfully SingIn redirecting user to HomePage
      if (context.mounted) {
        Navigator.of(context).pushNamed("/HomePage");
      }
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  // ------------------------------------
  // Method related Firebase Auth SingOut
  // ------------------------------------

  //! Method for SingOut Firebase Provider auth account
  static Future<void> singOut({required BuildContext context}) async {
    try {
      // Remove the entry's of Shared Preferences data.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('name');
      prefs.remove('email');
      prefs.remove('imageUrl');
      prefs.remove('userID');
      prefs.remove('provider');

      // seting isLogin to false.
      await prefs.setBool('isLogin', false);

      // SingOut code for Google SingIn/SingUp
      if (await GoogleSignIn().isSignedIn()) {
        // Sign out the user from google account
        GoogleSignIn().signOut();
      }
      // This method SignOut user from all firebase auth Provider's
      await _auth.signOut();
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message ==
              "A network error (such as timeout, interrupted connection or unreachable host) has occurred." &&
          context.mounted) {
        SnackBars.normalSnackBar(context, "Please turn on your Internet");
      } else {
        if (context.mounted) {
          SnackBars.normalSnackBar(context, error.message!);
        }
      }
    }
  }

  //! Method that check user is login or Not with any Provider.
  static Future<bool> isUserLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;
    return isLogin;
  }
}
