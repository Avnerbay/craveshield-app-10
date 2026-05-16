import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Fish {
  _Fish({
    required this.id,
    required this.x,
    required this.y,
    required this.vx,
    required this.baseSpeed,
    required this.bodyLen,
    required this.color,
    required this.phase,
    required this.bobFreq,
    required this.bobAmp,
    required this.wagPhase,
  });

  final int    id;
  final Color  color;
  final double bodyLen;   // fraction of screen width
  final double phase;     // bobbing phase offset
  final double bobFreq;   // bobbing frequency (rad/s)
  final double bobAmp;    // bobbing amplitude (normalized)
  final double wagPhase;  // tail-wag phase offset
  final double baseSpeed;

  double x = 0, y = 0;          // 0..1 normalized
  double vx = 0, vy = 0;        // velocity (normalized / second)
  double speedMult = 1.0;
  double speedTimer = 0.0;
  int? pelletTarget;
}

class _Bubble {
  _Bubble({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.wobble,
  });
  double x, y;            // 0..1 normalized
  final double r;          // radius in pixels
  final double speed;      // upward speed (normalized / second)
  final double wobble;     // horizontal wobble phase
}

class _Pellet {
  _Pellet({required this.id, required this.x, required this.y});
  final int id;
  double x, y;
  double age = 0;
  bool   eaten   = false;
  double eatPulse = 0;   // 0..1 expanding ring after eaten
}

// pre-generated pebble data so the painter never re-generates
class _Pebble {
  const _Pebble(this.xf, this.yf, this.rx, this.ry);
  final double xf, yf, rx, ry;
}

// ── Colors ────────────────────────────────────────────────────────────────────

