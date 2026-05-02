import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/memory_item.dart';
import '../services/memory_vault_service.dart';
import 'memory_vault_screen.dart';

class EmergencyMemoryScreen extends StatefulWidget {
  const EmergencyMemoryScreen({super.key});

  static const routeName = 'craveEmergencyMemory';
  static const routePath = '/crave-emergency-memory';

  @override
  State<EmergencyMemoryScreen> createState() => _EmergencyMemoryScreenState();
}

class _EmergencyMemoryScreenState extends State<EmergencyMemoryScreen> {
  List<MemoryItem> _items = [];
  bool _loading = true;
  late PageController _pageCtrl;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  Timer? _imageTimer;
  VoidCallback? _videoEndListener;
  VideoPlayerController? _listeningCtrl;

  static const _motivations = [
    'This is who you\'re doing it for ❤️',
    'Stay strong. They need you.',
    'You\'ve got this. One moment at a time.',
    'Your family believes in you.',
    'Be present for the ones you love.',
  ];
  int _motivationIndex = 0;
  bool _motivationVisible = true;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    final items = await MemoryVaultService.instance.loadItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
    if (_items.isNotEmpty) {
      _initController(0);
      if (_items.length > 1) _initController(1);
      _startCurrentPage();
    }
  }

  Future<void> _initController(int index) async {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].type != MemoryType.video) return;
    if (_controllers.containsKey(index)) return;

    final item = _items[index];
    final ctrl = item.isDemo
        ? VideoPlayerController.asset(item.filePath)
        : VideoPlayerController.file(File(item.filePath));
    _controllers[index] = ctrl;

    await ctrl.initialize();
    if (!mounted) return;
    ctrl.setLooping(false);
    if (index == _currentIndex) _startCurrentPage();
    setState(() {});
  }

  void _clearVideoEndListener() {
    if (_listeningCtrl != null && _videoEndListener != null) {
      _listeningCtrl!.removeListener(_videoEndListener!);
    }
    _videoEndListener = null;
    _listeningCtrl = null;
  }

  void _startCurrentPage() {
    _imageTimer?.cancel();
    _imageTimer = null;
    _clearVideoEndListener();
    if (_items.isEmpty) return;

    final item = _items[_currentIndex];

    if (item.type == MemoryType.video) {
      final ctrl = _controllers[_currentIndex];
      if (ctrl == null || !ctrl.value.isInitialized) return;
      ctrl.seekTo(Duration.zero);
      ctrl.play();

      bool fired = false;
      void listener() {
        final v = ctrl.value;
        if (!fired &&
            v.isInitialized &&
            !v.isPlaying &&
            v.position.inMilliseconds > 100 &&
            (v.duration - v.position).inMilliseconds < 300) {
          fired = true;
          if (mounted) _advance();
        }
      }

      _videoEndListener = listener;
      _listeningCtrl = ctrl;
      ctrl.addListener(listener);
    } else {
      _imageTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) _advance();
      });
    }
  }

  void _advance() {
    if (_items.isEmpty) return;
    HapticFeedback.lightImpact();
    _cycleMotivation();
    final next = (_currentIndex + 1) % _items.length;
    if (next == _currentIndex) {
      // Single item — restart in place
      _startCurrentPage();
      return;
    }
    _pageCtrl.jumpToPage(next);
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _startCurrentPage();
    _initController((index + 1) % _items.length);
    _disposeOutOfRange(index);
  }

  void _disposeOutOfRange(int current) {
    final keep = {current, (current + 1) % _items.length};
    final toRemove =
        _controllers.keys.where((i) => !keep.contains(i)).toList();
    for (final i in toRemove) {
      _controllers[i]!.dispose();
      _controllers.remove(i);
    }
  }

  void _cycleMotivation() {
    setState(() => _motivationVisible = false);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _motivationIndex = (_motivationIndex + 1) % _motivations.length;
        _motivationVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _clearVideoEndListener();
    _pageCtrl.dispose();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white30),
        ),
      );
    }

    if (_items.isEmpty) {
      return _EmptyState(
        onAdd: () => Navigator.of(context)
          ..pop()
          ..push(MaterialPageRoute<void>(
            builder: (_) => const MemoryVaultScreen(),
          )),
      );
    }

    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── PageView ────────────────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemCount: _items.length,
            itemBuilder: (_, index) => _buildPage(index),
          ),

          // ── Motivational text ────────────────────────────────────────────
          Positioned(
            top: mq.padding.top + 56,
            left: 24,
            right: 60,
            child: AnimatedOpacity(
              opacity: _motivationVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                _motivations[_motivationIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  shadows: [
                    Shadow(blurRadius: 12, color: Colors.black),
                    Shadow(blurRadius: 6, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),

          // ── X close button ────────────────────────────────────────────────
          Positioned(
            top: mq.padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final item = _items[index];
    final ctrl = item.type == MemoryType.video ? _controllers[index] : null;
    final mq = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),

        // Content
        if (item.type == MemoryType.video)
          ctrl != null && ctrl.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: ctrl.value.aspectRatio,
                    child: VideoPlayer(ctrl),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: Colors.white30),
                )
        else
          Center(
            child: item.isDemo
                ? Image.asset(item.filePath, fit: BoxFit.contain)
                : Image.file(File(item.filePath), fit: BoxFit.contain),
          ),

        // Caption overlay
        if (item.caption != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  16, 48, 16, mq.padding.bottom + 16),
              child: Text(
                item.caption!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded,
                    color: Colors.red, size: 72),
                const SizedBox(height: 20),
                const Text(
                  'Your memory vault is empty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Add photos and videos of your loved ones to support you in difficult moments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2BC0E4), Color(0xFF1B5FCB)],
                      ),
                    ),
                    child: const Text(
                      'Add Memories Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
