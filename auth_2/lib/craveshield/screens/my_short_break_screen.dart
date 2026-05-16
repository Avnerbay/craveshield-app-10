import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// ── Activity model ────────────────────────────────────────────────────────────

class _Activity {
  const _Activity(this.icon, this.text);
  final IconData icon;
  final String text;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MyShortBreakScreen extends StatefulWidget {
  const MyShortBreakScreen({super.key});
  static const routeName = 'craveMyShortBreakScreen';
  static const routePath = '/crave-my-short-break';

  @override
  State<MyShortBreakScreen> createState() => _MyShortBreakScreenState();
}

class _MyShortBreakScreenState extends State<MyShortBreakScreen>
    with TickerProviderStateMixin {
  // ── Colors ──────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0A192F);
  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);

  // ── Data ────────────────────────────────────────────────────────────────
  static const _presets = [2, 5, 10, 15];

  static const _activities = <_Activity>[
    _Activity(Icons.directions_walk,    'Stand up and stretch'),
    _Activity(Icons.visibility,         'Look out the window for 20 seconds'),
    _Activity(Icons.local_drink,        'Drink a glass of water'),
    _Activity(Icons.air,                'Take 5 deep breaths'),
    _Activity(Icons.accessibility_new,  'Roll your shoulders'),
    _Activity(Icons.bedtime,            'Close your eyes and rest'),
    _Activity(Icons.meeting_room,       'Walk to another room'),
    _Activity(Icons.spa,                'Massage your temples'),
    _Activity(Icons.park,               'Step outside for fresh air'),
    _Activity(Icons.fitness_center,     'Do 10 jumping jacks'),
    _Activity(Icons.music_note,         'Listen to one favorite song'),
    _Activity(Icons.message,            'Text someone you care about'),
    _Activity(Icons.water_drop,         'Wash your face with cold water'),
    _Activity(Icons.cleaning_services,  'Tidy up your desk'),
    _Activity(Icons.rotate_right,       'Do neck rolls slowly'),
    _Activity(Icons.front_hand,         'Stretch your arms overhead'),
    _Activity(Icons.self_improvement,   'Practice 4-7-8 breathing'),
    _Activity(Icons.edit_note,          'Write down 3 things you\'re grateful for'),
    _Activity(Icons.photo,              'Look at a photo that makes you smile'),
    _Activity(Icons.restaurant,         'Eat a healthy snack'),
    _Activity(Icons.sports_gymnastics,  'Do 10 squats'),
    _Activity(Icons.accessibility,      'Touch your toes 5 times'),
    _Activity(Icons.eco,                'Stare at something green or natural'),
    _Activity(Icons.queue_music,        'Hum your favorite tune'),
    _Activity(Icons.waving_hand,        'Wiggle your fingers and toes'),
    _Activity(Icons.directions_walk,    'Take a short mindful walk'),
    _Activity(Icons.ac_unit,            'Splash cold water on your wrists'),
    _Activity(Icons.landscape,          'Visualize your favorite place'),
    _Activity(Icons.calculate,          'Count backwards from 100 by 7s'),
    _Activity(Icons.favorite,           'Send a kind message to someone'),
    _Activity(Icons.window,             'Open a window and breathe deeply'),
  ];

  // ── State ────────────────────────────────────────────────────────────────
  int _selectedMinutes = 5;
  late int _totalSeconds;
  late int _remaining;
  bool _isRunning = false;
  bool _isComplete = false;
  int _activityIndex = 0;

  Timer? _countdown;
  Timer? _activityTimer;

  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _pulseAnim;

