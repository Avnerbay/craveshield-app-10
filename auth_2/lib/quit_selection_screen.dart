import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'craveshield/screens/my_shield_screen.dart';
import 'craveshield/screens/panic_button.dart';

/// Public name for the "What are you quitting today" screen.
class WhatAreYouQuittingScreen extends StatefulWidget {
  const WhatAreYouQuittingScreen({super.key});

  @override
  State<WhatAreYouQuittingScreen> createState() =>
      _WhatAreYouQuittingScreenState();
}

/// Backwards-compatible alias (existing routes/imports).
typedef QuitSelectionScreen = WhatAreYouQuittingScreen;

class _WhatAreYouQuittingScreenState extends State<WhatAreYouQuittingScreen>
    with TickerProviderStateMixin {
  int selectedIndex = 0;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  late final AnimationController _idlePulse;
  late final Animation<double> _idleCurve;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 20, end: 50).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _idlePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _idleCurve = CurvedAnimation(
      parent: _idlePulse,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _idlePulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061120),
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF073B8F), Color(0xFF0E4596)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: const Color(0xFF2F7BFF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 70,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 240,
                            height: 115,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00E5FF)
                                                  .withValues(alpha: 0.55),
                                              blurRadius:
                                                  _glowAnimation.value,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/craveshield_logo.svg',
                                      width: 105,
                                      height: 105,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -30,
                                  top: 44,
						child: AnimatedBuilder(
							animation: _idleCurve,
							builder: (context, child) {
								final pulse = 0.93 + 0.07 * _idleCurve.value;
								return Transform.scale(
									scale: pulse,
									child: Container(
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											boxShadow: [
												BoxShadow(
													color: Color(0xFFFF2200).withValues(alpha: 0.45 + 0.35 * _idleCurve.value),
													blurRadius: 16 + 16 * _idleCurve.value,
													spreadRadius: 2 + 5 * _idleCurve.value,
												),
											],
										),
									child: child,
								),
								);
							},
							child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MyShieldScreen(),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      'assets/images/my_shield_features/craveshield_logo_primary.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      isAntiAlias: true,
                                    ),
                                  ),
                                ),
							),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 200,
                left: 20,
                right: 20,
                child: PanicButton(),
              ),
              const Positioned(
                top: 264,
                left: 22,
                right: 22,
                child: Text(
                  'Stay Free.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Positioned(
                top: 332,
                left: 20,
                right: 20,
                child: Text(
                  'Choose what you\'re staying free from:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                top: 364,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
                  child: Column(
                    children: [
                      PremiumQuitCard(
                        idlePulseAnimation: _idleCurve,
                        title: 'Cigarette/Vape',
                        imagePath: 'assets/icons/cigarette.png',
                        colors: const [Color(0xFFFF4A00), Color(0xFFFF0000)],
                        glowColor: const Color(0xFFFF3B30),
                      ),
                      const SizedBox(height: 10),
                      PremiumQuitCard(
                        idlePulseAnimation: _idleCurve,
                        title: 'Alcohol',
                        imagePath: 'assets/icons/alcohol.png',
                        colors: const [Color(0xFFFFB000), Color(0xFFFF6A00)],
                        glowColor: const Color(0xFFFF9500),
                      ),
                      const SizedBox(height: 10),
                      PremiumQuitCard(
                        idlePulseAnimation: _idleCurve,
                        title: 'Sugar/Carbs',
                        imagePath: 'assets/icons/cookie .png',
                        colors: const [Color(0xFFFFD400), Color(0xFFF09000)],
                        glowColor: const Color(0xFFFFCC00),
                      ),
                      const SizedBox(height: 10),
                      PremiumQuitCard(
                        idlePulseAnimation: _idleCurve,
                        title: 'Cannabis',
                        imagePath: 'assets/icons/cannabis.png',
                        colors: const [Color(0xFF00C95A), Color(0xFF008A48)],
                        glowColor: const Color(0xFF34C759),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(34),
                      bottomRight: Radius.circular(34),
                    ),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 2,
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: (index) => setState(() => selectedIndex = index),
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: const Color(0xFF1976FF),
                    unselectedItemColor: const Color(0xFF9EA4AA),
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedFontSize: 12,
                    unselectedFontSize: 11,
                    iconSize: 28,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.home_rounded,
                          color: Color(0xFF1976FF),
                        ),
                        activeIcon: Icon(
                          Icons.home_rounded,
                          color: Color(0xFF1976FF),
                        ),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF00A86B),
                        ),
                        activeIcon: Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF00A86B),
                        ),
                        label: 'Stats',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF9C4DFF),
                        ),
                        activeIcon: Icon(
                          Icons.person_rounded,
                          color: Color(0xFF9C4DFF),
                        ),
                        label: 'Profile',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.settings_rounded,
                          color: Color(0xFFFF8A00),
                        ),
                        activeIcon: Icon(
                          Icons.settings_rounded,
                          color: Color(0xFFFF8A00),
                        ),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumQuitCard extends StatefulWidget {
  const PremiumQuitCard({
    super.key,
    required this.idlePulseAnimation,
    required this.title,
    required this.imagePath,
    required this.colors,
    required this.glowColor,
  });

  final Animation<double> idlePulseAnimation;
  final String title;
  final String imagePath;
  final List<Color> colors;
  final Color glowColor;

  @override
  State<PremiumQuitCard> createState() => _PremiumQuitCardState();
}

class _PremiumQuitCardState extends State<PremiumQuitCard> {
  bool pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => pressed = true),
        onTapUp: (_) => setState(() => pressed = false),
        onTapCancel: () => setState(() => pressed = false),
        child: AnimatedScale(
          scale: pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            width: 330,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: _hovered ? 0.85 : 0.35,
                  ),
                  blurRadius: _hovered ? 42 : 22,
                  spreadRadius: _hovered ? 5 : 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
              child: Container(
              width: 330,
              height: 76,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      widget.imagePath,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      gaplessPlayback: true,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


