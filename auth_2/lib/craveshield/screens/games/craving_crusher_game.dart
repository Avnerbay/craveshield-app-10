import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_scaffold.dart';

const _kMonsters = ['🍫', '🚬', '🍺', '🍬'];
const _kQuotes = [
  'You are stronger than any craving.',
  'One moment at a time. You\'ve got this.',
  'Every tap was a step toward freedom.',
  'Cravings pass. Your strength stays.',
  'You just proved you\'re in control.',
];

class CravingCrusherGame extends StatefulWidget {
  const CravingCrusherGame({
    super.key,
    this.emoji,
    this.target = 50,
    this.victoryMessage = 'You beat the craving!',
    this.title = 'Craving Crusher',
  });

  final String? emoji;
  final int target;
  final String victoryMessage;
  final String title;

  @override
  State<CravingCrusherGame> createState() => _CravingCrusherGameState();
}

class _CravingCrusherGameState extends State<CravingCrusherGame>
    with SingleTickerProviderStateMixin {
  int _taps = 0;
  bool _won = false;
  late String _monster;
  late String _quote;
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _reset();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shake = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    _taps = 0;
    _won = false;
    _monster = widget.emoji ??
        _kMonsters[DateTime.now().millisecond % _kMonsters.length];
    _quote = _kQuotes[DateTime.now().millisecond % _kQuotes.length];
  }

  void _tap() {
    if (_won) return;
    HapticFeedback.lightImpact();
    _shakeCtrl.forward(from: 0);
    setState(() {
      _taps++;
      if (_taps >= widget.target) {
        _won = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  double get _shrink {
    // monster goes from 1.0 to 0.15 as taps approach target
    final progress = (_taps / widget.target).clamp(0.0, 1.0);
    return 1.0 - progress * 0.85;
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: widget.title,
      trailing: _won
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(
                '${widget.target - _taps} left',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800),
              ),
            ),
      child: _won ? _buildWin() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _tap(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'TAP TO CRUSH',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shake,
              builder: (_, __) => Transform.translate(
                offset: Offset(_shake.value, 0),
                child: AnimatedScale(
                  scale: _shrink,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  child: Text(
                    _monster,
                    style: const TextStyle(fontSize: 120),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_taps / widget.target).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2BC0E4)),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$_taps / ${widget.target} taps',
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWin() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            widget.victoryMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.07),
              border: Border.all(
                  color: const Color(0xFF2BC0E4).withValues(alpha: 0.3)),
            ),
            child: Text(
              '"$_quote"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2BC0E4),
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          GameButton(
              label: 'PLAY AGAIN',
              onTap: () => setState(_reset)),
        ],
      ),
    );
  }
}
