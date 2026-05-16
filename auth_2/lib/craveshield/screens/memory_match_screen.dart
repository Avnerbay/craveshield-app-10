import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'games/game_scaffold.dart';

// ── Palette ────────────────────────────────────────────────────────────────

const _kAccent = Color(0xFF1E6FFF);
const _kMuted  = Color(0xFF8892B0);
const _kGold   = Color(0xFFFFD700);

// ── Calming symbols (12 pairs max for Hard) ────────────────────────────────

const _kSymbols = [
  '🌸', '🌙', '🍃', '🌊', '⛰️', '☀️', '⭐', '🪶', '🔥', '💧', '❄️', '🌳',
];

const _kConfettiColors = [
  Color(0xFF1E6FFF), Color(0xFF23D18B), Color(0xFFFFD700),
  Color(0xFFFF6B6B), Color(0xFFB388FF), Color(0xFF40E0D0),
];

// ── Difficulty ─────────────────────────────────────────────────────────────

enum _Diff { easy, medium, hard }

extension _DiffExt on _Diff {
  String get label => switch (this) {
        _Diff.easy   => 'Easy',
        _Diff.medium => 'Medium',
        _Diff.hard   => 'Hard',
      };

  String get subtitle => switch (this) {
        _Diff.easy   => '3×4 · 6 pairs',
        _Diff.medium => '4×4 · 8 pairs',
        _Diff.hard   => '4×6 · 12 pairs',
      };

  int get cols => this == _Diff.easy ? 3 : 4;

  int get totalCards => switch (this) {
        _Diff.easy   => 12,
        _Diff.medium => 16,
        _Diff.hard   => 24,
      };

  double get cardAspect => this == _Diff.hard ? 1.15 : 1.0;

  String get prefKey => 'memory_match_best_$name';
}

// ── Best record ────────────────────────────────────────────────────────────

class _Best {
  const _Best(this.moves, this.seconds);
  final int moves, seconds;

  factory _Best.fromJson(Map<String, dynamic> j) =>
      _Best(j['moves'] as int, j['time'] as int);

  Map<String, dynamic> toJson() => {'moves': moves, 'time': seconds};

  bool isBetterThan(_Best? other) {
    if (other == null) return true;
    if (moves != other.moves) return moves < other.moves;
    return seconds < other.seconds;
  }
}

// ── Game phase ─────────────────────────────────────────────────────────────

enum _Phase { start, playing, won }

