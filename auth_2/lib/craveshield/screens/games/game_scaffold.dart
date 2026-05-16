import 'package:flutter/material.dart';

/// Shared chrome for every game: gradient background, back button, title.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.bottomBar,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? bottomBar;

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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new,
                                size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                    Expanded(child: child),
                    if (bottomBar != null) bottomBar!,
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

/// Reusable gradient pill button.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width = double.infinity,
    this.height = 52.0,
  });

  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
              colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2BC0E4).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}
