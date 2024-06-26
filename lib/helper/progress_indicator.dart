import 'package:flutter/material.dart';

class ProgressIndicators {
  static void showProgressIndicator(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const PopScope(
          canPop: true, // Please set this to false once you debug your code
          child: Center(
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        );
      },
    );
  }
}
