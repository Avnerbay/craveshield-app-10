import 'dart:async';
import 'package:flutter/material.dart';
import 'game_scaffold.dart';

class BreathingBurstGame extends StatefulWidget {
  const BreathingBurstGame({super.key});

  @override
  State<BreathingBurstGame> createState() => _BreathingBurstGameState();
}

class _BreathingBurstGameState extends State<BreathingBurstGame>
    with SingleTickerProviderStateMixin {
  static const _phaseSecs = 4;
  static const _roundSecs = 60;
  static const _windowMs = 500;

  late final AnimationController _circle;

  // Game state
  bool _running = false;
  bool _done = false;
  int _score = 0;
  int _combo = 0;
  int _timeLeft = _roundSecs;
  String? _feedback;

  // Phase tracking
  final _stopwatch = Stopwatch();
  Timer? _gameTimer;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _circle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _phaseSecs),
    );
  }

  @override
  void dispose() {
    _circle.dispose();
    _gameTimer?.cancel();
    _feedbackTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _done = false;
      _score = 0;
      _combo = 0;
      _timeLeft = _roundSecs;
      _feedback = null;
    });
    _stopwatch
      ..reset()
      ..start();
    _circle.repeat(reverse: true);
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _finish();
      });
    });
  }

  void _finish() {
    _circle.stop();
    _stopwatch.stop();
    _gameTimer?.cancel();
    setState(() {
      _running = false;
      _done = true;
    });
  }

  void _onTap() {
    if (!_running) return;

    final cycle = _stopwatch.elapsedMilliseconds % (_phaseSecs * 2 * 1000);
    const peakInhale = _phaseSecs * 1000; // ms: 4000
    const peakExhale = _phaseSecs * 2 * 1000; // ms: 8000

    final toInhale = (cycle - peakInhale).abs();
    final toExhale = (cycle - peakExhale).abs().clamp(0, peakExhale);
    final toExhaleWrap = cycle < _windowMs ? cycle : peakExhale;
    final closest = [toInhale, toExhale, toExhaleWrap].reduce((a, b) => a < b ? a : b);

    if (closest <= _windowMs) {
      setState(() {
        _score++;
        _combo++;
        _feedback = _combo >= 3 ? 'Perfect rhythm! 🔥' : '✓ Synced!';
      });
    } else {
      setState(() {
        _combo = 0;
        _feedback = 'Off beat…';
      });
    }
    _feedbackTimer?.cancel();
    _feedbackTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _feedback = null);
    });
  }

  String get _phaseLabel {
    if (!_running) return 'Ready';
    return _circle.status == AnimationStatus.forward ? 'Inhale' : 'Exhale';
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Breathing Burst',
      child: _done ? _buildEnd() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Timer + score row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatPill(label: 'Score', value: '$_score'),
              _StatPill(
                label: 'Time',
                value: '$_timeLeft s',
                highlight: _timeLeft <= 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Feedback flash
        SizedBox(
          height: 28,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _feedback != null
                ? Text(
                    _feedback!,
                    key: ValueKey(_feedback),
                    style: TextStyle(
                      color: _feedback!.contains('🔥')
                          ? const Color(0xFFFFD700)
                          : _feedback!.contains('✓')
                              ? const Color(0xFF00D4FF)
                              : Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
        // Breathing circle
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _circle,
              builder: (_, __) {
                final t = _running ? _circle.value : 0.0;
                final size = 160.0 + 90.0 * t;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF0A84FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF)
                                .withValues(alpha: 0.30 + 0.30 * t),
                            blurRadius: 20 + 20 * t,
                            spreadRadius: 2 + 4 * t,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _phaseLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _running ? 'Tap at each peak ↑↓' : 'Tap START to begin',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // Tap + start buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              if (_running)
                GestureDetector(
                  onTap: _onTap,
                  child: Container(
                    height: 64,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                          color: const Color(0xFF00D4FF).withValues(alpha: 0.6),
                          width: 1.5),
                    ),
                    child: const Text(
                      'TAP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              if (_running) const SizedBox(height: 10),
              GameButton(
                label: _running ? 'STOP' : 'START',
                onTap: _running ? _finish : _start,
                height: 48,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnd() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Your breathing saved you',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You synced $_score times',
              style: const TextStyle(
                color: Color(0xFF00D4FF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            GameButton(
              label: 'PLAY AGAIN',
              onTap: _start,
              height: 52,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Back to games',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    this.highlight = false,
  });
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: highlight ? const Color(0xFFFF6B6B) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
