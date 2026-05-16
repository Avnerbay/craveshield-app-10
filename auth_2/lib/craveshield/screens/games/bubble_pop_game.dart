import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_scaffold.dart';

class BubblePopGame extends StatefulWidget {
  const BubblePopGame({super.key});

  @override
  State<BubblePopGame> createState() => _BubblePopGameState();
}

class _Bubble {
  _Bubble({
    required this.id,
    required this.origin,
    required this.radius,
    required this.color,
    required this.velocity,
    required this.lifetime,
  }) : born = DateTime.now();

  final int id;
  final Offset origin;
  final double radius;
  final Color color;
  final Offset velocity;
  final Duration lifetime;
  final DateTime born;

  Offset positionAt(DateTime now) =>
      origin + velocity * (now.difference(born).inMilliseconds / 1000.0);

  double opacityAt(DateTime now) {
    final t = now.difference(born).inMilliseconds / lifetime.inMilliseconds;
    if (t >= 1.0) return 0.0;
    if (t < 0.1) return t / 0.1;
    if (t > 0.7) return (1.0 - t) / 0.3;
    return 1.0;
  }

  bool isDeadAt(DateTime now) => now.difference(born) >= lifetime;
}

class _PopEffect {
  _PopEffect({
    required this.center,
    required this.color,
    required this.radius,
    required Random rng,
  })  : born = DateTime.now(),
        directions = List.generate(7, (i) {
          final angle = i * 2 * pi / 7 + (rng.nextDouble() - 0.5) * 0.5;
          return Offset(cos(angle), sin(angle));
        });

  static const durationMs = 380;
  final Offset center;
  final Color color;
  final double radius;
  final DateTime born;
  final List<Offset> directions;
}

class _BgParticle {
  const _BgParticle(
      this.x, this.speedFactor, this.offset, this.radius, this.alpha);
  final double x, speedFactor, offset, radius, alpha;
}

