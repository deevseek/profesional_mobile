import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
