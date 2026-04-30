import 'package:flutter/material.dart';

class MyShieldScreen extends StatefulWidget {
  const MyShieldScreen({super.key});

  @override
  State<MyShieldScreen> createState() => _MyShieldScreenState();
}

class _MyShieldScreenState extends State<MyShieldScreen> {
  int selectedIndex = 0;
  int _hoveredIndex = -1;

  Widget _buildTile(String path, int index) {
    final hovered = _hoveredIndex == index;
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) {
        if (_hoveredIndex == index) {
          setState(() => _hoveredIndex = -1);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(
                alpha: hovered ? 0.8 : 0.3,
              ),
              blurRadius: hovered ? 35 : 18,
              spreadRadius: hovered ? 4 : 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(path, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildTileRow(
    String left,
    String right,
    int leftIndex,
    int rightIndex,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: _buildTile(left, leftIndex),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150,
          height: 150,
          child: _buildTile(right, rightIndex),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071A33),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF123E78),
                    Color(0xFF0B2B55),
                    Color(0xFF081C38),
                  ],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _Header(onBack: () => Navigator.maybePop(context)),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTileRow(
                              'assets/my_shield_features/my_games.png',
                              'assets/my_shield_features/my_breathing.png',
                              0,
                              1,
                            ),
                            const SizedBox(height: 14),
                            _buildTileRow(
                              'assets/my_shield_features/my_music.png',
                              'assets/my_shield_features/my_photos.png',
                              2,
                              3,
                            ),
                            const SizedBox(height: 14),
                            _buildTileRow(
                              'assets/my_shield_features/my_quotes.png',
                              'assets/my_shield_features/my_sound .png',
                              4,
                              5,
                            ),
                            const SizedBox(height: 14),
                            _buildTileRow(
                              'assets/my_shield_features/my_short_break.png',
                              'assets/my_shield_features/my_support.png',
                              6,
                              7,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _BottomNavBar(
                    selectedIndex: selectedIndex,
                    onTap: (index) => setState(() => selectedIndex = index),
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

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            label: const Text('Back'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 44),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/my_shield_features/craveshield_logo_primary.png',
                  width: 92,
                  height: 92,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  isAntiAlias: true,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF75E9FF),
                      Color(0xFF9B6DFF),
                      Color(0xFFFF4FB7),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'MY SHIELD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      height: .95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.pinkAccent.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ride the Craving. Win the 10.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF4FB7),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
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
            icon: Icon(Icons.home_rounded, color: Color(0xFF1976FF)),
            activeIcon: Icon(Icons.home_rounded, color: Color(0xFF1976FF)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded, color: Color(0xFF00A86B)),
            activeIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF00A86B)),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, color: Color(0xFF9C4DFF)),
            activeIcon: Icon(Icons.person_rounded, color: Color(0xFF9C4DFF)),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded, color: Color(0xFFFF8A00)),
            activeIcon: Icon(Icons.settings_rounded, color: Color(0xFFFF8A00)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
