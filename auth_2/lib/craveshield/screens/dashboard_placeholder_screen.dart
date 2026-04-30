import 'package:flutter/material.dart';

import '../theme/craveshield_colors.dart';
import '../widgets/craveshield_screen.dart';

class CraveDashboardPlaceholderScreen extends StatelessWidget {
  const CraveDashboardPlaceholderScreen({super.key});

  static const routeName = 'craveDashboardPlaceholder';
  static const routePath = '/crave-dashboard-placeholder';

  @override
  Widget build(BuildContext context) {
    return CraveShieldScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smoke_free_rounded,
              color: CraveShieldColors.blue,
              size: 58,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Dashboard Coming Soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Cigarette/Vape journey selected.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
