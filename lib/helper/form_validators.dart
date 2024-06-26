//! This Class hold's All Form validators.

class FormValidator {
// -------------------------------
// Method for validating firstName
// -------------------------------

  static String? firstNameValidator(String? value) {
    // if textfield is Empty
    if (value!.isEmpty) {
      return "please enter first name";
    }
    // for UserName validation
    else if (!RegExp(r"^[a-zA-Z0-9]").hasMatch(value)) {
      return "Enter corrent first name";
    }
    // username must be no longer than 12 characters
    else if (RegExp(r"^.{15}").hasMatch(value)) {
      return "first name must be no longer than 15 characters";
    }
    // username should not contains special characters
    else if (RegExp(r"^(?=.*[#?!@$%^&*-+()/':;])").hasMatch(value)) {
      return "first name should not contains special characters";
    }
    // else return nothing
    else {
      return null;
    }
  }

// --------------------------------
// Method for validating secondname
// --------------------------------

  static String? secondNameValidator(String? value) {
    // if textfield is Empty
    if (value!.isEmpty) {
      return "please enter second name";
    }
    // for UserName validation
    else if (!RegExp(r"^[a-zA-Z0-9]").hasMatch(value)) {
      return "Enter corrent second name";
    }
    // username must be no longer than 12 characters
    else if (RegExp(r"^.{15}").hasMatch(value)) {
      return "second name must be no longer than 15 characters";
    }
    // username should not contains special characters
    else if (RegExp(r"^(?=.*[#?!@$%^&*-+()/':;])").hasMatch(value)) {
      return "second name should not contains special characters";
    }
    // else return nothing
    else {
      return null;
    }
  }

// ------------------------------
// Method for validating UserName
// ------------------------------

  static String? userNameValidator(String? value) {
    // if textfield is Empty
    if (value!.isEmpty) {
      return "please enter username";
    }
    // for UserName validation
    else if (!RegExp(r"^[a-zA-Z0-9]").hasMatch(value)) {
      return "Enter corrent username";
    }
    // username must be no longer than 12 characters
    else if (RegExp(r"^.{15}").hasMatch(value)) {
      return "username must be no longer than 15 characters";
    }
    // username should not contains special characters
    else if (RegExp(r"^(?=.*[#?!@$%^&*-+()/':;])").hasMatch(value)) {
      return "username should not contains special characters";
    }
    // else return nothing
    else {
      return null;
    }
  }

// ----------------------------
// Method for Validating E-mail
// ----------------------------

  static String? emailValidator(String? value) {
    // if textfield is Empty
    if (value!.isEmpty) {
      return "please enter a email";
      // RegExp for Email validation
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
        .hasMatch(value)) {
      return "Enter corrent email";
    }
    // else return nothing
    else {
      return null;
    }
  }

// ------------------------------
// Method for Validating Password
// ------------------------------

  static String? passwordValidator(String? value) {
    // If TextFeild is Empty
    if (value!.isEmpty) {
      return "Please enter a password";
    }

    // At least one upper case English letter
    // else if (!RegExp(r"^(?=.*[A-Z])").hasMatch(value)) {
    //   return "At least one upper case English letter";
    // }

    // At least one lower case English letter
    // else if (!RegExp(r"^(?=.*[a-z])").hasMatch(value)) {
    //   return "At least one lower case English letter";
    // }

    // At least one digit
    // else if (!RegExp(r"^(?=.*[0-9])").hasMatch(value)) {
    //   return "At least one digit,";
    // }

    // At least one special character
    // else if (!RegExp(r"^(?=.*[#?!@$%^&*-])")
    //     .hasMatch(value)) {
    //   return "At least one special character";
    // }

    // Minimum eight in length
    else if (!RegExp(r"^.{6}").hasMatch(value)) {
      return "Minimum six in length";
    }
    // else return nothing
    else {
      return null;
    }
  }

// ----------------------------------
// Method for Validating Phone Number
// ----------------------------------

  static String? phoneNumberValidator(String? value) {
    // if Textfield is empty
    if (value!.isEmpty) {
      return "Please enter a number";
    }
    // validating Phone number
    else if (!RegExp(r"^(?:(?:\+|0{0,2})91(\s*[\-]\s*)?|[0]?)?[789]\d{9}$")
        .hasMatch(value)) {
      return "Please enter valid number";
    }

    // else return nothing
    else {
      return null;
    }
  }

// ---------------------------
// Method for Validating OTP's
// ---------------------------

  static String? otpValidator(String? value) {
    // if Textfield is empty
    if (value!.isEmpty) {
      return "OTP required";
    }
    // if otp is lower then 6 digit's
    else if (value.length < 6) {
      return "Make sure all OTP fields are filled in";
    }
    // validating Phone number
    else if (!RegExp(r"^[0-9]{1,6}$").hasMatch(value)) {
      return "Only digit are allowed";
    }

    // else return nothing
    else {
      return null;
    }
  }
}
