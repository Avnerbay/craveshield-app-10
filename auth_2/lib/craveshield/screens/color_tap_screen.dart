import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── palette ────────────────────────────────────────────────────────────────

const _bg     = Color(0xFF0A192F);
const _card   = Color(0xFF112240);
const _accent = Color(0xFF1E6FFF);
const _muted  = Color(0xFF8892B0);

// ── game colors ────────────────────────────────────────────────────────────

class _GameColor {
  const _GameColor(this.label, this.value);
  final String label;
  final Color value;
}

const _gameColors = [
  _GameColor('RED',    Color(0xFFE63946)),
  _GameColor('BLUE',   Color(0xFF1E6FFF)),
  _GameColor('GREEN',  Color(0xFF06D6A0)),
  _GameColor('YELLOW', Color(0xFFFFD60A)),
];

// ── screen ─────────────────────────────────────────────────────────────────

enum _Phase { start, playing, end }

class ColorTapScreen extends StatefulWidget {
  const ColorTapScreen({super.key});
  static const routeName = 'colorTapScreen';
  static const routePath = '/crave-color-tap';

  @override
  State<ColorTapScreen> createState() => _ColorTapScreenState();
}

class _ColorTapScreenState extends State<ColorTapScreen>
    with SingleTickerProviderStateMixin {
  static const _bestKey    = 'color_tap_best_score';
  static const _gameSecs   = 60;
  static const _flashMs    = 280;

  final _rng = Random();

  _Phase _phase = _Phase.start;
  int _score      = 0;
  int _timeLeft   = _gameSecs;
  int _totalTaps  = 0;
  int _correctTaps = 0;
  int _bestScore  = 0;
  bool _newBest   = false;

  // current round word / ink
  _GameColor _word = _gameColors[0];
  _GameColor _ink  = _gameColors[1];

  // flash feedback
  Color? _borderColor;

  // timers
  Timer? _gameTimer;
  Timer? _wordTimer;
  Timer? _flashTimer;

  // word entrance animation
  late AnimationController _wordCtrl;
  late Animation<double>   _wordScale;

  @override
  void initState() {
    super.initState();
    _wordCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _wordScale = _wordCtrl.drive(
      CurveTween(curve: Curves.elasticOut),
    );
    _loadBest();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _wordTimer?.cancel();
    _flashTimer?.cancel();
    _wordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _bestScore = p.getInt(_bestKey) ?? 0);
  }

  Future<void> _saveBest(int score) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_bestKey, score);
  }

  // ── word timing: 2.0s at start, ramps down to 0.8s at score 100+ ──────────

  double get _wordSecs => max(0.8, 2.0 - (max(0, _score) / 100.0) * 1.2);

  // ── game flow ──────────────────────────────────────────────────────────────

  void _startGame() {
    _gameTimer?.cancel();
    _wordTimer?.cancel();
    setState(() {
      _phase      = _Phase.playing;
      _score      = 0;
      _timeLeft   = _gameSecs;
      _totalTaps  = 0;
      _correctTaps = 0;
      _newBest    = false;
      _borderColor = null;
    });
    _nextWord();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endGame();
    });
  }

  void _nextWord() {
    if (!mounted || _phase != _Phase.playing) return;
    final meaning = _gameColors[_rng.nextInt(_gameColors.length)];
    _GameColor ink;
    do { ink = _gameColors[_rng.nextInt(_gameColors.length)]; }
    while (ink.label == meaning.label);

    setState(() { _word = meaning; _ink = ink; });
    _wordCtrl.forward(from: 0);

    _wordTimer?.cancel();
    _wordTimer = Timer(
      Duration(milliseconds: (_wordSecs * 1000).round()),
      _nextWord,
    );
  }

  void _onColorTap(_GameColor tapped) {
    if (_phase != _Phase.playing) return;
    _wordTimer?.cancel();

    final correct = tapped.label == _ink.label;
    _totalTaps++;
    if (correct) _correctTaps++;
    HapticFeedback.lightImpact();

    _flashTimer?.cancel();
    setState(() {
      _score += correct ? 10 : -5;
      _borderColor = correct ? const Color(0xFF06D6A0) : const Color(0xFFE63946);
    });
    _flashTimer = Timer(const Duration(milliseconds: _flashMs), () {
      if (mounted) setState(() => _borderColor = null);
    });

    _nextWord();
  }

  void _endGame() {
    _gameTimer?.cancel();
    _wordTimer?.cancel();
    _gameTimer = null;
    _wordTimer = null;

    final beat = _score > _bestScore;
    if (beat) { _bestScore = _score; _saveBest(_score); }
    setState(() { _phase = _Phase.end; _newBest = beat; });
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: switch (_phase) {
          _Phase.start   => _buildStart(),
          _Phase.playing => _buildPlaying(),
          _Phase.end     => _buildEnd(),
        },
      ),
    );
  }

  // ── start screen ───────────────────────────────────────────────────────────

  Widget _buildStart() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),

          // title
          const Text(
            'COLOR TAP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the COLOR of the word,\nnot what it says.',
            style: TextStyle(color: _muted, fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // example illustration card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                const Text(
                  'For example:',
                  style: TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                // "RED" in blue ink
                const Text(
                  'RED',
                  style: TextStyle(
                    color: Color(0xFF1E6FFF),
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '← Tap this',
                      style: TextStyle(color: _muted, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E6FFF),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E6FFF).withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'BLUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'The ink is BLUE — ignore the word, tap Blue',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          if (_bestScore > 0) ...[
            Text(
              'Best: $_bestScore pts',
              style: const TextStyle(color: _muted, fontSize: 14),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── playing screen ─────────────────────────────────────────────────────────

  Widget _buildPlaying() {
    return Stack(
      children: [
        // flash border overlay
        if (_borderColor != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: _borderColor!, width: 5),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 24, 32),
          child: Column(
            children: [
              // score + timer row (back button on left)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SCORE',
                        style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 1),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TIME',
                        style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 1),
                      ),
                      Text(
                        '$_timeLeft',
                        style: TextStyle(
                          color: _timeLeft <= 10
                              ? const Color(0xFFE63946)
                              : Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // hint
              const Text(
                'What COLOR is the word?',
                style: TextStyle(color: _muted, fontSize: 13, letterSpacing: 0.5),
              ),
              const SizedBox(height: 24),

              // the word in its ink color
              ScaleTransition(
                scale: _wordScale,
                child: Text(
                  _word.label,
                  style: TextStyle(
                    color: _ink.value,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const Spacer(),

              // 2×2 color button grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 2.4,
                children: _gameColors.map((c) => _ColorBtn(
                  gameColor: c,
                  onTap: () => _onColorTap(c),
                )).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ── end screen ─────────────────────────────────────────────────────────────

  Widget _buildEnd() {
    final accuracy = _totalTaps > 0
        ? (_correctTaps / _totalTaps * 100).round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Mindful Focus! 🎯',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'You kept your eyes on what matters.',
            style: TextStyle(color: _muted, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Text(
                  '$_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'points',
                  style: TextStyle(color: _muted, fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat(label: 'Accuracy', value: '$accuracy%'),
                    _Stat(label: 'Correct',  value: '$_correctTaps'),
                    _Stat(label: 'Taps',     value: '$_totalTaps'),
                  ],
                ),
                const SizedBox(height: 20),
                // best score row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _newBest
                        ? const Color(0xFF06D6A0).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _newBest
                          ? const Color(0xFF06D6A0).withValues(alpha: 0.4)
                          : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _newBest
                        ? [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFF06D6A0), size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'New best!',
                              style: TextStyle(
                                color: Color(0xFF06D6A0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]
                        : [
                            Text(
                              'Best: $_bestScore pts',
                              style: const TextStyle(color: _muted),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Games',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── color tap button ───────────────────────────────────────────────────────

class _ColorBtn extends StatelessWidget {
  const _ColorBtn({required this.gameColor, required this.onTap});
  final _GameColor gameColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: gameColor.value,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: gameColor.value.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            gameColor.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}

// ── end-screen stat item ───────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}