class _BubblePopGameState extends State<BubblePopGame>
    with SingleTickerProviderStateMixin {
  static const _palette = [
    Color(0xFF00E5FF), Color(0xFFFF1F8F), Color(0xFF00FFC8),
    Color(0xFFB14BFF), Color(0xFF1E90FF), Color(0xFFFF7B47),
    Color(0xFFFFD23F), Color(0xFFFF4FB7),
  ];

  late final AnimationController _tickCtrl;
  late final DateTime _startTime;
  late final List<_BgParticle> _bgParticles;

  final _rng = Random();
  final _bubbles = <_Bubble>[];
  final _popEffects = <_PopEffect>[];

  Timer? _spawnTimer;
  Size? _gameSize;
  int _score = 0;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _tickCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat();

    final bgRng = Random(7);
    _bgParticles = List.generate(
      10,
      (_) => _BgParticle(bgRng.nextDouble(), 0.5 + bgRng.nextDouble() * 0.8,
          bgRng.nextDouble(), 1.5 + bgRng.nextDouble() * 2.0,
          0.12 + bgRng.nextDouble() * 0.18),
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scheduleNextSpawn());
  }

  @override
  void dispose() {
    _tickCtrl.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _scheduleNextSpawn() {
    if (!mounted) return;
    _spawnTimer = Timer(
      Duration(milliseconds: 600 + _rng.nextInt(601)),
      () {
        if (!mounted) return;
        final now = DateTime.now();
        setState(() {
          _bubbles.removeWhere((b) => b.isDeadAt(now));
          _popEffects.removeWhere((e) =>
              now.difference(e.born).inMilliseconds >= _PopEffect.durationMs);
          if (_bubbles.length < 10 && _gameSize != null) {
            _bubbles.add(_newBubble());
          }
        });
        _scheduleNextSpawn();
      },
    );
  }

  _Bubble _newBubble() {
    final gs = _gameSize!;
    final radius = 20.0 + _rng.nextDouble() * 25.0;
    final pad = radius + 12;
    final angle = _rng.nextDouble() * 2 * pi;
    final speed = 8.0 + _rng.nextDouble() * 10.0;
    return _Bubble(
      id: _nextId++,
      origin: Offset(
        pad + _rng.nextDouble() * (gs.width - pad * 2).clamp(0, gs.width),
        pad + _rng.nextDouble() * (gs.height - pad * 2).clamp(0, gs.height),
      ),
      radius: radius,
      color: _palette[_rng.nextInt(_palette.length)],
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      lifetime: Duration(milliseconds: 4000 + _rng.nextInt(2001)),
    );
  }

  void _tapAt(TapDownDetails d) {
    final now = DateTime.now();
    for (int i = _bubbles.length - 1; i >= 0; i--) {
      final b = _bubbles[i];
      final pos = b.positionAt(now);
      if ((d.localPosition - pos).distance <= b.radius + 8) {
        HapticFeedback.lightImpact();
        setState(() {
          _score++;
          _popEffects.add(
              _PopEffect(center: pos, color: b.color, radius: b.radius, rng: _rng));
          _bubbles.removeAt(i);
        });
        return;
      }
    }
  }

  void _reset() {
    setState(() {
      _bubbles.clear();
      _popEffects.clear();
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Bubble Pop',
      trailing: _ScoreBadge(score: _score),
      bottomBar: _ResetBar(onReset: _reset),
      child: LayoutBuilder(
        builder: (_, constraints) {
          _gameSize = constraints.biggest;
          return AnimatedBuilder(
            animation: _tickCtrl,
            builder: (_, __) {
              final elapsed =
                  DateTime.now().difference(_startTime).inMilliseconds /
                      1000.0;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _tapAt,
                child: CustomPaint(
                  painter: _BubblePainter(
                    bubbles: _bubbles,
                    popEffects: _popEffects,
                    bgParticles: _bgParticles,
                    elapsedSeconds: elapsed,
                  ),
                  size: Size.infinite,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2BC0E4).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF2BC0E4).withValues(alpha: 0.40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$score',
              style: const TextStyle(
                  color: Color(0xFF2BC0E4),
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          const Text('popped',
              style: TextStyle(
                  color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ResetBar extends StatelessWidget {
  const _ResetBar({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: GestureDetector(
        onTap: onReset,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withValues(alpha: 0.08),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white60, size: 16),
              SizedBox(width: 6),
              Text('RESET',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.bubbles,
    required this.popEffects,
    required this.bgParticles,
    required this.elapsedSeconds,
  });

  final List<_Bubble> bubbles;
  final List<_PopEffect> popEffects;
  final List<_BgParticle> bgParticles;
  final double elapsedSeconds;

  static const _auroraBlobs = [
    _AB(0.15, 0.28,  1/75.0,  1/90.0, 0.52, 13.0, Color(0xFF00CCDD)),
    _AB(0.78, 0.62, -1/80.0, -1/70.0, 0.48, 10.0, Color(0xFF7733EE)),
    _AB(0.48, 0.85,  1/65.0, -1/82.0, 0.46, 16.0, Color(0xFFCC1177)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    _drawAurora(canvas, size);
    _drawBgParticles(canvas, size);
    _drawBubbles(canvas, now);
    _drawPopEffects(canvas, now);
  }

  void _drawAurora(Canvas canvas, Size size) {
    final minDim = min(size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 72);
    for (final b in _auroraBlobs) {
      final x = ((b.bx + elapsedSeconds * b.dx) % 1.0) * size.width;
      final y = ((b.by + elapsedSeconds * b.dy) % 1.0) * size.height;
      final pulse = sin(elapsedSeconds * 2 * pi / b.pp);
      final radius = minDim * b.rf * (1.0 + 0.10 * pulse);
      paint.color = b.color.withValues(alpha: 0.17 + 0.05 * (pulse + 1) / 2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawBgParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in bgParticles) {
      final t =
          ((elapsedSeconds * p.speedFactor * 0.08) + p.offset) % 1.0;
      final opacity =
          t < 0.15 ? t / 0.15 : (t > 0.75 ? (1.0 - t) / 0.25 : 1.0);
      final y = size.height * (1.0 - t);
      final x =
          size.width * p.x + sin(t * pi * 2 + p.offset * pi) * 10;
      paint
        ..color =
            const Color(0xFF2BC0E4).withValues(alpha: opacity * p.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.9);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
    paint.maskFilter = null;
  }

  void _drawBubbles(Canvas canvas, DateTime now) {
    for (final b in bubbles) {
      final pos = b.positionAt(now);
      final opacity = b.opacityAt(now);
      if (opacity <= 0) continue;
      canvas.drawCircle(
          pos,
          b.radius * 1.4,
          Paint()
            ..color = b.color.withValues(alpha: opacity * 0.30)
            ..maskFilter =
                MaskFilter.blur(BlurStyle.normal, b.radius * 0.90));
      final rect = Rect.fromCircle(center: pos, radius: b.radius);
      canvas.drawCircle(
          pos,
          b.radius,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.35, -0.35),
              radius: 0.85,
              colors: [
                Color.lerp(b.color, Colors.white, 0.72)!
                    .withValues(alpha: opacity * 0.95),
                b.color.withValues(alpha: opacity * 0.75),
                Color.lerp(b.color, Colors.black, 0.35)!
                    .withValues(alpha: opacity * 0.85),
              ],
              stops: const [0.0, 0.6, 1.0],
            ).createShader(rect));
      canvas.drawCircle(
          Offset(pos.dx - b.radius * 0.28, pos.dy - b.radius * 0.28),
          b.radius * 0.22,
          Paint()..color = Colors.white.withValues(alpha: opacity * 0.50));
    }
  }

  void _drawPopEffects(Canvas canvas, DateTime now) {
    for (final e in popEffects) {
      final ms = now.difference(e.born).inMilliseconds;
      final p = (ms / _PopEffect.durationMs).clamp(0.0, 1.0);
      if (p >= 1.0) continue;
      if (p < 0.4) {
        final bp = p / 0.4;
        canvas.drawCircle(
            e.center,
            e.radius * (1.0 + 0.55 * bp),
            Paint()
              ..color = e.color.withValues(alpha: (1.0 - bp) * 0.55)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5);
      }
      final pp = ((p - 0.1) / 0.9).clamp(0.0, 1.0);
      if (pp > 0) {
        final pPaint = Paint()..style = PaintingStyle.fill;
        for (final dir in e.directions) {
          final dist = e.radius * 2.3 * pp;
          final pPos = e.center + dir * dist;
          final pRadius = (e.radius * 0.18 * (1.0 - pp * 0.55)).clamp(1.0, 20.0);
          pPaint.color = e.color.withValues(alpha: (1.0 - pp) * 0.90);
          canvas.drawCircle(pPos, pRadius, pPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => true;
}

class _AB {
  const _AB(this.bx, this.by, this.dx, this.dy, this.rf, this.pp, this.color);
  final double bx, by, dx, dy, rf, pp;
  final Color color;
}
