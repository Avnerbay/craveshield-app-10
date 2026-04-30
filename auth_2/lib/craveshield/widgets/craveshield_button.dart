import 'package:flutter/material.dart';

import '../theme/craveshield_colors.dart';

class CraveShieldButton extends StatelessWidget {
  const CraveShieldButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70, width: 1.4),
            shape: shape,
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: .2,
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor:
              CraveShieldColors.disabled.withValues(alpha: .55),
          disabledForegroundColor: Colors.white70,
          backgroundColor: Colors.white,
          foregroundColor: CraveShieldColors.blue,
          elevation: onPressed == null ? 0 : 4,
          shadowColor: Colors.black26,
          shape: shape,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: .2,
          ),
        ),
        child: child,
      ),
    );
  }
}
