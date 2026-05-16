import 'dart:async';
import 'package:flutter/material.dart';
import 'game_scaffold.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

const _kSymbols = ['🌊','🔥','⭐','🌈','🦋','🍃','🎯','💎'];

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;

  int? _firstIdx;
  bool _locked = false;
  int _moves = 0;
  int _seconds = 0;
  bool _won = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _init() {
    final deck = [..._kSymbols, ..._kSymbols]..shuffle();
    _cards   = deck;
    _flipped = List.filled(16, false);
    _matched = List.filled(16, false);
    _firstIdx = null;
    _locked = false;
    _moves = 0;
    _seconds = 0;
    _won = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_won) setState(() => _seconds++);
    });
  }

  void _tap(int i) {
    if (_locked || _flipped[i] || _matched[i]) return;
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
        _matched[i] = true;
      });
      if (_matched.every((m) => m)) {
        _timer?.cancel();
        setState(() => _won = true);
      }
    } else {
      _locked = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _flipped[first] = false;
          _flipped[i] = false;
          _locked = false;
        });
      });
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Memory Match',
      trailing: _won
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Stat(label: 'moves', value: '$_moves'),
                const SizedBox(width: 10),
                _Stat(label: 'time', value: _fmt(_seconds)),
              ],
            ),
      child: _won ? _WinScreen(moves: _moves, seconds: _seconds, onPlay: () => setState(_init)) : _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 16,
        itemBuilder: (_, i) => _CardTile(
          symbol: _cards[i],
          flipped: _flipped[i],
          matched: _matched[i],
          onTap: () => _tap(i),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.symbol,
    required this.flipped,
    required this.matched,
    required this.onTap,
  });
  final String symbol;
  final bool flipped, matched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: matched
              ? const LinearGradient(
                  colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)])
              : flipped
                  ? LinearGradient(colors: [
                      const Color(0xFF2F7BFF).withValues(alpha: 0.35),
                      const Color(0xFF062B6D).withValues(alpha: 0.6),
                    ])
                  : null,
          color: flipped || matched
              ? null
              : Colors.white.withValues(alpha: 0.10),
          border: Border.all(
            color: matched
                ? const Color(0xFF2BC0E4)
                : Colors.white.withValues(alpha: 0.18),
            width: matched ? 1.5 : 1,
          ),
          boxShadow: matched
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF2BC0E4).withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: flipped || matched
            ? Text(symbol, style: const TextStyle(fontSize: 28))
            : const Icon(Icons.question_mark_rounded,
                color: Colors.white38, size: 22),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WinScreen extends StatelessWidget {
  const _WinScreen({required this.moves, required this.seconds, required this.onPlay});
  final int moves, seconds;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('You matched them all!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(
            '$moves moves · ${mins}m ${secs}s',
            style: const TextStyle(
                color: Color(0xFF2BC0E4),
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 32),
          GameButton(label: 'PLAY AGAIN', onTap: onPlay),
        ],
      ),
    );
  }
}