  final AudioPlayer _audio = AudioPlayer();

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _totalSeconds = _selectedMinutes * 60;
    _remaining = _totalSeconds;
    _activityIndex = Random().nextInt(_activities.length);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.055).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _activityTimer?.cancel();
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  // ── Timer control ─────────────────────────────────────────────────────────
  void _start() {
    if (_isComplete) {
      _reset();
      return;
    }
    setState(() => _isRunning = true);
    _pulseCtrl.repeat(reverse: true);
    _waveCtrl.repeat();

    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _onComplete();
      } else {
        if (mounted) setState(() => _remaining--);
      }
    });

    _activityTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _nextActivity());
    });
  }

  void _pause() {
    setState(() => _isRunning = false);
    _countdown?.cancel();
    _activityTimer?.cancel();
    _pulseCtrl.stop();
    _waveCtrl.stop();
  }

  void _reset() {
    _countdown?.cancel();
    _activityTimer?.cancel();
    _pulseCtrl.stop();
    _waveCtrl.stop();
    setState(() {
      _remaining = _totalSeconds;
      _isRunning = false;
      _isComplete = false;
      _nextActivity();
    });
  }

  void _selectPreset(int minutes) {
    if (_isRunning) return;
    setState(() {
      _selectedMinutes = minutes;
      _totalSeconds = minutes * 60;
      _remaining = _totalSeconds;
      _isComplete = false;
    });
  }

  void _nextActivity() {
    if (_activities.length <= 1) return;
    int next;
    do {
      next = Random().nextInt(_activities.length);
    } while (next == _activityIndex);
    _activityIndex = next;
  }

  void _onComplete() {
    _countdown?.cancel();
    _activityTimer?.cancel();
    _pulseCtrl.stop();
    _waveCtrl.stop();
    if (mounted) {
      setState(() {
        _remaining = 0;
        _isRunning = false;
        _isComplete = true;
      });
    }
    _playCompletionSound();
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audio.setAsset('assets/audio/calming_voice.mp3');
      await _audio.play();
      await Future.delayed(const Duration(seconds: 4));
      await _audio.stop();
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _timeLabel {
    final m = _remaining ~/ 60;
    final s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get _progress =>
      _totalSeconds > 0 ? 1.0 - (_remaining / _totalSeconds) : 0.0;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            _pause();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'MY SHORT BREAK',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPresets(),
            const SizedBox(height: 20),
            _buildActivityBanner(),
            const SizedBox(height: 8),
            Expanded(child: Center(child: _buildTimerCircle())),
            _buildControls(),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ── Preset chips ──────────────────────────────────────────────────────────
  Widget _buildPresets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _presets.map((m) {
        final sel = m == _selectedMinutes;
        return GestureDetector(
          onTap: () => _selectPreset(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: sel
                  ? _accentDark
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sel
                    ? _accent.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Text(
              '$m min',
              style: TextStyle(
                color: sel ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight:
                    sel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Activity banner ───────────────────────────────────────────────────────
  Widget _buildActivityBanner() {
    final activity = _activities[_activityIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, 0.25), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: GestureDetector(
          onTap: () => setState(() => _nextActivity()),
          child: Container(
            key: ValueKey(_activityIndex),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(activity.icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  activity.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  // ── Timer circle ──────────────────────────────────────────────────────────
  Widget _buildTimerCircle() {
    const circleSize = 230.0;
    const outerPad = 60.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _waveCtrl]),
      builder: (_, __) {
        return SizedBox(
          width: circleSize + outerPad * 2,
          height: circleSize + outerPad * 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding wave rings
              if (_isRunning) ...[
                _waveRing(circleSize, _waveCtrl.value),
                _waveRing(
                    circleSize, (_waveCtrl.value + 0.34) % 1.0),
                _waveRing(
                    circleSize, (_waveCtrl.value + 0.67) % 1.0),
              ],
              // Completion glow
              if (_isComplete)
                Container(
                  width: circleSize + 40,
                  height: circleSize + 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2BC0E4)
                        .withValues(alpha: 0.1),
                  ),
                ),
              // Main circle with pulse scale
              Transform.scale(
                scale: _isRunning ? _pulseAnim.value : 1.0,
                child: CustomPaint(
                  size: const Size(circleSize, circleSize),
                  painter: _RingPainter(
                    progress: _progress,
                    isComplete: _isComplete,
                  ),
                  child: SizedBox(
                    width: circleSize,
                    height: circleSize,
                    child: Center(child: _buildTimerFace()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerFace() {
    if (_isComplete) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌿', style: TextStyle(fontSize: 38)),
          SizedBox(height: 8),
          Text(
            'Break\ncomplete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return Text(
      _timeLabel,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 54,
        fontWeight: FontWeight.w200,
        letterSpacing: 3,
      ),
    );
  }

  Widget _waveRing(double baseSize, double t) {
    final radius = baseSize / 2 + t * 55;
    final opacity = (1.0 - t) * 0.22;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _accent.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }

  // ── Controls ──────────────────────────────────────────────────────────────
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset
        _circleBtn(
          size: 56,
          onTap: _reset,
          child: const Icon(Icons.refresh_rounded,
              color: Colors.white70, size: 24),
          color: Colors.white.withValues(alpha: 0.07),
          borderColor: Colors.white.withValues(alpha: 0.14),
        ),
        const SizedBox(width: 24),
        // Play / Pause
        GestureDetector(
          onTap: _isRunning ? _pause : _start,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0B4EA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _accentDark.withValues(alpha: 0.5),
                  blurRadius: 22,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(
              _isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Invisible mirror for symmetry
        const SizedBox(width: 56, height: 56),
      ],
    );
  }

  Widget _circleBtn({
    required double size,
    required VoidCallback onTap,
    required Widget child,
    required Color color,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.isComplete});
  final double progress;
  final bool isComplete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Fill
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF112240)
        ..style = PaintingStyle.fill,
    );

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = isComplete
              ? const Color(0xFF2BC0E4)
              : const Color(0xFF72B9FF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isComplete != isComplete;
}
