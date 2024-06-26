import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
      inversePrimary: Colors.grey.shade500,
      outline: const Color.fromARGB(255, 138, 136, 136),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.grey[300],
          displayColor: Colors.white,
        ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionColor: Color.fromARGB(255, 78, 125, 148),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(circularTrackColor: Colors.white));
