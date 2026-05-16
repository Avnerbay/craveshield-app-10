import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_scaffold.dart';

class CalmSortingGame extends StatefulWidget {
  const CalmSortingGame({super.key});

  @override
  State<CalmSortingGame> createState() => _CalmSortingGameState();
}

// Each feeling maps to a bucket index (0=Breathe, 1=Walk, 2=Drink Water)
const _kFeelings = {
  'stressed':   0, 'overwhelmed': 0, 'anxious':   0,
  'tense':      0, 'panicky':     0,
  'restless':   1, 'bored':       1, 'frustrated': 1,
  'irritable':  1, 'agitated':    1,
  'thirsty':    2, 'drained':     2, 'tired':      2,
  'foggy':      2, 'sluggish':    2,
};

const _kBuckets = ['Breathe 🫁', 'Walk 🚶', 'Drink Water 💧'];
const _kBucketColors = [
  Color(0xFF2BC0E4), Color(0xFF4CAF50), Color(0xFF7BA8D8),
];

class _FeelingCard {
  _FeelingCard({required this.word, required this.correctBucket})
      : id = _FeelingCard._nextId++;
  static int _nextId = 0;
  final int id;
  final String word;
  final int correctBucket;
  Offset position = Offset.zero;
}

class _CalmSortingGameState extends State<CalmSortingGame> {
  final _rng = Random();
  late List<_FeelingCard> _deck;
  int _sorted = 0;
  int _correct = 0;
  // bucket glow: index → glow intensity 0..1
  final _bucketGlow = [0.0, 0.0, 0.0];

  final _allFeelings = _kFeelings.entries.toList();

  @override
  void initState() {
    super.initState();
    _buildDeck();
  }

  void _buildDeck() {
    final shuffled = [..._allFeelings]..shuffle(_rng);
    _deck = shuffled
        .take(10)
        .map((e) => _FeelingCard(word: e.key, correctBucket: e.value))
        .toList();
    _sorted = 0;
    _correct = 0;
    for (int i = 0; i < 3; i++) {
      _bucketGlow[i] = 0.0;
    }
  }

  _FeelingCard? get _current =>
      _sorted < _deck.length ? _deck[_sorted] : null;

  void _dropOnBucket(int bucketIdx) {
    final card = _current;
    if (card == null) return;
    final isCorrect = card.correctBucket == bucketIdx;
    setState(() {
      _sorted++;
      if (isCorrect) {
        _correct++;
        _bucketGlow[bucketIdx] = 1.0;
      }
    });
    // Fade glow
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _bucketGlow[bucketIdx] = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _current;
    final done = _sorted >= _deck.length;

    return GameScaffold(
      title: 'Calm Sorting',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Text('$_correct / ${_deck.length}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800)),
      ),
      child: done
          ? _DoneScreen(
              correct: _correct,
              total: _deck.length,
              onPlay: () => setState(_buildDeck),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Falling card area
                  Expanded(
                    flex: 3,
                    child: current == null
                        ? const SizedBox()
                        : Center(
                            child: _DraggableCard(
                              key: ValueKey(current.id),
                              word: current.word,
                              onDropped: _dropOnBucket,
                              bucketPositions: _computeBucketPositions(context),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  // Bucket row
                  Row(
                    children: List.generate(
                      3,
                      (i) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 6,
                              right: i == 2 ? 0 : 6),
                          child: _Bucket(
                            label: _kBuckets[i],
                            color: _kBucketColors[i],
                            glow: _bucketGlow[i],
                            index: i,
                            onDrop: _dropOnBucket,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Approximate bucket center positions (used for drag-snap logic)
  List<Offset> _computeBucketPositions(BuildContext context) {
    // We return placeholder; actual detection is done in _Bucket via DragTarget
    return [Offset.zero, Offset.zero, Offset.zero];
  }
}

class _DraggableCard extends StatefulWidget {
  const _DraggableCard({
    super.key,
    required this.word,
    required this.onDropped,
    required this.bucketPositions,
  });
  final String word;
  final ValueChanged<int> onDropped;
  final List<Offset> bucketPositions;

  @override
  State<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<_DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -6, end: 6).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: -1, // bucket index resolved by DragTarget
      feedback: _CardWidget(word: widget.word, dragging: true),
      childWhenDragging: Opacity(
          opacity: 0.3, child: _CardWidget(word: widget.word)),
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        ),
        child: _CardWidget(word: widget.word),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  const _CardWidget({required this.word, this.dragging = false});
  final String word;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2F7BFF).withValues(alpha: 0.25),
              const Color(0xFF062B6D).withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
              color: const Color(0xFF2BC0E4).withValues(alpha: 0.5),
              width: 1.5),
          boxShadow: dragging
              ? [
                  BoxShadow(
                    color: const Color(0xFF2BC0E4).withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Text(
          word,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Bucket extends StatelessWidget {
  const _Bucket({
    required this.label,
    required this.color,
    required this.glow,
    required this.index,
    required this.onDrop,
  });
  final String label;
  final Color color;
  final double glow;
  final int index;
  final ValueChanged<int> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (_) => onDrop(index),
      builder: (_, candidates, __) {
        final hovering = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: hovering
                ? color.withValues(alpha: 0.25)
                : color.withValues(alpha: 0.10),
            border: Border.all(
              color: glow > 0.5
                  ? color
                  : hovering
                      ? color.withValues(alpha: 0.8)
                      : color.withValues(alpha: 0.3),
              width: glow > 0.5 ? 2 : 1,
            ),
            boxShadow: glow > 0
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: glow * 0.45),
                      blurRadius: 16 * glow,
                      spreadRadius: 2 * glow,
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        );
      },
    );
  }
}

class _DoneScreen extends StatelessWidget {
  const _DoneScreen(
      {required this.correct, required this.total, required this.onPlay});
  final int correct, total;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final pct = (correct / total * 100).round();
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pct >= 80 ? '🌿' : '🌱',
              style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('Well done!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Text('$correct out of $total sorted correctly',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF2BC0E4),
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Recognising your feelings is the first step.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),
          GameButton(label: 'PLAY AGAIN', onTap: onPlay),
        ],
      ),
    );
  }
}
