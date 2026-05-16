import 'package:flutter/material.dart';

import 'memory_vault_screen.dart';
import 'my_breathing_screen.dart';
import 'my_games_screen.dart';
import 'my_music_screen.dart';
import 'my_quotes_screen.dart';
import 'my_short_break_screen.dart';
import 'my_sounds_screen.dart';
import 'my_support_screen.dart';

class MyShieldScreen extends StatefulWidget {
  const MyShieldScreen({super.key});

  static const routeName = 'craveMyShield';
  static const routePath = '/crave-my-shield';

  @override
  State<MyShieldScreen> createState() => _MyShieldScreenState();
}

class _MyShieldScreenState extends State<MyShieldScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  static const List<Map<String, dynamic>> _items = [
    {'label': 'My Breathing',   'icon': 'assets/my_shield_features/my_breathing.png',  'route': MyBreathingScreen.routePath},
    {'label': 'My Support',     'icon': 'assets/my_shield_features/my_support.png',    'route': MySupportScreen.routePath},
    {'label': 'My Photos',      'icon': 'assets/my_shield_features/my_photos.png',     'route': MemoryVaultScreen.routePath},
    {'label': 'My Quotes',      'icon': 'assets/my_shield_features/my_quotes.png',     'route': MyQuotesScreen.routePath},
    {'label': 'My Short Break', 'icon': 'assets/my_shield_features/my_short_break.png','route': MyShortBreakScreen.routePath},
    {'label': 'My Music',       'icon': 'assets/my_shield_features/my_music.png',      'route': MyMusicScreen.routePath},
    {'label': 'My Sound',       'icon': 'assets/my_shield_features/my_sound.png',      'route': MySoundsScreen.routePath},
    {'label': 'My Games',       'icon': 'assets/my_shield_features/my_games.png',      'route': MyGamesScreen.routePath},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001f3f),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'MY SHIELD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return GestureDetector(
                      onTap: () {
                        if (item['route'] != null) {
                          Navigator.pushNamed(
                              context, item['route'] as String);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0a2a5e),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: FractionallySizedBox(
                                    widthFactor: 0.65,
                                    heightFactor: 0.65,
                                    child: Image.asset(
                                      item['icon'] as String,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              item['label'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
