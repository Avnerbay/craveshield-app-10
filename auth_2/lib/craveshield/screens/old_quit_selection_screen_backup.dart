import 'package:flutter/material.dart';

import '../theme/craveshield_colors.dart';
import '../widgets/craveshield_back_button.dart';
import '../widgets/craveshield_screen.dart';
import 'dashboard_placeholder_screen.dart';

class OldQuitSelectionScreenBackup extends StatelessWidget {
  const OldQuitSelectionScreenBackup({super.key});

  static const routeName = 'oldQuitSelectionBackup';
  static const routePath = '/old-quit-selection-backup';

  @override
  Widget build(BuildContext context) {
    return CraveShieldScreen(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CraveShieldBackButton(),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'What are you quitting?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select one to personalize your journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _AddictionTile(
                    label: 'Cigarette/Vape',
                    icon: Icons.smoke_free_rounded,
                    onTap: () => Navigator.of(context).pushNamed(
                      CraveDashboardPlaceholderScreen.routePath,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _AddictionTile(
                    label: 'Alcohol',
                    icon: Icons.no_drinks_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  _AddictionTile(
                    label: 'Sugar/Carbs',
                    icon: Icons.no_food_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 14),
                  _AddictionTile(
                    label: 'Cannabis',
                    icon: Icons.spa_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          NavigationBar(
            selectedIndex: 0,
            height: 72,
            backgroundColor: Colors.white,
            indicatorColor: CraveShieldColors.sky.withValues(alpha: .25),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddictionTile extends StatelessWidget {
  const _AddictionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CraveShieldColors.sky.withValues(alpha: .2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: CraveShieldColors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: CraveShieldColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: CraveShieldColors.muted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
