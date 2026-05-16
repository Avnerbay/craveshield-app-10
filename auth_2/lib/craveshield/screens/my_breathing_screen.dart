import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class _Technique {
  const _Technique({
    required this.name,
    required this.inhale,
    this.hold = 0,
    required this.exhale,
    this.hold2 = 0,
    this.isCustom = false,
  });

  final String name;
  final int inhale;
  final int hold;
  final int exhale;
  final int hold2;
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'name': name,
        'inhale': inhale,
        'hold': hold,
        'exhale': exhale,
        'hold2': hold2,
      };

  factory _Technique.fromJson(Map<String, dynamic> j) => _Technique(
        name: j['name'] as String,
        inhale: (j['inhale'] as num).toInt(),
        hold: ((j['hold'] as num?) ?? 0).toInt(),
        exhale: (j['exhale'] as num).toInt(),
        hold2: ((j['hold2'] as num?) ?? 0).toInt(),
        isCustom: true,
      );

  String get subtitle {
    final parts = <String>['${inhale}s inhale'];
    if (hold > 0) parts.add('${hold}s hold');
    parts.add('${exhale}s exhale');
    if (hold2 > 0) parts.add('${hold2}s hold');
    return parts.join(' · ');
  }
}

enum _Phase { inhale, hold, exhale, hold2 }

// ── Screen ────────────────────────────────────────────────────────────────────

class MyBreathingScreen extends StatefulWidget {
  const MyBreathingScreen({super.key});

  static const routeName = 'craveMyBreathing';
  static const routePath = '/crave-my-breathing';

  @override
  State<MyBreathingScreen> createState() => _MyBreathingScreenState();
}

