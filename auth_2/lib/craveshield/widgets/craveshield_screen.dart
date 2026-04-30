import 'package:flutter/material.dart';

import '../theme/craveshield_colors.dart';

class CraveShieldScreen extends StatelessWidget {
  const CraveShieldScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
    this.safeArea = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            CraveShieldColors.brightBlue,
            CraveShieldColors.blue,
            CraveShieldColors.navy,
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    return Scaffold(
      backgroundColor: CraveShieldColors.navy,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: safeArea ? SafeArea(child: content) : content,
          ),
        ),
      ),
    );
  }
}
