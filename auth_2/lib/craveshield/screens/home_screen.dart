import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/crave_auth_session.dart';
import 'dashboard_placeholder_screen.dart';
import 'my_shield_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = 'craveHome';
  static const routePath = '/crave-home';

  Future<void> _selectAddiction(BuildContext context, String value) async {
    await CraveAuthSession.saveSelectedAddiction(value);

    if (!context.mounted) return;
    // TODO: Replace with the next onboarding/personalization route when it exists.
    Navigator.of(context).pushNamed(CraveDashboardPlaceholderScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03122D),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06265A),
                    Color(0xFF0E4FA8),
                    Color(0xFF062B6D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _HomeHeader(),
                            const SizedBox(height: 28),
                            const Text(
                              'What are you quitting?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 29,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Select one to personalize your journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 66),
                            _AddictionCard(
                              label: 'Cigarette/Vape',
                              iconAsset: 'assets/images/Subheading_(6).png',
                              iconContainerColor:
                                  const Color(0xFF7A2A12).withOpacity(0.55),
                              iconBorderColor: const Color(0xFFFF4B14),
                              gradient: const [
                                Color(0xFFFF4B14),
                                Color(0xFFF20707),
                              ],
                              onTap: () => _selectAddiction(
                                context,
                                'cigarette_vape',
                              ),
                            ),
                            const SizedBox(height: 20),
                            _AddictionCard(
                              label: 'Alcohol',
                              iconAsset: 'assets/images/Victory_(39).png',
                              iconContainerColor:
                                  const Color(0xFF8A5A00).withOpacity(0.55),
                              iconBorderColor: const Color(0xFFFFB000),
                              gradient: const [
                                Color(0xFFFFB000),
                                Color(0xFFFF7900),
                              ],
                              onTap: () => _selectAddiction(context, 'alcohol'),
                            ),
                            const SizedBox(height: 20),
                            _AddictionCard(
                              label: 'Sugar/Carbs',
                              iconAsset: 'assets/images/Victory_(42).png',
                              iconContainerColor:
                                  const Color(0xFF8A6A00).withOpacity(0.55),
                              iconBorderColor: const Color(0xFFFFD000),
                              gradient: const [
                                Color(0xFFFFD000),
                                Color(0xFFEF8700),
                              ],
                              onTap: () => _selectAddiction(
                                context,
                                'sugar_carbs',
                              ),
                            ),
                            const SizedBox(height: 20),
                            _AddictionCard(
                              label: 'Cannabis',
                              iconAsset:
                                  'assets/images/Add_a_little_bit_of_body_text_(28).png',
                              iconContainerColor:
                                  const Color(0xFF006B47).withOpacity(0.55),
                              iconBorderColor: const Color(0xFF00B86B),
                              gradient: const [
                                Color(0xFF00B86B),
                                Color(0xFF00864D),
                              ],
                              onTap: () =>
                                  _selectAddiction(context, 'cannabis'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const _HomeBottomNav(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HomeLogo(),
          SizedBox(width: 18),
          _MyShieldShortcut(),
        ],
      ),
    );
  }
}

class _HomeLogo extends StatelessWidget {
  const _HomeLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42F5FF).withValues(alpha: .28),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/images/craveshield_logo.svg',
        width: 56,
        height: 56,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _MyShieldShortcut extends StatefulWidget {
  const _MyShieldShortcut();

  @override
  State<_MyShieldShortcut> createState() => _MyShieldShortcutState();
}

class _MyShieldShortcutState extends State<_MyShieldShortcut> {
  bool _pressed = false;

  void _openShield() {
    Navigator.of(context).pushNamed(MyShieldScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .95 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _openShield();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/images/Victory_(55).png',
            height: 72,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _AddictionCard extends StatefulWidget {
  const _AddictionCard({
    required this.label,
    required this.iconAsset,
    required this.iconContainerColor,
    required this.iconBorderColor,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final Color iconContainerColor;
  final Color iconBorderColor;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  State<_AddictionCard> createState() => _AddictionCardState();
}

class _AddictionCardState extends State<_AddictionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.last.withValues(alpha: .30),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.iconContainerColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.iconBorderColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .16),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.iconAsset,
                          width: 30,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: 'Home',
            selected: true,
          ),
          _NavItem(
            index: 1,
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
          ),
          _NavItem(
            index: 2,
            icon: Icons.person_rounded,
            label: 'Profile',
          ),
          _NavItem(
            index: 3,
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool selected;

  Color _activeColor() {
    switch (index) {
      case 0:
        return const Color(0xFF2F80ED);
      case 1:
        return const Color(0xFF27AE60);
      case 2:
        return const Color(0xFFBB6BD9);
      case 3:
        return const Color(0xFFF2994A);
    }
    return const Color(0xFF2F80ED);
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _activeColor();
    final iconColor = selected ? activeColor : const Color(0xFFBDBDBD);
    final background =
        selected ? activeColor.withValues(alpha: .15) : Colors.transparent;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: selected ? activeColor : const Color(0xFFBDBDBD),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