const _kFishColors = [
  Color(0xFFFF7F7F), // coral
  Color(0xFFFFD166), // golden yellow
  Color(0xFF2BCDC1), // teal
  Color(0xFFFF85A1), // pink
  Color(0xFFB8E0FF), // ice blue
  Color(0xFFFF9A3C), // orange
  Color(0xFF79E7C7), // mint
  Color(0xFFFFB3DE), // soft pink
  Color(0xFF90CAF9), // sky blue
  Color(0xFFA5D6A7), // soft green
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AquariumScreen extends StatefulWidget {
  const AquariumScreen({super.key});

  @override
  State<AquariumScreen> createState() => _AquariumState();
}

class _AquariumState extends State<AquariumScreen>
    with SingleTickerProviderStateMixin {
  static const _fishCount   = 10;
  static const _maxPellets  = 5;
  static const _pebbleCount = 22;

  final _rng = Random();
  late final Ticker        _ticker;
  late final List<_Fish>   _fish;
  late final List<_Bubble> _bubbles;
  late final List<_Pebble> _pebbles;
  final      List<_Pellet> _pellets = [];

  int    _nextPelletId = 0;
  double _time         = 0;
  Duration _lastTick   = Duration.zero;
  Size   _size         = const Size(400, 800);

  bool _showHint = true;
  bool _audioOn  = false;
  Timer? _hintTimer;

  // ── Init / dispose ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fish    = _spawnFish();
    _bubbles = _spawnBubbles();
    _pebbles = _genPebbles();
    _ticker  = createTicker(_onTick)..start();
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _hintTimer?.cancel();
    super.dispose();
  }

  // ── Spawn helpers ─────────────────────────────────────────────────────────

  List<_Fish> _spawnFish() => List.generate(_fishCount, (i) {
        final dir = _rng.nextBool() ? 1.0 : -1.0;
        final spd = 0.07 + _rng.nextDouble() * 0.09; // 0.07–0.16 → 6–14 s/screen
        return _Fish(
          id:        i,
          x:         _rng.nextDouble(),
          y:         0.18 + _rng.nextDouble() * 0.52,
          vx:        dir * spd,
          baseSpeed: spd,
          bodyLen:   0.055 + _rng.nextDouble() * 0.06,
          color:     _kFishColors[i % _kFishColors.length],
          phase:     _rng.nextDouble() * 2 * pi,
          bobFreq:   0.5 + _rng.nextDouble() * 0.7,
          bobAmp:    0.004 + _rng.nextDouble() * 0.006,
          wagPhase:  _rng.nextDouble() * 2 * pi,
        );
      });

  List<_Bubble> _spawnBubbles() => List.generate(20, (i) => _Bubble(
        x:      _rng.nextDouble(),
        y:      _rng.nextDouble(),
        r:      1.5 + _rng.nextDouble() * 5,
        speed:  0.025 + _rng.nextDouble() * 0.045,
        wobble: _rng.nextDouble() * 2 * pi,
      ));

  List<_Pebble> _genPebbles() {
    final rng = Random(37); // fixed seed → stable layout
    return List.generate(_pebbleCount, (_) => _Pebble(
          rng.nextDouble(),
          0.88 + rng.nextDouble() * 0.10,
          3 + rng.nextDouble() * 7,
          1.5 + rng.nextDouble() * 3,
        ));
  }

  // ── Tick / update ─────────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastTick = elapsed;
    _time     = elapsed.inMicroseconds / 1e6;

    _updateBubbles(dt);
    _updatePellets(dt);
    _updateFish(dt);

    if (mounted) setState(() {});
  }

  void _updateBubbles(double dt) {
    for (final b in _bubbles) {
      b.y -= b.speed * dt;
      if (b.y < -0.06) {
        b.y = 1.02 + _rng.nextDouble() * 0.08;
        b.x = _rng.nextDouble();
      }
    }
  }

  void _updatePellets(double dt) {
    _pellets.removeWhere((p) => p.eaten && p.eatPulse >= 1.0);
    for (final p in _pellets) {
      if (p.eaten) {
        p.eatPulse = (p.eatPulse + dt * 2.5).clamp(0.0, 1.0);
      } else {
        p.y   = (p.y + 0.016 * dt).clamp(0.0, 0.84);
        p.age += dt;
        if (p.age > 12.0) p.eaten = true;
      }
    }
  }

  _Pellet? _findPellet(int id) {
    for (final p in _pellets) {
      if (p.id == id) return p;
    }
    return null;
  }

  double _dist(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1, dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  void _updateFish(double dt) {
    for (final f in _fish) {
      // Decay speed boost
      if (f.speedTimer > 0) {
        f.speedTimer = max(0, f.speedTimer - dt);
        if (f.speedTimer == 0) f.speedMult = 1.0;
      }

      // Validate current pellet target
      if (f.pelletTarget != null) {
        final p = _findPellet(f.pelletTarget!);
        if (p == null || p.eaten) f.pelletTarget = null;
      }

      // Acquire nearest pellet if none
      if (f.pelletTarget == null) {
        _Pellet? best;
        double bestD = 0.30;
        for (final p in _pellets) {
          if (p.eaten) continue;
          final d = _dist(f.x, f.y, p.x, p.y);
          if (d < bestD) { bestD = d; best = p; }
        }
        f.pelletTarget = best?.id;
      }

      double tvx, tvy;

      if (f.pelletTarget != null) {
        final p = _findPellet(f.pelletTarget!)!;
        final dx = p.x - f.x;
        final dy = p.y - f.y;
        final d  = max(0.001, _dist(f.x, f.y, p.x, p.y));
        if (d < 0.025) {
          // Eat the pellet
          p.eaten     = true;
          p.eatPulse  = 0.001;
          f.pelletTarget = null;
          f.speedMult  = 2.4;
          f.speedTimer = 2.0;
          tvx = f.vx; tvy = f.vy; // coast briefly
        } else {
          final spd = f.baseSpeed * 2.0;
          tvx = dx / d * spd;
          tvy = dy / d * spd;
        }
      } else {
        // Normal swim: maintain direction + sine bob
        final dir = f.vx >= 0 ? 1.0 : -1.0;
        tvx = dir * f.baseSpeed * f.speedMult;
        tvy = sin(_time * f.bobFreq + f.phase) * f.bobAmp;
      }

      // Smooth steering (ease toward target velocity)
      final ease = min(1.0, 3.5 * dt);
      f.vx += (tvx - f.vx) * ease;
      f.vy += (tvy - f.vy) * ease;

      f.x += f.vx * dt;
      f.y += f.vy * dt;

      // Edge bounce (hard flip so the fish always stays visible)
      if (f.x < 0.04 && f.vx < 0) f.vx =  f.baseSpeed * f.speedMult;
      if (f.x > 0.96 && f.vx > 0) f.vx = -f.baseSpeed * f.speedMult;
      f.y = f.y.clamp(0.10, 0.74);
    }
  }

  // ── Tap to feed ───────────────────────────────────────────────────────────

  void _onTap(TapDownDetails d) {
    // If at max, expire the oldest visible pellet to make room
    if (_pellets.where((p) => !p.eaten).length >= _maxPellets) {
      final oldest = _pellets.where((p) => !p.eaten).reduce(
            (a, b) => a.age > b.age ? a : b);
      oldest.eaten = true;
    }
    _pellets.add(_Pellet(
      id: _nextPelletId++,
      x:  d.localPosition.dx / _size.width,
      y:  d.localPosition.dy / _size.height,
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF042040),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTap,
        child: Stack(children: [
          // ── Water gradient background ──────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A4A7F), Color(0xFF042040)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SizedBox.expand(),
          ),

          // ── Aquarium: rays, bubbles, plants, floor, fish, pellets ──────
          RepaintBoundary(
            child: CustomPaint(
              size: _size,
              painter: _AquariumPainter(
                fish:    _fish,
                bubbles: _bubbles,
                pellets: _pellets,
                pebbles: _pebbles,
                time:    _time,
              ),
            ),
          ),

          // ── Hint overlay ───────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _showHint ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Align(
              alignment: const Alignment(0, 0.72),
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Tap anywhere to feed the fish 🐟',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── Controls ──────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AquaButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _AquaButton(
                    icon: _audioOn ? Icons.volume_up : Icons.volume_off,
                    onTap: () => setState(() => _audioOn = !_audioOn),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Control button ────────────────────────────────────────────────────────────

class _AquaButton extends StatelessWidget {
  const _AquaButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _AquariumPainter extends CustomPainter {
  const _AquariumPainter({
    required this.fish,
    required this.bubbles,
    required this.pellets,
    required this.pebbles,
    required this.time,
  });

  final List<_Fish>   fish;
  final List<_Bubble> bubbles;
  final List<_Pellet> pellets;
  final List<_Pebble> pebbles;
  final double        time;

  @override
  bool shouldRepaint(_AquariumPainter _) => true;

  @override
  void paint(Canvas canvas, Size size) {
    _drawRays(canvas, size);
    _drawBubbles(canvas, size);
    _drawPlants(canvas, size);
    _drawFloor(canvas, size);
    _drawPellets(canvas, size);
    _drawFish(canvas, size);
  }

  // ── Light rays (caustics) ────────────────────────────────────────────────

  void _drawRays(Canvas canvas, Size size) {
    const count = 5;
    final paint = Paint();
    for (int i = 0; i < count; i++) {
      final sway  = sin(time * 0.10 + i * 1.4) * 0.05;
      final cx    = size.width * (0.12 + i * 0.20 + sway);
      final reach = size.height * (0.55 + sin(time * 0.09 + i) * 0.08);
      final half  = size.width * (0.03 + (i % 2) * 0.015);

      final rect = Rect.fromLTWH(cx - half * 2, 0, half * 4, reach);
      paint.shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

      final path = Path()
        ..moveTo(cx - half * 0.4, 0)
        ..lineTo(cx + half * 0.4, 0)
        ..lineTo(cx + half * 2.2, reach)
        ..lineTo(cx - half * 2.2, reach)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  // ── Bubbles ──────────────────────────────────────────────────────────────

  void _drawBubbles(Canvas canvas, Size size) {
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9;
    final fill   = Paint();
    for (final b in bubbles) {
      final px = (b.x + sin(b.wobble + b.y * 5) * 0.012) * size.width;
      final py = b.y * size.height;
      final a  = ((1 - py / size.height) * 0.50).clamp(0.0, 0.5);
      stroke.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(px, py), b.r, stroke);
      fill.color = Colors.white.withValues(alpha: a * 0.18);
      canvas.drawCircle(Offset(px, py), b.r, fill);
      // specular glint
      fill.color = Colors.white.withValues(alpha: a * 0.55);
      canvas.drawCircle(
          Offset(px - b.r * 0.32, py - b.r * 0.32), b.r * 0.28, fill);
    }
  }

  // ── Plants ───────────────────────────────────────────────────────────────

  static const _plantX      = [0.07, 0.20, 0.44, 0.57, 0.76, 0.91];
  static const _plantH      = [0.19, 0.13, 0.21, 0.15, 0.18, 0.12];
  static const _plantColors = [
    Color(0xFF1A7A4E), Color(0xFF13793F), Color(0xFF1A6040),
    Color(0xFF0F6B35), Color(0xFF186845), Color(0xFF116038),
  ];

  void _drawPlants(Canvas canvas, Size size) {
    for (int i = 0; i < _plantX.length; i++) {
      final px   = _plantX[i] * size.width;
      final py   = size.height * 0.875;
      final h    = _plantH[i] * size.height;
      final sway = sin(time * 0.65 + i * 1.05) * 14;

      final stemP = Paint()
        ..color      = _plantColors[i]
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 5 + (i % 2) * 2.5
        ..strokeCap  = StrokeCap.round;

      final stem = Path()
        ..moveTo(px, py)
        ..quadraticBezierTo(
            px + sway * 0.55, py - h * 0.55, px + sway, py - h);
      canvas.drawPath(stem, stemP);

      // Two leaf blades per plant
      for (int j = 1; j <= 2; j++) {
        final lx    = px + sway * (j / 3.0);
        final ly    = py - h * (j / 3.0);
        final lsway = sway * 0.4 + (j.isOdd ? 20.0 : -20.0);
        final leaf  = Path()
          ..moveTo(lx, ly)
          ..quadraticBezierTo(
              lx + lsway, ly - h * 0.10, lx + lsway * 0.6, ly - h * 0.20);
        canvas.drawPath(
          leaf,
          Paint()
            ..color      = _plantColors[i].withValues(alpha: 0.65)
            ..style      = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap  = StrokeCap.round,
        );
      }
    }
  }

  // ── Sandy floor ───────────────────────────────────────────────────────────

  void _drawFloor(Canvas canvas, Size size) {
    final floorTop = size.height * 0.875;
    final floorRect = Rect.fromLTWH(0, floorTop, size.width, size.height - floorTop);
    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF244A6A), Color(0xFF0F2A40)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(floorRect),
    );

    // Pebbles (pre-generated, stable)
    final pebP = Paint()..color = const Color(0xFF1A3D58);
    for (final p in pebbles) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(p.xf * size.width, p.yf * size.height),
            width:  p.rx * 2,
            height: p.ry * 2),
        pebP,
      );
    }
  }

  // ── Pellets ───────────────────────────────────────────────────────────────

  void _drawPellets(Canvas canvas, Size size) {
    final p = Paint();
    for (final pel in pellets) {
      final px = pel.x * size.width;
      final py = pel.y * size.height;
      if (pel.eaten) {
        // Expanding ring
        final r = 5 + pel.eatPulse * 14;
        canvas.drawCircle(
          Offset(px, py),
          r,
          Paint()
            ..color = Colors.white.withValues(alpha: (1 - pel.eatPulse) * 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else {
        final alpha = (1 - pel.age / 12.0).clamp(0.25, 1.0);
        // pellet body
        p.color = Colors.white.withValues(alpha: alpha * 0.92);
        canvas.drawCircle(Offset(px, py), 4.5, p);
        // specular
        p.color = Colors.white.withValues(alpha: alpha * 0.45);
        canvas.drawCircle(Offset(px - 1.3, py - 1.3), 1.4, p);
      }
    }
  }

  // ── Fish ─────────────────────────────────────────────────────────────────

  void _drawFish(Canvas canvas, Size size) {
    // Sort by size so smaller fish appear in front
    final sorted = List<_Fish>.from(fish)
      ..sort((a, b) => b.bodyLen.compareTo(a.bodyLen));

    for (final f in sorted) {
      final cx = f.x * size.width;
      final cy = f.y * size.height;

      canvas.save();
      canvas.translate(cx, cy);
      if (f.vx < 0) canvas.scale(-1, 1); // flip to face direction of travel

      final len    = f.bodyLen * size.width;
      final wagSpd = (2.5 + f.speedMult) * (f.pelletTarget != null ? 1.6 : 1.0);
      _drawSingleFish(canvas, len, f.color, sin(time * wagSpd + f.wagPhase));
      canvas.restore();
    }
  }

  void _drawSingleFish(Canvas canvas, double len, Color color, double wag) {
    final bw  = len;
    final bh  = len * 0.42;
    final p   = Paint()..color = color;

    // ── Tail (forked, animated) ────────────────────────────────────────
    final tw  = wag * bh * 0.55;
    final tail = Path()
      ..moveTo(-bw * 0.37, 0)
      ..lineTo(-bw * 0.70, -bh * 0.60 + tw)
      ..lineTo(-bw * 0.55, 0)
      ..lineTo(-bw * 0.70,  bh * 0.60 - tw)
      ..close();
    canvas.drawPath(tail, p..color = color.withValues(alpha: 0.82));

    // ── Body ──────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(bw * 0.05, 0), width: bw, height: bh),
      p..color = color,
    );

    // ── Belly highlight ────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(bw * 0.04, bh * 0.13),
          width:  bw * 0.50,
          height: bh * 0.32),
      Paint()..color = Colors.white.withValues(alpha: 0.20),
    );

    // ── Dorsal fin ─────────────────────────────────────────────────────
    final finW = wag * len * 0.035;
    final fin  = Path()
      ..moveTo(-bw * 0.10, -bh * 0.48)
      ..quadraticBezierTo(bw * 0.05 + finW, -bh * 0.88, bw * 0.20, -bh * 0.48);
    canvas.drawPath(
      fin,
      Paint()
        ..color      = color.withValues(alpha: 0.72)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = bh * 0.20
        ..strokeCap  = StrokeCap.round,
    );

    // ── Pectoral fin (side) ────────────────────────────────────────────
    final pec = Path()
      ..moveTo(bw * 0.05, bh * 0.05)
      ..quadraticBezierTo(bw * 0.15, bh * 0.40, -bw * 0.05, bh * 0.36);
    canvas.drawPath(
      pec,
      Paint()
        ..color      = color.withValues(alpha: 0.55)
        ..style      = PaintingStyle.stroke
        ..strokeWidth = bh * 0.14
        ..strokeCap  = StrokeCap.round,
    );

    // ── Eye ───────────────────────────────────────────────────────────
    final ex = bw * 0.31;
    final ey = -bh * 0.07;
    canvas.drawCircle(Offset(ex, ey), len * 0.075, Paint()..color = Colors.black87);
    canvas.drawCircle(
        Offset(ex + len * 0.022, ey - len * 0.022), len * 0.032,
        Paint()..color = Colors.white);
  }
}
