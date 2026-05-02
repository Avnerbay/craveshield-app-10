// dart:io compiles on Flutter Web but File I/O throws at runtime.
// All File/VideoPlayerController.file usages are guarded with kIsWeb below.
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/memory_item.dart';
import '../services/memory_vault_service.dart';

class MemoryViewerScreen extends StatefulWidget {
  const MemoryViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  final List<MemoryItem> items;
  final int initialIndex;

  static const routeName = 'craveMemoryViewer';
  static const routePath = '/crave-memory-viewer';

  @override
  State<MemoryViewerScreen> createState() => _MemoryViewerScreenState();
}

class _MemoryViewerScreenState extends State<MemoryViewerScreen> {
  late List<MemoryItem> _items;
  late PageController _pageCtrl;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
    _currentIndex = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
    _initController(_currentIndex);
    if (_currentIndex + 1 < _items.length) {
      _initController(_currentIndex + 1);
    }
  }

  Future<void> _initController(int index) async {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].type != MemoryType.video) return;
    if (_controllers.containsKey(index)) return;

    final item = _items[index];
    final ctrl = item.isDemo
        ? VideoPlayerController.asset(item.filePath)
        : kIsWeb
            ? VideoPlayerController.networkUrl(Uri.parse(item.filePath))
            : VideoPlayerController.file(File(item.filePath));
    _controllers[index] = ctrl;

    await ctrl.initialize();
    if (!mounted) return;
    ctrl.setLooping(true);
    if (index == _currentIndex) ctrl.play();
    setState(() {});
  }

  void _disposeOutOfRange(int current) {
    final toRemove =
        _controllers.keys.where((i) => (i - current).abs() > 1).toList();
    for (final i in toRemove) {
      _controllers[i]!.dispose();
      _controllers.remove(i);
    }
  }

  void _onPageChanged(int index) {
    _controllers[_currentIndex]?.pause();
    setState(() => _currentIndex = index);
    final ctrl = _controllers[index];
    if (ctrl != null && ctrl.value.isInitialized) ctrl.play();
    _initController(index + 1);
    _disposeOutOfRange(index);
  }

  Future<void> _deleteItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF062550),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Memory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Remove this memory from your vault?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFFF4444), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await MemoryVaultService.instance.deleteItem(_items[index].id);
    if (!mounted) return;

    if (_items.length == 1) {
      Navigator.pop(context);
      return;
    }

    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    _controllers.clear();

    setState(() {
      _items.removeAt(index);
      if (_currentIndex >= _items.length) {
        _currentIndex = _items.length - 1;
      }
    });

    _pageCtrl.jumpToPage(_currentIndex);
    _initController(_currentIndex);
    if (_currentIndex + 1 < _items.length) {
      _initController(_currentIndex + 1);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageCtrl,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: _items.length,
        itemBuilder: (_, index) => _MemoryPage(
          key: ValueKey(_items[index].id),
          item: _items[index],
          controller: _items[index].type == MemoryType.video
              ? _controllers[index]
              : null,
          onClose: () => Navigator.pop(context),
          onDelete: () => _deleteItem(index),
        ),
      ),
    );
  }
}

// ── Per-page widget ───────────────────────────────────────────────────────────

class _MemoryPage extends StatefulWidget {
  const _MemoryPage({
    super.key,
    required this.item,
    required this.onClose,
    required this.onDelete,
    this.controller,
  });

  final MemoryItem item;
  final VideoPlayerController? controller;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  State<_MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<_MemoryPage> {
  bool _iconVisible = false;
  bool _iconIsPlay = false;

  void _togglePlay() {
    final ctrl = widget.controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final wasPlaying = ctrl.value.isPlaying;
    wasPlaying ? ctrl.pause() : ctrl.play();
    setState(() {
      _iconVisible = true;
      _iconIsPlay = !wasPlaying;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _iconVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final ctrl = widget.controller;
    final isVideo = item.type == MemoryType.video;
    final mq = MediaQuery.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background ──────────────────────────────────────────────────────
        const ColoredBox(color: Colors.black),

        // ── Content ─────────────────────────────────────────────────────────
        if (isVideo)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlay,
            child: ctrl != null && ctrl.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: ctrl.value.aspectRatio,
                      child: VideoPlayer(ctrl),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: Colors.white30),
                  ),
          )
        else
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: item.isDemo
                  ? Image.asset(item.filePath, fit: BoxFit.contain)
                  : kIsWeb
                      ? Image.network(item.filePath, fit: BoxFit.contain)
                      : Image.file(File(item.filePath), fit: BoxFit.contain),
            ),
          ),

        // ── Top overlay ─────────────────────────────────────────────────────
        Positioned(
          top: mq.padding.top + 4,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (item.isDemo)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              GestureDetector(
                onTap: widget.onClose,
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
            ],
          ),
        ),

        // ── Bottom overlay ──────────────────────────────────────────────────
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar (videos only)
                if (isVideo && ctrl != null && ctrl.value.isInitialized)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: ctrl,
                      builder: (_, value, __) {
                        final total = value.duration.inMilliseconds;
                        final pos = value.position.inMilliseconds;
                        final progress =
                            total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF2BC0E4)),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                  ),

                // Caption + delete row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: item.caption != null
                          ? Text(
                              item.caption!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Colors.white70, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Play/pause flash icon ────────────────────────────────────────────
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _iconVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconIsPlay
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
