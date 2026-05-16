import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _bg     = Color(0xFF0A192F);
const _card   = Color(0xFF112240);
const _accent = Color(0xFF1E6FFF);
const _muted  = Color(0xFF8892B0);
const _gameSecs  = 60;
const _roundSecs = 5;

enum _Phase { start, playing, end }

class PatternMatchScreen extends StatefulWidget {
  const PatternMatchScreen({super.key});
  static const routeName = 'patternMatchScreen';
  static const routePath = '/crave-pattern-match';

  @override
  State<PatternMatchScreen> createState() => _PatternMatchScreenState();
}

class _PatternMatchScreenState extends State<PatternMatchScreen> {
  final _rng = Random();
  _Phase _phase = _Phase.start;

  int _score       = 0;
  int _timeLeft    = _gameSecs;
  int _roundLeft   = _roundSecs;
  int _totalRounds = 0;
  int _correct     = 0;

  Timer? _gameTimer;
  Timer? _roundTimer;

  // Round state
  int    _oddIndex  = 0;
  Color  _baseColor = const Color(0xFF1E6FFF);
  Color  _oddColor  = const Color(0xFF2BC0E4);
  double _baseSz    = 44;
  double _oddSz     = 44;

  // Flash feedback
  int?  _flashIdx;
  bool  _flashOk = false;

  int get _diff {
    if (_score < 50)  return 0;
    if (_score < 120) return 1;
    if (_score < 220) return 2;
    return 3;
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    super.dispose();
  }

  // ── game flow ───────────────────────────────────────────────────────────────

