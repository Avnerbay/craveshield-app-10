import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../quit_selection_screen.dart';
import '../services/crave_auth_session.dart';
import 'disclaimer_screen.dart';

class CraveSplashScreen extends StatefulWidget {
  const CraveSplashScreen({super.key});

  static const routeName = 'craveSplash';
  static const routePath = '/crave-splash';

  @override
  State<CraveSplashScreen> createState() => _CraveSplashScreenState();
}

class _CraveSplashScreenState extends State<CraveSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _introController;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _sparkleOpacity;
  late final Animation<double> _sloganOpacity;
  late final Animation<Offset> _sloganOffset;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _logoScale = Tween<double>(begin: .975, end: 1.045).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringScale = Tween<double>(begin: .95, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );
    _ringOpacity = Tween<double>(begin: .26, end: .62).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _sparkleOpacity = Tween<double>(begin: .30, end: .95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _sloganOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(.18, 1, curve: Curves.easeOutCubic),
    );
    _sloganOffset = Tween<Offset>(
      begin: const Offset(0, .10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(.18, 1, curve: Curves.easeOutCubic),
      ),
    );

    _redirectIfLoggedIn();
  }

  Future<void> _redirectIfLoggedIn() async {
    final isLoggedIn = await CraveAuthSession.isLoggedIn();
    if (!mounted || !isLoggedIn) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QuitSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).pushNamed(CraveDisclaimerScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1E),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF020B1E),
                    Color(0xFF062B66),
                    Color(0xFF1255A6),
                  ],
                  stops: [0, .52, 1],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _BackgroundSparklePainter(
                          _pulseController.value,
                        ),
                      );
                    },
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height = constraints.maxHeight;
                        final topLogoGap =
                            math.max(18.0, math.min(44.0, height * .045));
                        final stageSize =
                            math.max(190.0, math.min(width * .62, 250.0));
                        final buttonHorizontalPadding =
                            math.max(26.0, width * .075);
                        final bottomGap =
                            math.max(22.0, math.min(34.0, height * .035));

                        return Column(
                          children: [
                            SizedBox(height: topLogoGap),
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return _LogoStage(
                                  size: stageSize,
                                  logoScale: _logoScale.value,
                                  ringScale: _ringScale.value,
                                  ringOpacity: _ringOpacity.value,
                                  sparkleOpacity: _sparkleOpacity.value,
                                );
                              },
                            ),
                            Expanded(
                              child: Center(
                                child: FadeTransition(
                                  opacity: _sloganOpacity,
                                  child: SlideTransition(
                                    position: _sloganOffset,
                                    child: AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, _) {
                                        return _Slogan(
                                          glowOpacity: _sparkleOpacity.value,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: buttonHorizontalPadding,
                              ),
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, _) {
                                  final wave = math.sin(
                                    _pulseController.value * math.pi * 2,
                                  );
                                  return Transform.scale(
                                    scale: .992 + ((wave + 1) / 2) * .018,
                                    child: _StartShieldButton(
                                      onPressed: _continue,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: bottomGap),
                          ],
                        );
                      },
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

class _LogoStage extends StatelessWidget {
  const _LogoStage({
    required this.size,
    required this.logoScale,
    required this.ringScale,
    required this.ringOpacity,
    required this.sparkleOpacity,
  });

  final double size;
  final double logoScale;
  final double ringScale;
  final double ringOpacity;
  final double sparkleOpacity;

  @override
  Widget build(BuildContext context) {
    final circleSize = math.min(size * .70, 184.0);
    final svgSize = circleSize * .86;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _LogoHalo(opacity: ringOpacity),
          Transform.scale(
            scale: ringScale,
            child: _PulseRing(
              size: math.min(size * .98, 260),
              opacity: ringOpacity * .30,
              width: 1.3,
            ),
          ),
          Transform.scale(
            scale: (ringScale + .04).clamp(.9, 1.18),
            child: _PulseRing(
              size: math.min(size * .88, 246),
              opacity: ringOpacity * .50,
              width: 1.7,
            ),
          ),
          Transform.scale(
            scale: (ringScale + .08).clamp(.9, 1.22),
            child: _PulseRing(
              size: math.min(size * .78, 230),
              opacity: ringOpacity * .82,
              width: 2.1,
            ),
          ),
          _Sparkle(
            left: size * .18,
            top: size * .20,
            size: 6,
            opacity: sparkleOpacity * .68,
          ),
          _Sparkle(
            right: size * .22,
            top: size * .10,
            size: 8,
            opacity: sparkleOpacity * .86,
          ),
          _Sparkle(
            right: size * .08,
            top: size * .42,
            size: 5,
            opacity: sparkleOpacity * .42,
            color: const Color(0xFF65F36A),
          ),
          _Sparkle(
            left: size * .10,
            bottom: size * .33,
            size: 5,
            opacity: sparkleOpacity * .40,
          ),
          _Sparkle(
            right: size * .15,
            bottom: size * .24,
            size: 7,
            opacity: sparkleOpacity * .72,
            color: const Color(0xFF65F36A),
          ),
          Transform.scale(
            scale: logoScale,
            child: _LogoBadge(
              circleSize: circleSize,
              svgSize: svgSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundSparklePainter extends CustomPainter {
  const _BackgroundSparklePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const sparkles = [
      _SparklePoint(.18, .18, 2.4, Color(0xFF4DEFFF), .00, 9, -7),
      _SparklePoint(.78, .16, 3.2, Color(0xFF4DEFFF), .18, -8, 10),
      _SparklePoint(.86, .33, 2.0, Color(0xFF65F36A), .34, -7, -8),
      _SparklePoint(.24, .60, 2.2, Color(0xFF65F36A), .52, 10, 8),
      _SparklePoint(.70, .66, 1.9, Color(0xFF4DEFFF), .70, -9, -6),
      _SparklePoint(.38, .78, 1.8, Color(0xFF4DEFFF), .86, 8, 7),
    ];

    for (final sparkle in sparkles) {
      final wave = math.sin((progress + sparkle.phase) * math.pi * 2);
      final drift = math.cos((progress + sparkle.phase) * math.pi * 2);
      final twinkle = ((wave + 1) / 2).clamp(0.0, 1.0);
      final opacity = (.22 + twinkle * .62).clamp(0.0, 1.0);
      final center = Offset(
        size.width * sparkle.x + drift * sparkle.dx,
        size.height * sparkle.y + wave * sparkle.dy,
      );
      final paint = Paint()
        ..color = sparkle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;
      final glowPaint = Paint()
        ..color = sparkle.color.withValues(alpha: opacity * .62)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      final rayPaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * .82)
        ..strokeWidth = math.max(1, sparkle.radius * .45)
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, sparkle.radius * (3.6 + twinkle), glowPaint);
      canvas.drawCircle(center, sparkle.radius, paint);
      canvas.drawLine(
        Offset(center.dx - sparkle.radius * 2.7, center.dy),
        Offset(center.dx + sparkle.radius * 2.7, center.dy),
        rayPaint,
      );
      canvas.drawLine(
        Offset(center.dx, center.dy - sparkle.radius * 2.7),
        Offset(center.dx, center.dy + sparkle.radius * 2.7),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundSparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SparklePoint {
  const _SparklePoint(
    this.x,
    this.y,
    this.radius,
    this.color,
    this.phase,
    this.dx,
    this.dy,
  );

  final double x;
  final double y;
  final double radius;
  final Color color;
  final double phase;
  final double dx;
  final double dy;
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.circleSize,
    required this.svgSize,
  });

  final double circleSize;
  final double svgSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleSize,
      height: circleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-.16, -.20),
          radius: .86,
          colors: [
            Color(0xFF102650),
            Color(0xFF071326),
            Color(0xFF01050C),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4DEFFF).withValues(alpha: .16),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DEFFF).withValues(alpha: .42),
            blurRadius: 42,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF65F36A).withValues(alpha: .08),
            blurRadius: 54,
            spreadRadius: 7,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .38),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/images/craveshield_logo.svg',
        width: svgSize,
        height: svgSize,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _LogoHalo extends StatelessWidget {
  const _LogoHalo({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      height: 205,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DEFFF).withValues(alpha: opacity * .18),
            blurRadius: 82,
            spreadRadius: 18,
          ),
          BoxShadow(
            color: const Color(0xFF65F36A).withValues(alpha: opacity * .08),
            blurRadius: 96,
            spreadRadius: 9,
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.size,
    required this.opacity,
    required this.width,
  });

  final double size;
  final double opacity;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4DEFFF).withValues(alpha: opacity),
          width: width,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DEFFF).withValues(alpha: opacity * .42),
            blurRadius: 24,
            spreadRadius: .8,
          ),
        ],
      ),
    );
  }
}

class _Slogan extends StatelessWidget {
  const _Slogan({required this.glowOpacity});

  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We Start\nWhen Others',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: .1,
                height: 1.16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'QUIT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                height: .96,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4EFF7A),
                letterSpacing: 1.6,
                shadows: [
                  Shadow(
                    blurRadius: 16,
                    color: const Color(0xFF4EFF7A).withValues(alpha: .82),
                  ),
                  Shadow(
                    blurRadius: 30,
                    color: const Color(0xFF4EFF7A).withValues(alpha: .34),
                  ),
                ],
              ),
            ),
          ],
        ),
        _Sparkle(
          left: 102,
          bottom: -18,
          size: 5,
          opacity: glowOpacity * .42,
          color: const Color(0xFF65F36A),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.size,
    required this.opacity,
    this.color = const Color(0xFF4DEFFF),
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final double size;
  final double opacity;
  final Color color;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final visibleOpacity = opacity.clamp(0.0, 1.0);

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: visibleOpacity),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: visibleOpacity * .82),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartShieldButton extends StatelessWidget {
  const _StartShieldButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2BC0E4),
                Color(0xFF1B5FCB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              'START MY SHIELD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
