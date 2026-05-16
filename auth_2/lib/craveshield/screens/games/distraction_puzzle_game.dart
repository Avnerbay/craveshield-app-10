import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_scaffold.dart';

class DistractionPuzzleGame extends StatefulWidget {
  const DistractionPuzzleGame({super.key});

  @override
  State<DistractionPuzzleGame> createState() => _DistractionPuzzleGameState();
}

class _DistractionPuzzleGameState extends State<DistractionPuzzleGame> {
  static const _goal = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  late List<int> _tiles;
  int _moves = 0;
  int _seconds = 0;
  bool _won = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _newGame() {
    _timer?.cancel();
    setState(() {
      _tiles = _shuffle(List.of(_goal));
      _moves = 0;
      _seconds = 0;
      _won = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_won) setState(() => _seconds++);
    });
  }

  // Generate a solvable shuffle by applying random valid moves from goal state.
  List<int> _shuffle(List<int> tiles) {
    final rng = Random();
    for (int i = 0; i < 120; i++) {
      final empty = tiles.indexOf(0);
      final neighbors = _neighbors(empty);
      final n = neighbors[rng.nextInt(neighbors.length)];
      tiles[empty] = tiles[n];
      tiles[n] = 0;
    }
    return tiles;
  }

  List<int> _neighbors(int idx) {
    final row = idx ~/ 3;
    final col = idx % 3;
    final result = <int>[];
    if (row > 0) result.add(idx - 3);
    if (row < 2) result.add(idx + 3);
    if (col > 0) result.add(idx - 1);
    if (col < 2) result.add(idx + 1);
    return result;
  }

  void _onTileTap(int tileIdx) {
    if (_won) return;
    final emptyIdx = _tiles.indexOf(0);
    if (!_neighbors(emptyIdx).contains(tileIdx)) return;
    setState(() {
      _tiles[emptyIdx] = _tiles[tileIdx];
      _tiles[tileIdx] = 0;
      _moves++;
      if (_tiles.join() == _goal.join()) {
        _won = true;
        _timer?.cancel();
      }
    });
  }

  String get _timeStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      title: 'Distraction Puzzle',
      child: _won ? _buildWin() : _buildPuzzle(),
    );
  }

  Widget _buildPuzzle() {
    return Column(
      children: [
        const SizedBox(height: 12),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: 'Moves', value: '$_moves'),
              _StatChip(label: 'Time', value: _timeStr),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Arrange 1–8 in order',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 13,
          ),
        ),
        // Puzzle grid
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (_, i) {
                    final value = _tiles[i];
                    final isEmpty = value == 0;
                    final isCorrect = value != 0 && value == _goal[i];
                    return GestureDetector(
                      onTap: () => _onTileTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: isEmpty
                              ? null
                              : LinearGradient(
                                  colors: isCorrect
                                      ? [
                                          const Color(0xFF48BB78),
                                          const Color(0xFF38A169),
                                        ]
                                      : [
                                          const Color(0xFF6C63FF),
                                          const Color(0xFF4C46CC),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          color: isEmpty
                              ? Colors.white.withValues(alpha: 0.06)
                              : null,
                          boxShadow: isEmpty
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: isEmpty
                            ? null
                            : Text(
                                '$value',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: GameButton(
            label: '🔀  SHUFFLE',
            onTap: _newGame,
            height: 52,
          ),
        ),
      ],
    );
  }

  Widget _buildWin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🧩', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Puzzle solved!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your mind is sharp',
              style: TextStyle(
                color: Color(0xFF48BB78),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You focused through your craving',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(label: 'Moves', value: '$_moves'),
                const SizedBox(width: 16),
                _StatChip(label: 'Time', value: _timeStr),
              ],
            ),
            const SizedBox(height: 32),
            GameButton(label: 'PLAY AGAIN', onTap: _newGame, height: 52),
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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
