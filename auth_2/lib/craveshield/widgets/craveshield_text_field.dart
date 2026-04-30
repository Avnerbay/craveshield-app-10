import 'package:flutter/material.dart';

import '../theme/craveshield_colors.dart';

class CraveShieldTextField extends StatelessWidget {
  const CraveShieldTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.suffix,
    this.textInputAction,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: CraveShieldColors.ink,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        labelStyle: const TextStyle(
          color: CraveShieldColors.muted,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .75)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: CraveShieldColors.sky, width: 2),
        ),
      ),
    );
  }
}
