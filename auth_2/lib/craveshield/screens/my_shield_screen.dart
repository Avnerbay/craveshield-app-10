import 'package:flutter/material.dart';

class MyShieldScreen extends StatelessWidget {
  const MyShieldScreen({super.key});

  static const routeName = 'craveMyShield';
  static const routePath = '/crave-my-shield';

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
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3DFF9A)
                                    .withValues(alpha: .25),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Color(0xFF3DFF9A),
                            size: 48,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Build Your Shield',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create your personal defense against cravings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const _ShieldSectionCard(
                        icon: Icons.photo_library_rounded,
                        title: 'Personal Motivation',
                        subtitle:
                            'Images, videos, and words that remind you why.',
                      ),
                      const SizedBox(height: 14),
                      const _ShieldSectionCard(
                        icon: Icons.format_quote_rounded,
                        title: 'Quotes / Affirmations',
                        subtitle:
                            'Short phrases for moments when willpower drops.',
                      ),
                      const SizedBox(height: 14),
                      const _ShieldSectionCard(
                        icon: Icons.music_note_rounded,
                        title: 'Music / Audio',
                        subtitle: 'Grounding sounds and playlists for urges.',
                      ),
                      const SizedBox(height: 14),
                      const _ShieldSectionCard(
                        icon: Icons.psychology_alt_rounded,
                        title: 'Emergency tools',
                        subtitle: 'CBT, breathing, and distraction tools.',
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

class _ShieldSectionCard extends StatelessWidget {
  const _ShieldSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0E4FA8).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF0E4FA8), size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF10233F),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF526C91),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
