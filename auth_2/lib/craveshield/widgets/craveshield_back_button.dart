import 'package:flutter/material.dart';

class CraveShieldBackButton extends StatelessWidget {
  const CraveShieldBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        tooltip: 'Back',
        color: Colors.white.withValues(alpha: .86),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
