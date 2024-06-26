import 'package:flutter/material.dart';
import 'package:firebase_authentication/pages/auth%20pages/all_login_sign_up_page.dart';
import 'package:firebase_authentication/services/auth/firebase_auth_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method for fetching current Provider user Data
  Future<Map<String, dynamic>?> getUserData() async {
    // creating instace of Shared Preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // creating Map of UserData so we can return to the FutureBuilder as Map.
    Map<String, dynamic> data = {
      "name": prefs.getString('name'),
      "userName": prefs.getString('userName'),
      "email": prefs.getString('email'),
      "phoneNumber": prefs.getString('phoneNumber'),
      "imageUrl": prefs.getString('imageUrl'),
      "provider": prefs.getString('provider'),
      "userID": prefs.getString('userID'),
    };
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          // varible for snapShot data
          var data = snapshot.data ?? {"data": "null"};
          var name = data["name"];
          var userName = data["userName"];
          var email = data["email"];
          var phoneNumber = data["phoneNumber"];
          var imageUrl = data["imageUrl"];
          var userID = data["userID"];
          var provider = data["provider"];

          // snapshot begin loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // If snapshot has Data
          else {
            return Scaffold(
              appBar: AppBar(
                leading: const Text(""),
                backgroundColor: Colors.deepPurple[200],
                title: const Text("H O M E   P A G E"),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      // calling singOut method
                      await FirebaseAuthMethod.singOut(context: context);

                      // redirecting user to AllSignUpAndLoginPage
                      if (context.mounted) {
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
                    icon: const Icon(Icons.logout),
                  )
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // If values's are null then reuturn empty SizedBox.shrink() else show data In Text() widget
                    imageUrl == "empty"
                        ? const SizedBox.shrink()
                        : ClipOval(
                            child: Image.network(
                              height: 110,
                              width: 110,
                              fit: BoxFit.contain,
                              imageUrl,
                            ),
                          ),

                    email == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("Email : $email",
                                style: const TextStyle(fontSize: 16)),
                          ),

                    phoneNumber == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("phoneNumber : $phoneNumber",
                                style: const TextStyle(fontSize: 16)),
                          ),

                    name == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("Name : $name",
                                style: const TextStyle(fontSize: 16)),
                          ),

                    userName == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("userName : $userName",
                                style: const TextStyle(fontSize: 16)),
                          ),

                    userID == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("User ID: $userID",
                                style: const TextStyle(fontSize: 16)),
                          ),

                    provider == "empty"
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text("Provider: $provider",
                                style: const TextStyle(fontSize: 16)),
                          ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
