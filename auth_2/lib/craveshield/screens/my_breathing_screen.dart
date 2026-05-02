import 'dart:math';
import 'package:flutter/material.dart';

class MyBreathingScreen extends StatefulWidget {
  const MyBreathingScreen({super.key});

  static const routeName = 'craveMyBreathing';
  static const routePath = '/crave-my-breathing';

  @override
  State<MyBreathingScreen> createState() => _MyBreathingScreenState();
}

enum _Phase { inhale, hold, exhale }

class _MyBreathingScreenState extends State<MyBreathingScreen>
    with TickerProviderStateMixin {
  static const _durations = {
    _Phase.inhale: 4,
    _Phase.hold: 7,
    _Phase.exhale: 8,
  };

  // Breathing scale
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  // Effect controllers
  late final AnimationController _rippleCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowCtrl;

  // Particles — generated once, seeded for consistency
  late final List<_Particle> _particles;

  _Phase _phase = _Phase.inhale;
  int _secondsLeft = 4;
  bool _running = false;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, value: 0);
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    final rng = Random(42);
    _particles = List.generate(
      12,
      (_) => _Particle(
        x: rng.nextDouble(),
        speed: 0.6 + rng.nextDouble() * 0.8,
        offset: rng.nextDouble(),
        size: 2.0 + rng.nextDouble() * 3.0,
        alpha: 0.3 + rng.nextDouble() * 0.5,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _rippleCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _rippleCtrl.repeat();
    _particleCtrl.repeat();
    _glowCtrl.repeat(reverse: true);
    _runPhase(_Phase.inhale);
  }

  void _stop() {
    setState(() => _running = false);
    _rippleCtrl.stop();
    _rippleCtrl.reset();
    _particleCtrl.stop();
    _particleCtrl.reset();
    _glowCtrl.stop();
    _glowCtrl.reset();
    _ctrl
        .animateTo(0,
            duration: const Duration(milliseconds: 600), curve: Curves.easeOut)
        .then((_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.inhale;
        _secondsLeft = _durations[_Phase.inhale]!;
      });
    });
  }

  Future<void> _runPhase(_Phase phase) async {
    if (!mounted || !_running) return;
    final secs = _durations[phase]!;

    setState(() {
      _phase = phase;
      _secondsLeft = secs;
    });

    switch (phase) {
      case _Phase.inhale:
        _ctrl.duration = Duration(seconds: secs);
        _ctrl.forward(from: 0);
      case _Phase.hold:
        break;
      case _Phase.exhale:
        _ctrl.duration = Duration(seconds: secs);
        _ctrl.reverse(from: 1);
    }

    for (int i = secs; i > 0; i--) {
      if (!mounted || !_running) return;
      setState(() => _secondsLeft = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_running) return;
    _runPhase(switch (phase) {
      _Phase.inhale => _Phase.hold,
      _Phase.hold => _Phase.exhale,
      _Phase.exhale => _Phase.inhale,
    });
  }

  String get _phaseLabel => switch (_phase) {
        _Phase.inhale => 'INHALE',
        _Phase.hold => 'HOLD',
        _Phase.exhale => 'EXHALE',
      };

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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                  child: Column(
                    children: [
                      // ── Back button ──────────────────────────────────────
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

                      // ── Icon ─────────────────────────────────────────────
                      Image.asset(
                        'assets/my_shield_features/my_breathing.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 22),

                      // ── Title ────────────────────────────────────────────
                      const Text(
                        'My Breathing',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Subtitle ─────────────────────────────────────────
                      const Text(
                        'Follow the rhythm. Ride the craving wave.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Breathing circle + particles ─────────────────────
                      Expanded(
                        child: Stack(
                          children: [
                            // Floating particles — behind everything
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _particleCtrl,
                                builder: (_, __) => CustomPaint(
                                  painter: _ParticlePainter(
                                    progress: _particleCtrl.value,
                                    particles: _particles,
                                    visible: _running,
                                  ),
                                ),
                              ),
                            ),

                            // Breathing circle
                            Center(
                              child: AnimatedBuilder(
                                animation: Listenable.merge(
                                    [_scale, _rippleCtrl, _glowCtrl]),
                                builder: (context, _) {
                                  final t = _scale.value;
                                  final g = _glowCtrl.value;
                                  final circleSize = 170.0 + 70.0 * t;
                                  final glowSize = circleSize + 60.0;
                                  final showRipples =
                                      _running && _phase == _Phase.inhale;

                                  return SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // ── Ripple rings (INHALE only) ──────
                                        AnimatedOpacity(
                                          opacity: showRipples ? 1.0 : 0.0,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: List.generate(3, (i) {
                                              final ringT =
                                                  (_rippleCtrl.value + i / 3.0) %
                                                      1.0;
                                              final ringSize =
                                                  240.0 + 90.0 * ringT;
                                              final ringAlpha =
                                                  (1.0 - ringT) * 0.25;
                                              return Container(
                                                width: ringSize,
                                                height: ringSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFF2BC0E4)
                                                            .withValues(
                                                                alpha:
                                                                    ringAlpha),
                                                    width: 1.5,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),

                                        // ── Ambient glow ring ────────────────
                                        Container(
                                          width: glowSize,
                                          height: glowSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(0xFF2BC0E4)
                                                    .withValues(
                                                        alpha: 0.14 + 0.14 * t),
                                                const Color(0xFF2BC0E4)
                                                    .withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // ── Main gradient circle ─────────────
                                        Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF2BC0E4),
                                                Color(0xFF1B5FCB),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              // Inner: follows breathing scale
                                              BoxShadow(
                                                color: const Color(0xFF2BC0E4)
                                                    .withValues(
                                                        alpha: 0.30 + 0.30 * t),
                                                blurRadius: 20 + 20 * t,
                                                spreadRadius: 2 + 4 * t,
                                              ),
                                              // Middle: pulses on _glowCtrl
                                              BoxShadow(
                                                color: const Color(0xFF2BC0E4)
                                                    .withValues(
                                                        alpha: 0.14 + 0.12 * g),
                                                blurRadius: 50 + 20 * g,
                                                spreadRadius: 0,
                                              ),
                                              // Outer: soft navy aura
                                              BoxShadow(
                                                color: const Color(0xFF1B5FCB)
                                                    .withValues(
                                                        alpha: 0.08 + 0.08 * t),
                                                blurRadius: 85 + 25 * g,
                                                spreadRadius: -5,
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ── Text — never scales or moves ─────
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 350),
                                              child: Text(
                                                _running ? _phaseLabel : 'READY',
                                                key: ValueKey(_running
                                                    ? _phaseLabel
                                                    : 'READY'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Opacity avoids layout jump
                                            Opacity(
                                              opacity: _running ? 1.0 : 0.0,
                                              child: Text(
                                                '$_secondsLeft',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Phase chips ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _PhaseChip(
                            label: 'Inhale',
                            seconds: 4,
                            isActive: _running && _phase == _Phase.inhale,
                          ),
                          _PhaseChip(
                            label: 'Hold',
                            seconds: 7,
                            isActive: _running && _phase == _Phase.hold,
                          ),
                          _PhaseChip(
                            label: 'Exhale',
                            seconds: 8,
                            isActive: _running && _phase == _Phase.exhale,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── START / STOP button ──────────────────────────────
                      GestureDetector(
                        onTapDown: (_) => setState(() => _btnPressed = true),
                        onTapUp: (_) {
                          setState(() => _btnPressed = false);
                          _running ? _stop() : _start();
                        },
                        onTapCancel: () => setState(() => _btnPressed = false),
                        child: AnimatedScale(
                          scale: _btnPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2BC0E4)
                                      .withValues(alpha: .30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _running ? 'STOP' : 'START BREATHING',
                                key: ValueKey(_running),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                            ),
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

// ── Phase chip ────────────────────────────────────────────────────────────────

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.seconds,
    required this.isActive,
  });

  final String label;
  final int seconds;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.55,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color:
                  isActive ? const Color(0xFF2BC0E4) : const Color(0xFF7BA8D8),
              fontSize: isActive ? 28 : 26,
              fontWeight: FontWeight.w900,
            ),
            child: Text('$seconds'),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Particle data ─────────────────────────────────────────────────────────────

class _Particle {
  const _Particle({
    required this.x,
    required this.speed,
    required this.offset,
    required this.size,
    required this.alpha,
  });

  final double x;      // horizontal 0–1
  final double speed;  // relative speed 0.6–1.4
  final double offset; // cycle phase offset 0–1
  final double size;   // radius px 2–5
  final double alpha;  // max opacity 0.3–0.8
}

// ── Particle painter ──────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.progress,
    required this.particles,
    required this.visible,
  });

  final double progress;
  final List<_Particle> particles;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final t = (progress * p.speed + p.offset) % 1.0;
      // fade in bottom 15%, full mid, fade out top 25%
      final opacity = t < 0.15
          ? t / 0.15
          : (t > 0.75 ? (1.0 - t) / 0.25 : 1.0);
      final y = size.height * (1.0 - t);
      final x = size.width * p.x + sin(t * pi * 2 + p.offset * pi) * 12;
      paint
        ..color =
            const Color(0xFF2BC0E4).withValues(alpha: opacity * p.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.visible != visible;
}
