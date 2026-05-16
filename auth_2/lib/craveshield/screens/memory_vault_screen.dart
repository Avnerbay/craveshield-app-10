import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/memory_item.dart';
import '../services/memory_vault_service.dart';
import 'memory_viewer_screen.dart';

class MemoryVaultScreen extends StatefulWidget {
  const MemoryVaultScreen({super.key});

  static const routeName = 'craveMemoryVault';
  static const routePath = '/crave-memory-vault';

  @override
  State<MemoryVaultScreen> createState() => _MemoryVaultScreenState();
}

class _MemoryVaultScreenState extends State<MemoryVaultScreen> {
  List<MemoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await MemoryVaultService.instance.loadItems();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(MemoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF062550),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete?',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Remove this memory?',
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
                    color: Color(0xFFFF4444),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await MemoryVaultService.instance.deleteItem(item.id);
    _reload();
  }

  Future<void> _pickVideo() async {
    if (kIsWeb) {
      // image_picker_web does not support video on all browsers; use file_picker
      // which provides a blob URL via PlatformFile.xFile.path on web.
      final result =
          await FilePicker.platform.pickFiles(type: FileType.video);
      if (result != null && result.files.isNotEmpty && mounted) {
        await MemoryVaultService.instance
            .addItem(result.files.first.xFile, MemoryType.video);
        _reload();
      }
    } else {
      final file =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (file != null && mounted) {
        await MemoryVaultService.instance.addItem(file, MemoryType.video);
        _reload();
      }
    }
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      await MemoryVaultService.instance.addItem(file, MemoryType.image);
      _reload();
    }
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF062550),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded,
                  color: Color(0xFF2BC0E4)),
              title: const Text(
                'Choose Video',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF2BC0E4)),
              title: const Text(
                'Choose Photo',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
                  colors: [
                    Color(0xFF06265A),
                    Color(0xFF0E4FA8),
                    Color(0xFF062B6D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Header ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new,
                                size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Add memory',
                            color: Colors.white,
                            icon: const Icon(Icons.add_rounded, size: 28),
                            onPressed: _showAddSheet,
                          ),
                        ],
                      ),
                    ),

                    // ── Title ──────────────────────────────────────────────
                    const SizedBox(height: 8),
                    const Text(
                      'MY PHOTOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Body ───────────────────────────────────────────────
                    if (_loading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2BC0E4)),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            mainAxisExtent: 160,
                          ),
                          itemCount: 8,
                          itemBuilder: (_, i) {
                            if (i < _items.length) {
                              return _MemoryTile(
                                item: _items[i],
                                onLongPress: () => _confirmDelete(_items[i]),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => MemoryViewerScreen(
                                      items: _items,
                                      initialIndex: i,
                                    ),
                                  ),
                                ).then((_) => _reload()),
                              );
                            }
                            return _PlaceholderTile(onTap: _showAddSheet);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grid tile ─────────────────────────────────────────────────────────────────

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({
    required this.item,
    required this.onTap,
    this.onLongPress,
  });
  final MemoryItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            if (item.type == MemoryType.image && !item.isDemo)
              kIsWeb
                  ? Image.network(item.filePath, fit: BoxFit.cover)
                  : Image.file(File(item.filePath), fit: BoxFit.cover)
            else
              _VideoThumbnail(item: item),

            // ── Play badge (videos) ────────────────────────────────────────
            if (item.type == MemoryType.video)
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 16),
                ),
              ),

            // ── Demo badge ─────────────────────────────────────────────────
            if (item.isDemo)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

            // ── Delete button ───────────────────────────────────────────────
            if (onLongPress != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.delete,
                        color: Colors.red, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

// ── Placeholder tile ──────────────────────────────────────────────────────────

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white38, size: 32),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(12);
    final paint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height), radius));

    const dashLen = 6.0;
    const gapLen = 4.0;
    final dashed = Path();
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        final end = (d + dashLen).clamp(0.0, m.length);
        dashed.addPath(m.extractPath(d, end), Offset.zero);
        d += dashLen + gapLen;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Video thumbnail ───────────────────────────────────────────────────────────

class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({required this.item});
  final MemoryItem item;

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late final VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.item.isDemo
        ? VideoPlayerController.asset(widget.item.filePath)
        : kIsWeb
            ? VideoPlayerController.networkUrl(
                Uri.parse(widget.item.filePath))
            : VideoPlayerController.file(File(widget.item.filePath));
    _ctrl.initialize().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
        color: const Color(0xFF041530),
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Colors.white24),
          ),
        ),
      );
    }
    // FittedBox + SizedBox fills the tile while preserving aspect ratio via cover
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _ctrl.value.size.width,
        height: _ctrl.value.size.height,
        child: VideoPlayer(_ctrl),
      ),
    );
  }
}
