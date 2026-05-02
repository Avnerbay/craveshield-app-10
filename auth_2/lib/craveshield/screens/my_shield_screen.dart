import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'memory_vault_screen.dart';
import 'my_breathing_screen.dart';
import 'my_games_screen.dart';

class MyShieldScreen extends StatelessWidget {
  const MyShieldScreen({super.key});

  static const routeName = 'craveMyShield';
  static const routePath = '/crave-my-shield';

  static const _tiles = [
    _TileData('assets/my_shield_features/my_games.png', MyGamesScreen.routePath),
    _TileData('assets/my_shield_features/my_breathing.png', MyBreathingScreen.routePath),
    _TileData('assets/my_shield_features/my_music.png', null),
    _TileData('assets/my_shield_features/my_photos.png', MemoryVaultScreen.routePath),
    _TileData('assets/my_shield_features/my_quotes.png', null),
    _TileData('assets/my_shield_features/my_sound .png', null),
    _TileData('assets/my_shield_features/my_short_break.png', null),
    _TileData('assets/my_shield_features/my_support.png', null),
  ];

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
              width: double.infinity,
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back',
                          color: Colors.white,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/my_shield.svg',
                          width: 140,
                          height: 140,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'MY SHIELD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: _tiles.map((tile) {
                          return _ShieldTile(
                            imagePath: tile.imagePath,
                            onTap: tile.routePath != null
                                ? () => Navigator.pushNamed(
                                      context,
                                      tile.routePath!,
                                    )
                                : () => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      const SnackBar(
                                        content: Text('Coming Soon'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2BC0E4),
                              Color(0xFF1B5FCB),
                            ],
                          ),
                        ),
                        child: const Text(
                          'SAVE MY SHIELD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TileData {
  const _TileData(this.imagePath, this.routePath);
  final String imagePath;
  final String? routePath; // null = Coming Soon
}

class _ShieldTile extends StatefulWidget {
  const _ShieldTile({required this.imagePath, required this.onTap});

  final String imagePath;
  final VoidCallback onTap;

  @override
  State<_ShieldTile> createState() => _ShieldTileState();
}

class _ShieldTileState extends State<_ShieldTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: _hovered ? 0.22 : 0.10),
                  blurRadius: _hovered ? 20 : 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