// ── Screen ─────────────────────────────────────────────────────────────────

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  _Diff  _diff  = _Diff.medium;
  _Phase _phase = _Phase.start;

  late List<String> _cards;
  late List<bool>   _flipped;
  late List<bool>   _matched;
  int?   _firstIdx;
  bool   _locked  = false;
  int    _moves   = 0;
  int    _seconds = 0;
  Timer? _timer;

  bool  _isNewBest = false;
  _Best? _best;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Game logic ─────────────────────────────────────────────────────────

  Future<void> _startGame() async {
    final pairs  = _diff.totalCards ~/ 2;
    final symbols = _kSymbols.sublist(0, pairs);
    final deck   = [...symbols, ...symbols]..shuffle(Random());

    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_diff.prefKey);
    final best  = raw != null
        ? _Best.fromJson(jsonDecode(raw) as Map<String, dynamic>)
        : null;

    if (!mounted) return;

    _timer?.cancel();
    setState(() {
      _cards    = deck;
      _flipped  = List.filled(_diff.totalCards, false);
      _matched  = List.filled(_diff.totalCards, false);
      _firstIdx = null;
      _locked   = false;
      _moves    = 0;
      _seconds  = 0;
      _isNewBest = false;
      _best     = best;
      _phase    = _Phase.playing;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _phase == _Phase.playing) setState(() => _seconds++);
    });
  }

  void _tap(int i) {
    if (_locked || _flipped[i] || _matched[i] || _phase != _Phase.playing) {
      return;
    }
    setState(() => _flipped[i] = true);

    if (_firstIdx == null) {
      _firstIdx = i;
      return;
    }

    final first = _firstIdx!;
    _firstIdx = null;
    _moves++;

    if (_cards[first] == _cards[i]) {
      setState(() {
        _matched[first] = true;
        _matched[i]     = true;
      });
      if (_matched.every((m) => m)) {
        _timer?.cancel();
        _onWin();
      }
    } else {
      _locked = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _flipped[first] = false;
          _flipped[i]     = false;
          _locked         = false;
        });
      });
    }
  }

  Future<void> _onWin() async {
    final record = _Best(_moves, _seconds);
    final isNew  = record.isBetterThan(_best);
    if (isNew) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_diff.prefKey, jsonEncode(record.toJson()));
    }
    if (!mounted) return;
    setState(() {
      _isNewBest = isNew;
      if (isNew) _best = record;
      _phase = _Phase.won;
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'MEMORY MATCH',
      trailing: _phase == _Phase.playing
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              _StatBadge(label: 'moves', value: '$_moves'),
              const SizedBox(width: 8),
              _StatBadge(label: 'time', value: _fmt(_seconds)),
            ])
          : null,
      child: switch (_phase) {
        _Phase.start   => _buildStart(),
        _Phase.playing => _buildGame(),
        _Phase.won     => _buildWin(),
      },
    );
  }

  // ── Start screen ────────────────────────────────────────────────────────

  Widget _buildStart() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(children: [
        const Text('🧠', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        const Text(
          'MEMORY MATCH',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Match the pairs. Calm the mind.',
          style: TextStyle(color: _kMuted, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const Text(
          'DIFFICULTY',
          style: TextStyle(
              color: _kMuted, fontSize: 11, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _Diff.values.map((d) {
            final sel = d == _diff;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: GestureDetector(
                onTap: () => setState(() => _diff = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? _kAccent
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: sel
                          ? _kAccent
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(children: [
                    Text(
                      d.label,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            sel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      d.subtitle,
                      style: TextStyle(
                        color: sel ? Colors.white70 : Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 40),
        GameButton(label: 'START', onTap: _startGame),
      ]),
    );
  }

  // ── Game board ──────────────────────────────────────────────────────────

  Widget _buildGame() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _diff.cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: _diff.cardAspect,
      ),
      itemCount: _cards.length,
      itemBuilder: (_, i) => _FlipCard(
        key: ValueKey(i),
        symbol: _cards[i],
        flipped: _flipped[i],
        matched: _matched[i],
        onTap: () => _tap(i),
      ),
    );
  }

  // ── Win screen ──────────────────────────────────────────────────────────

  Widget _buildWin() {
    return Stack(children: [
      const Positioned.fill(child: _Confetti()),
      SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(children: [
          const Text('🌿', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          const Text(
            'Mindful Mastery!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_isNewBest) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _kGold, width: 1.5),
              ),
              child: const Text(
                '🏆 New Best!',
                style: TextStyle(
                  color: _kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(children: [
              _WinRow('Difficulty', _diff.label),
              const Divider(color: Colors.white12, height: 20),
              _WinRow('Moves', '$_moves'),
              const Divider(color: Colors.white12, height: 20),
              _WinRow('Time', _fmt(_seconds)),
              if (_best != null && !_isNewBest) ...[
                const Divider(color: Colors.white12, height: 20),
                _WinRow(
                  'Best',
                  '${_best!.moves} moves · ${_fmt(_best!.seconds)}',
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          GameButton(label: 'PLAY AGAIN', onTap: _startGame),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _phase = _Phase.start),
            child: const Text(
              'Back to Start',
              style: TextStyle(color: _kMuted, fontSize: 14),
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ── _FlipCard ───────────────────────────────────────────────────────────────

class _FlipCard extends StatefulWidget {
  const _FlipCard({
    super.key,
    required this.symbol,
    required this.flipped,
    required this.matched,
    required this.onTap,
  });
  final String symbol;
  final bool   flipped, matched;
  final VoidCallback onTap;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _matchCtrl;
  late final Animation<double>   _matchScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: (widget.flipped || widget.matched) ? 1.0 : 0.0,
    );
    _matchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _matchScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.06)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: 1.06, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 1),
    ]).animate(_matchCtrl);
  }

  @override
  void didUpdateWidget(_FlipCard old) {
    super.didUpdateWidget(old);
    final up    = widget.flipped || widget.matched;
    final wasUp = old.flipped || old.matched;
    if (up && !wasUp) _ctrl.forward();
    if (!up && wasUp) _ctrl.reverse();
    if (widget.matched && !old.matched) _matchCtrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _matchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _matchScale,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value;
            // Squish-flip: 0→0.5 back narrows to 0, 0.5→1 front widens to full
            final scaleX = ((t < 0.5) ? 1 - 2 * t : 2 * t - 1)
                .abs()
                .clamp(0.001, 1.0);
            final showFront = t >= 0.5;
            return Transform.scale(
              scaleX: scaleX,
              scaleY: 1.0,
              child: showFront ? _buildFront() : _buildBack(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBack() {
    return LayoutBuilder(builder: (_, constraints) {
      final iconSize = min(constraints.maxWidth, constraints.maxHeight) * 0.40;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF112240), Color(0xFF0A192F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: const Color(0xFF1E6FFF).withValues(alpha: 0.30),
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_outlined,
                  color: const Color(0xFF00F5D4), size: iconSize),
              Padding(
                padding: EdgeInsets.only(top: iconSize * 0.04),
                child: Icon(Icons.local_fire_department,
                    color: const Color(0xFF00F5D4), size: iconSize * 0.48),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFront() {
    const matched   = Color(0xFF06D6A0);
    const unmatched = Color(0xFF1E6FFF);
    return LayoutBuilder(builder: (_, constraints) {
      final emojiSize = min(constraints.maxWidth, constraints.maxHeight) * 0.50;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: widget.matched
                ? [const Color(0xFF0D2B1E), const Color(0xFF071612)]
                : [const Color(0xFF112240), const Color(0xFF0A192F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: widget.matched ? matched : unmatched.withValues(alpha: 0.40),
            width: widget.matched ? 2.0 : 1.0,
          ),
          boxShadow: widget.matched
              ? [
                  BoxShadow(
                    color: matched.withValues(alpha: 0.45),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(widget.symbol,
              style: TextStyle(fontSize: emojiSize)),
        ),
      );
    });
  }
}

// ── _StatBadge ──────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── _WinRow ─────────────────────────────────────────────────────────────────

class _WinRow extends StatelessWidget {
  const _WinRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _kMuted, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Confetti ─────────────────────────────────────────────────────────────────

class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(65, (_) => _Particle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_particles, _ctrl.value),
      ),
    );
  }
}

class _Particle {
  _Particle(Random rng)
      : x      = rng.nextDouble(),
        vx     = (rng.nextDouble() - 0.5) * 0.3,
        vy     = 0.2 + rng.nextDouble() * 0.6,
        size   = 5 + rng.nextDouble() * 8,
        rot    = rng.nextDouble() * 2 * pi,
        rotSpd = (rng.nextDouble() - 0.5) * 8,
        color  =
            _kConfettiColors[rng.nextInt(_kConfettiColors.length)];

  final double x, vx, vy, size, rot, rotSpd;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final px = (p.x + p.vx * t) * size.width;
      final py = p.vy * t * size.height;
      if (py > size.height + 20) continue;

      paint.color =
          p.color.withValues(alpha: (1 - t * 0.85).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rot + p.rotSpd * t);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.45),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
