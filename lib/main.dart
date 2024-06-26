import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_authentication/helper/user_login_or_not.dart';
import 'package:firebase_authentication/pages/auth%20pages/Phone%20auth/phone_varifcation.dart';
import 'package:firebase_authentication/pages/auth%20pages/Email%20auth/email_other_pages.dart';
import 'package:firebase_authentication/pages/auth%20pages/all_login_sign_up_page.dart';
import 'package:firebase_authentication/pages/home_page.dart';
import 'package:firebase_authentication/pages/auth%20pages/Email%20auth/login_with_email_password.dart';
import 'package:firebase_authentication/pages/auth%20pages/Email%20auth/sign_up_email_password.dart';
import 'package:firebase_authentication/providers/timer_and_checkmark_provider.dart';
import 'package:firebase_authentication/services/firebase_options.dart';                    
import 'package:provider/provider.dart';

void main() async {
  // code for firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Imp code for facebook signIn/singUp for flutter web app only
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "990641889469194",
      cookie: true,
      xfbml: true,
      version: "v13.0",
    );
  }

  // checking user is previously login or not.
  bool isLogin = await UserLoginStatus.isUserLogin();

  runApp(MyApp(isLogin: isLogin));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  const MyApp({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TimerAndRadioButtonProvider(),
        ),
      ],
      child: MaterialApp(
        initialRoute: "/",
        routes: {
          "/HomePage": (context) => const HomePage(),
          "/AllSignUpAndLoginPage": (context) => const AllSignUpAndLoginPage(),
          "/signUpWithEmailPassword": (context) =>
              const SignUpWithEmailPassword(),
          "/loginWithEmailPassword": (context) =>
              const LoginWithEmailPassword(),
          "/VerficationCompleted": (context) => const VerficationCompleted(),
          "/ForgotEmailPasswordPage": (context) =>
              const ForgotEmailPasswordPage(),
          "/PhoneVarifcation": (context) => const PhoneVarifcation(),
        },
        debugShowCheckedModeBanner: false,
        home: isLogin ? const HomePage() : const AllSignUpAndLoginPage(),
      ),
    );
  }
}
