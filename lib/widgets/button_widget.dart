import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final void Function() onTap;
  final String image;
  final String text;
  final Color color;
  const ButtonWidget({
    super.key,
    required this.onTap,
    required this.text,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                image,
                width: 60,
                height: 30,
                fit: BoxFit.contain,
              ),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(""),
            ],
          ),
        ),
      ),
    );
  }
}