class _MyBreathingScreenState extends State<MyBreathingScreen>
    with TickerProviderStateMixin {
  static const _prefsKey = 'custom_breathing_techniques';

  static const _builtIn = [
    _Technique(name: '4-7-8', inhale: 4, hold: 7, exhale: 8),
    _Technique(name: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, hold2: 4),
    _Technique(name: 'Deep Breathing', inhale: 6, exhale: 6),
  ];

  List<_Technique> _techniques = List.from(_builtIn);
  int _selectedIndex = 0;

  _Technique get _selected => _techniques[_selectedIndex];

  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final AnimationController _rippleCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _glowCtrl;
  late final List<_Particle> _particles;

  _Phase _phase = _Phase.inhale;
  int _secondsLeft = 4;
  bool _running = false;
  bool _btnPressed = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _selected.inhale;

    _ctrl = AnimationController(vsync: this, value: 0);
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    final rng = Random(42);
    _particles = List.generate(
      12,
      (_) => _Particle(
        x: rng.nextDouble(),
        speed: 0.6 + rng.nextDouble() * 0.8,
        offset: rng.nextDouble(),
        size: 2.0 + rng.nextDouble() * 3.0,
        alpha: 0.3 + rng.nextDouble() * 0.5,
      ),
    );

    _loadCustomTechniques();
  }

  Future<void> _loadCustomTechniques() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => _Technique.fromJson(e as Map<String, dynamic>))
          .toList();
      if (mounted) setState(() => _techniques = [..._builtIn, ...list]);
    } catch (_) {}
  }

  Future<void> _saveCustomTechniques() async {
    final prefs = await SharedPreferences.getInstance();
    final custom = _techniques.where((t) => t.isCustom).toList();
    await prefs.setString(
        _prefsKey, jsonEncode(custom.map((t) => t.toJson()).toList()));
  }

  void _selectTechnique(int index) {
    if (_running) _stop();
    setState(() {
      _selectedIndex = index;
      _phase = _Phase.inhale;
      _secondsLeft = _techniques[index].inhale;
    });
  }

  void _addCustomTechnique(_Technique t) {
    setState(() => _techniques = [..._techniques, t]);
    _saveCustomTechniques();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _rippleCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _rippleCtrl.repeat();
    _particleCtrl.repeat();
    _glowCtrl.repeat(reverse: true);
    _runPhase(_Phase.inhale);
  }

  void _stop() {
    setState(() => _running = false);
    _rippleCtrl.stop();
    _rippleCtrl.reset();
    _particleCtrl.stop();
    _particleCtrl.reset();
    _glowCtrl.stop();
    _glowCtrl.reset();
    _ctrl
        .animateTo(0,
            duration: const Duration(milliseconds: 600), curve: Curves.easeOut)
        .then((_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.inhale;
        _secondsLeft = _selected.inhale;
      });
    });
  }

  Future<void> _runPhase(_Phase phase) async {
    if (!mounted || !_running) return;
    final tech = _selected;
    final secs = _phaseSecs(phase, tech);

    if (secs == 0) {
      _runPhase(_nextPhase(phase, tech));
      return;
    }

    setState(() {
      _phase = phase;
      _secondsLeft = secs;
    });

    switch (phase) {
      case _Phase.inhale:
        _ctrl.duration = Duration(seconds: secs);
        _ctrl.forward(from: 0);
      case _Phase.exhale:
        _ctrl.duration = Duration(seconds: secs);
        _ctrl.reverse(from: 1);
      case _Phase.hold:
      case _Phase.hold2:
        break;
    }

    for (int i = secs; i > 0; i--) {
      if (!mounted || !_running) return;
      setState(() => _secondsLeft = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_running) return;
    _runPhase(_nextPhase(phase, tech));
  }

  int _phaseSecs(_Phase p, _Technique t) => switch (p) {
        _Phase.inhale => t.inhale,
        _Phase.hold => t.hold,
        _Phase.exhale => t.exhale,
        _Phase.hold2 => t.hold2,
      };

  _Phase _nextPhase(_Phase p, _Technique t) => switch (p) {
        _Phase.inhale => t.hold > 0 ? _Phase.hold : _Phase.exhale,
        _Phase.hold => _Phase.exhale,
        _Phase.exhale => t.hold2 > 0 ? _Phase.hold2 : _Phase.inhale,
        _Phase.hold2 => _Phase.inhale,
      };

  String get _phaseLabel => switch (_phase) {
        _Phase.inhale => 'INHALE',
        _Phase.hold => 'HOLD',
        _Phase.exhale => 'EXHALE',
        _Phase.hold2 => 'HOLD',
      };

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddTechniqueDialog(onAdd: _addCustomTechnique),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03122D),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF06265A), Color(0xFF0E4FA8), Color(0xFF062B6D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    children: [
                      // ── Back button ────────────────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back',
                          color: Colors.white,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Technique selector ─────────────────────────────
                      SizedBox(
                        height: 200,
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (int i = 0; i < _techniques.length; i++)
                              _TechniqueCard(
                                technique: _techniques[i],
                                isSelected: i == _selectedIndex,
                                onTap: () => _selectTechnique(i),
                              ),
                            _TechniqueCard(
                              isAdd: true,
                              onTap: _showAddDialog,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Title ──────────────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _selected.name,
                          key: ValueKey(_selected.name),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Subtitle (durations) ───────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _selected.subtitle,
                          key: ValueKey(_selected.subtitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.60),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Breathing circle + particles ───────────────────
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AnimatedBuilder(
                                animation: _particleCtrl,
                                builder: (_, __) => CustomPaint(
                                  painter: _ParticlePainter(
                                    progress: _particleCtrl.value,
                                    particles: _particles,
                                    visible: _running,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: AnimatedBuilder(
                                animation: Listenable.merge(
                                    [_scale, _rippleCtrl, _glowCtrl]),
                                builder: (context, _) {
                                  final t = _scale.value;
                                  final g = _glowCtrl.value;
                                  final circleSize = 170.0 + 70.0 * t;
                                  final glowSize = circleSize + 60.0;
                                  final showRipples =
                                      _running && _phase == _Phase.inhale;
                                  return SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedOpacity(
                                          opacity: showRipples ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 400),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: List.generate(3, (i) {
                                              final ringT = (_rippleCtrl.value + i / 3.0) % 1.0;
                                              final ringSize = 240.0 + 90.0 * ringT;
                                              final ringAlpha = (1.0 - ringT) * 0.25;
                                              return Container(
                                                width: ringSize,
                                                height: ringSize,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(0xFF2BC0E4).withValues(alpha: ringAlpha),
                                                    width: 1.5,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        Container(
                                          width: glowSize,
                                          height: glowSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(0xFF2BC0E4).withValues(alpha: 0.14 + 0.14 * t),
                                                const Color(0xFF2BC0E4).withValues(alpha: 0),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF2BC0E4).withValues(alpha: 0.30 + 0.30 * t),
                                                blurRadius: 20 + 20 * t,
                                                spreadRadius: 2 + 4 * t,
                                              ),
                                              BoxShadow(
                                                color: const Color(0xFF2BC0E4).withValues(alpha: 0.14 + 0.12 * g),
                                                blurRadius: 50 + 20 * g,
                                                spreadRadius: 0,
                                              ),
                                              BoxShadow(
                                                color: const Color(0xFF1B5FCB).withValues(alpha: 0.08 + 0.08 * t),
                                                blurRadius: 85 + 25 * g,
                                                spreadRadius: -5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 350),
                                              child: Text(
                                                _running ? _phaseLabel : 'READY',
                                                key: ValueKey(_running ? _phaseLabel : 'READY'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 2.5,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Opacity(
                                              opacity: _running ? 1.0 : 0.0,
                                              child: Text(
                                                '$_secondsLeft',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w900,
                                                  height: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Phase chips (dynamic per technique) ────────────
                      _PhaseChips(
                          technique: _selected, phase: _phase, running: _running),
                      const SizedBox(height: 20),

                      // ── START / STOP button ────────────────────────────
                      GestureDetector(
                        onTapDown: (_) => setState(() => _btnPressed = true),
                        onTapUp: (_) {
                          setState(() => _btnPressed = false);
                          _running ? _stop() : _start();
                        },
                        onTapCancel: () => setState(() => _btnPressed = false),
                        child: AnimatedScale(
                          scale: _btnPressed ? 0.97 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            height: 58,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2BC0E4).withValues(alpha: .30),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _running ? 'STOP' : 'START BREATHING',
                                key: ValueKey(_running),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Technique card ─────────────────────────────────────────────────────────────

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({
    this.technique,
    this.isSelected = false,
    this.isAdd = false,
    required this.onTap,
  });

  final _Technique? technique;
  final bool isSelected;
  final bool isAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFF2BC0E4).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.07),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2BC0E4)
                : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: isAdd
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white70, size: 22),
                  SizedBox(height: 2),
                  Text('Upload\nYours',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technique!.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    technique!.subtitle,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2BC0E4)
                          : Colors.white38,
                      fontSize: 9,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Phase chips ────────────────────────────────────────────────────────────────

class _PhaseChips extends StatelessWidget {
  const _PhaseChips({
    required this.technique,
    required this.phase,
    required this.running,
  });

  final _Technique technique;
  final _Phase phase;
  final bool running;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (label: 'Inhale', secs: technique.inhale, phase: _Phase.inhale),
      if (technique.hold > 0)
        (label: 'Hold', secs: technique.hold, phase: _Phase.hold),
      (label: 'Exhale', secs: technique.exhale, phase: _Phase.exhale),
      if (technique.hold2 > 0)
        (label: 'Hold', secs: technique.hold2, phase: _Phase.hold2),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: chips.map((c) {
        final isActive = running && phase == c.phase;
        return AnimatedOpacity(
          opacity: isActive ? 1.0 : 0.55,
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFF2BC0E4)
                      : const Color(0xFF7BA8D8),
                  fontSize: isActive ? 28 : 26,
                  fontWeight: FontWeight.w900,
                ),
                child: Text('${c.secs}'),
              ),
              Text(
                c.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Add technique dialog ───────────────────────────────────────────────────────

class _AddTechniqueDialog extends StatefulWidget {
  const _AddTechniqueDialog({required this.onAdd});
  final void Function(_Technique) onAdd;

  @override
  State<_AddTechniqueDialog> createState() => _AddTechniqueDialogState();
}

class _AddTechniqueDialogState extends State<_AddTechniqueDialog> {
  final _nameCtrl = TextEditingController();
  final _inhaleCtrl = TextEditingController(text: '4');
  final _holdCtrl = TextEditingController(text: '0');
  final _exhaleCtrl = TextEditingController(text: '4');
  final _hold2Ctrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _inhaleCtrl.dispose();
    _holdCtrl.dispose();
    _exhaleCtrl.dispose();
    _hold2Ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final inhale = int.tryParse(_inhaleCtrl.text) ?? 4;
    final hold = int.tryParse(_holdCtrl.text) ?? 0;
    final exhale = int.tryParse(_exhaleCtrl.text) ?? 4;
    final hold2 = int.tryParse(_hold2Ctrl.text) ?? 0;
    if (inhale < 1 || exhale < 1) return;
    widget.onAdd(_Technique(
      name: name,
      inhale: inhale,
      hold: hold,
      exhale: exhale,
      hold2: hold2,
      isCustom: true,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0E2A5A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Upload Yours',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Field(ctrl: _nameCtrl, label: 'Name', hint: 'e.g. My Technique'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Field(ctrl: _inhaleCtrl, label: 'Inhale (s)', isNum: true)),
              const SizedBox(width: 8),
              Expanded(child: _Field(ctrl: _holdCtrl, label: 'Hold (s)', isNum: true)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Field(ctrl: _exhaleCtrl, label: 'Exhale (s)', isNum: true)),
              const SizedBox(width: 8),
              Expanded(child: _Field(ctrl: _hold2Ctrl, label: 'Exhale Hold (s)', isNum: true)),
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2BC0E4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submit,
          child: const Text('Add',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
      {required this.ctrl, required this.label, this.hint, this.isNum = false});
  final TextEditingController ctrl;
  final String label;
  final String? hint;
  final bool isNum;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ── Particle data ─────────────────────────────────────────────────────────────

class _Particle {
  const _Particle({
    required this.x,
    required this.speed,
    required this.offset,
    required this.size,
    required this.alpha,
  });

  final double x;
  final double speed;
  final double offset;
  final double size;
  final double alpha;
}

// ── Particle painter ──────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.progress,
    required this.particles,
    required this.visible,
  });

  final double progress;
  final List<_Particle> particles;
  final bool visible;

  @override
  void paint(Canvas canvas, Size size) {
    if (!visible) return;
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final t = (progress * p.speed + p.offset) % 1.0;
      final opacity =
          t < 0.15 ? t / 0.15 : (t > 0.75 ? (1.0 - t) / 0.25 : 1.0);
      final y = size.height * (1.0 - t);
      final x = size.width * p.x + sin(t * pi * 2 + p.offset * pi) * 12;
      paint
        ..color = const Color(0xFF2BC0E4).withValues(alpha: opacity * p.alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.visible != visible;
}