  void _startGame() {
    setState(() {
      _phase       = _Phase.playing;
      _score       = 0;
      _timeLeft    = _gameSecs;
      _totalRounds = 0;
      _correct     = 0;
    });
    _newRound();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        _roundTimer?.cancel();
        setState(() => _phase = _Phase.end);
      }
    });
  }

  void _newRound() {
    _roundTimer?.cancel();

    const palettes = [
      Color(0xFF1E6FFF),
      Color(0xFF2BC0E4),
      Color(0xFF06D6A0),
      Color(0xFFE63946),
      Color(0xFF8A2BE2),
      Color(0xFFFFD60A),
    ];
    final base = palettes[_rng.nextInt(palettes.length)];
    final hsl  = HSLColor.fromColor(base);

    // Lightness delta shrinks as difficulty rises
    final double delta = switch (_diff) {
      0 => 0.35,
      1 => 0.22,
      2 => 0.13,
      _ => 0.07,
    };
    final shift  = _rng.nextBool() ? delta : -delta;
    final oddL   = (hsl.lightness + shift).clamp(0.1, 0.9);
    final odd    = hsl.withLightness(oddL).toColor();

    // At harder levels, sometimes use size instead of color
    double baseSz = 44, oddSz = 44;
    if (_diff >= 2 && _rng.nextBool()) {
      oddSz = baseSz + (_diff == 2 ? 10.0 : 6.0);
    }

    setState(() {
      _oddIndex  = _rng.nextInt(9);
      _baseColor = base;
      _oddColor  = (_diff >= 2 && oddSz != baseSz) ? base : odd;
      _baseSz    = baseSz;
      _oddSz     = oddSz;
      _flashIdx  = null;
      _roundLeft = _roundSecs;
      _totalRounds++;
    });

    _roundTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _roundLeft--);
      if (_roundLeft <= 0) {
        t.cancel();
        _newRound(); // timeout: no penalty
      }
    });
  }

  void _tap(int idx) {
    if (_phase != _Phase.playing || _flashIdx != null) return;
    _roundTimer?.cancel();

    final ok = idx == _oddIndex;
    HapticFeedback.lightImpact();
    setState(() {
      _flashIdx = idx;
      _flashOk  = ok;
      if (ok) {
        _score += 10;
        _correct++;
      } else {
        _score = (_score - 5).clamp(0, 9999);
      }
    });

    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted || _phase != _Phase.playing) return;
      _newRound();
    });
  }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: switch (_phase) {
          _Phase.start   => _StartView(onStart: _startGame, onBack: () => Navigator.pop(context)),
          _Phase.playing => _buildPlayView(),
          _Phase.end     => _EndView(
              score:    _score,
              total:    _totalRounds,
              correct:  _correct,
              onReplay: _startGame,
              onBack:   () => Navigator.pop(context),
            ),
        },
      ),
    );
  }

  Widget _buildPlayView() {
    final roundProgress = _roundLeft / _roundSecs;
    return Column(
      children: [
        // Header: back | score | timer
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () {
                  _gameTimer?.cancel();
                  _roundTimer?.cancel();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SCORE', style: TextStyle(color: _muted, fontSize: 10, letterSpacing: 1)),
                        Text(
                          '$_score',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TIME', style: TextStyle(color: _muted, fontSize: 10, letterSpacing: 1)),
                        Text(
                          '${_timeLeft}s',
                          style: TextStyle(
                            color: _timeLeft <= 10 ? Colors.redAccent : Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Round countdown bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: roundProgress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                roundProgress > 0.4 ? _accent : Colors.redAccent,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('Tap the odd one out', style: TextStyle(color: _muted, fontSize: 13)),
        ),
        // 3x3 grid
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  itemCount: 9,
                  itemBuilder: (_, i) => _ShapeCell(
                    isOdd:      i == _oddIndex,
                    color:      i == _oddIndex ? _oddColor : _baseColor,
                    size:       i == _oddIndex ? _oddSz    : _baseSz,
                    flashing:   _flashIdx == i,
                    flashOk:    _flashOk,
                    onTap:      () => _tap(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── shape cell ───────────────────────────────────────────────────────────────

class _ShapeCell extends StatelessWidget {
  const _ShapeCell({
    required this.isOdd,
    required this.color,
    required this.size,
    required this.flashing,
    required this.flashOk,
    required this.onTap,
  });

  final bool   isOdd;
  final Color  color;
  final double size;
  final bool   flashing;
  final bool   flashOk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayColor = flashing
        ? (flashOk ? const Color(0xFF06D6A0) : const Color(0xFFE63946))
        : color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: flashing
                ? (flashOk ? const Color(0xFF06D6A0) : const Color(0xFFE63946))
                : Colors.white.withValues(alpha: 0.06),
            width: flashing ? 2 : 1,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width:  size,
            height: size,
            decoration: BoxDecoration(
              color: displayColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: displayColor.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── start view ───────────────────────────────────────────────────────────────

class _StartView extends StatelessWidget {
  const _StartView({required this.onStart, required this.onBack});
  final VoidCallback onStart, onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBack,
          ),
        ),
        const Spacer(),
        const Text('🧩', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 20),
        const Text(
          'Pattern Match',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('Spot the odd one', style: TextStyle(color: _muted, fontSize: 16)),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Column(
            children: [
              _RuleRow(icon: '🔵', text: 'Find the one shape that looks different'),
              SizedBox(height: 10),
              _RuleRow(icon: '⚡', text: '5 seconds per round — no tap = skip, no penalty'),
              SizedBox(height: 10),
              _RuleRow(icon: '🎯', text: '+10 correct  •  −5 wrong'),
              SizedBox(height: 10),
              _RuleRow(icon: '⏱️', text: '60 second session'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: onStart,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A2BE2),
            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.icon, required this.text});
  final String icon, text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }
}

// ── end view ─────────────────────────────────────────────────────────────────

class _EndView extends StatelessWidget {
  const _EndView({
    required this.score,
    required this.total,
    required this.correct,
    required this.onReplay,
    required this.onBack,
  });

  final int score, total, correct;
  final VoidCallback onReplay, onBack;

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0 : ((correct / total) * 100).round();
    final grade    = accuracy >= 80
        ? 'Sharp Eyes! 🎯'
        : accuracy >= 55
            ? 'Good Focus! 👁️'
            : 'Keep Practicing! 💪';

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBack,
          ),
        ),
        const Spacer(),
        Text(grade, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Score: $score  •  Accuracy: $accuracy%',
          style: const TextStyle(color: _muted, fontSize: 15),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatBox(label: 'Score',    value: '$score'),
            const SizedBox(width: 14),
            _StatBox(label: 'Accuracy', value: '$accuracy%'),
            const SizedBox(width: 14),
            _StatBox(label: 'Rounds',   value: '$total'),
          ],
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: onReplay,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A2BE2),
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Play Again', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onBack,
          child: const Text('Back to Games', style: TextStyle(color: _muted)),
        ),
        const Spacer(),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }
}
