import 'package:flutter/material.dart';

class TextFormFeildWidget extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final Widget? prefix;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController textEditingController;

  const TextFormFeildWidget({
    super.key,
    required this.obscureText,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    required this.labelText,
    this.validator,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        prefix: prefix,
        labelText: labelText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
    );
  }
}
