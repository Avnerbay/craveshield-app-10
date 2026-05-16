import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_scaffold.dart';

class TapTargetGame extends StatefulWidget {
  const TapTargetGame({super.key});

  @override
  State<TapTargetGame> createState() => _TapTargetGameState();
}

const _kTargetColors = [
  Color(0xFF00E5FF), Color(0xFFFF1F8F), Color(0xFF00FFC8),
  Color(0xFFB14BFF), Color(0xFFFFD23F), Color(0xFFFF7B47),
];

const _kRoundSecs = 30;
const _kTargetLifeMs = 1500;

class _Target {
  _Target({required this.x, required this.y, required this.color})
      : born = DateTime.now();
  final double x, y;
  final Color color;
  final DateTime born;

  double get progress {
    final ms = DateTime.now().difference(born).inMilliseconds;
    return (ms / _kTargetLifeMs).clamp(0.0, 1.0);
  }

  bool get expired => progress >= 1.0;
  double get size => 64.0 * (1.0 - progress);
}

class _TapTargetGameState extends State<TapTargetGame>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late AnimationController _tick;

  _Target? _target;
  int _score = 0;
  int _timeLeft = _kRoundSecs;
  bool _running = false;
  bool _gameOver = false;
  Timer? _roundTimer;
  Timer? _spawnTimer;
  Size? _areaSize;

  @override
  void initState() {
    super.initState();
    _tick = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_checkExpiry)
      ..repeat();
  }

  @override
  void dispose() {
    _tick.dispose();
    _roundTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _checkExpiry() {
    if (_target != null && _target!.expired) {
      setState(() {
        _score = (_score - 1).clamp(-99, 999);
        _target = null;
      });
      _scheduleNext();
    }
  }

  void _start() {
    setState(() {
      _score = 0;
      _timeLeft = _kRoundSecs;
      _running = true;
      _gameOver = false;
      _target = null;
    });
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _endRound();
    });
    _scheduleNext();
  }

  void _endRound() {
    _roundTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _running = false;
      _gameOver = true;
      _target = null;
    });
  }

  void _scheduleNext() {
    if (!_running) return;
    _spawnTimer?.cancel();
    _spawnTimer = Timer(
      Duration(milliseconds: 200 + _rng.nextInt(300)),
      () {
        if (!mounted || !_running || _areaSize == null) return;
        final s = _areaSize!;
        setState(() {
          _target = _Target(
            x: 40 + _rng.nextDouble() * (s.width - 80),
            y: 40 + _rng.nextDouble() * (s.height - 80),
            color: _kTargetColors[_rng.nextInt(_kTargetColors.length)],
          );
        });
      },
    );
  }

  void _tapTarget() {
    if (_target == null || !_running) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _score++;
      _target = null;
    });
    _scheduleNext();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Tap Target',
      trailing: _running
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CountBadge(label: '⏱', value: '$_timeLeft'),
                const SizedBox(width: 8),
                _CountBadge(label: '★', value: '$_score'),
              ],
            )
          : null,
      child: _gameOver
          ? _EndScreen(score: _score, onPlay: _start)
          : !_running
              ? _StartScreen(onPlay: _start)
              : _buildArena(),
    );
  }

  Widget _buildArena() {
    return LayoutBuilder(
      builder: (_, box) {
        _areaSize = box.biggest;
        return AnimatedBuilder(
          animation: _tick,
          builder: (_, __) {
            final t = _target;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Stack(
                children: [
                  if (t != null)
                    Positioned(
                      left: t.x - t.size / 2,
                      top: t.y - t.size / 2,
                      child: GestureDetector(
                        onTap: _tapTarget,
                        child: Container(
                          width: t.size,
                          height: t.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.color.withValues(
                                alpha: (1.0 - t.progress * 0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: t.color.withValues(
                                    alpha: 0.5 * (1.0 - t.progress)),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StartScreen extends StatelessWidget {
  const _StartScreen({required this.onPlay});
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          const Text('Tap the Target',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'Hit the circle before it shrinks away.\n30 seconds. Miss = –1 point.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.5),
          ),
          const SizedBox(height: 32),
          GameButton(label: 'START', onTap: onPlay),
        ],
      ),
    );
  }
}

class _EndScreen extends StatelessWidget {
  const _EndScreen({required this.score, required this.onPlay});
  final int score;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(score > 10 ? '🏆' : '🎯',
              style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('Time\'s up!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text('Score: $score',
              style: const TextStyle(
                  color: Color(0xFF2BC0E4),
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 32),
          GameButton(label: 'PLAY AGAIN', onTap: onPlay),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text('$label $value',
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}
