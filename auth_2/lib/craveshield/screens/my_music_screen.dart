import 'dart:convert';
import 'dart:io';
// dart:typed_data provided via flutter/foundation
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ── palette ────────────────────────────────────────────────────────────────

const _bg     = Color(0xFF0A192F);
const _card   = Color(0xFF112240);
const _accent = Color(0xFF1E6FFF);
const _muted  = Color(0xFF8892B0);

// ── emotional tags ─────────────────────────────────────────────────────────

class EmotionalTag {
  final String emoji;
  final String label;
  final Color color;
  const EmotionalTag(this.emoji, this.label, this.color);
  String get full => '$emoji $label';
}

const _eTags = [
  EmotionalTag('🌊', 'Calms me',              Color(0xFF0B8BFF)),
  EmotionalTag('⚡', 'Energizes me',          Color(0xFFF59E0B)),
  EmotionalTag('💭', 'Reminds me why I quit', Color(0xFF7C3AED)),
  EmotionalTag('💪', 'Strengthens me',        Color(0xFF10B981)),
  EmotionalTag('🌙', 'Helps me sleep',        Color(0xFF6366F1)),
];

// ── song model ─────────────────────────────────────────────────────────────

class UserSong {
  final String id;
  String displayName;
  String? filePath;     // native user-uploaded
  String? assetPath;    // bundled asset (demo song)
  final DateTime addedDate;
  String? tagFull;      // e.g. "🌊 Calms me"
  int playCount;
  Duration duration;
  Uint8List? bytes;     // web only – not persisted
  final bool isDemo;

  UserSong({
    required this.id,
    required this.displayName,
    this.filePath,
    this.assetPath,
    required this.addedDate,
    this.tagFull,
    this.playCount = 0,
    this.duration = Duration.zero,
    this.bytes,
    this.isDemo = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'filePath': filePath,
    'assetPath': assetPath,
    'addedDateMs': addedDate.millisecondsSinceEpoch,
    'tagFull': tagFull,
    'playCount': playCount,
    'durationMs': duration.inMilliseconds,
    'isDemo': isDemo,
  };

  factory UserSong.fromJson(Map<String, dynamic> j) => UserSong(
    id: j['id'] as String,
    displayName: j['displayName'] as String,
    filePath: j['filePath'] as String?,
    assetPath: j['assetPath'] as String?,
    addedDate: DateTime.fromMillisecondsSinceEpoch(j['addedDateMs'] as int),
    tagFull: j['tagFull'] as String?,
    playCount: j['playCount'] as int? ?? 0,
    duration: Duration(milliseconds: j['durationMs'] as int? ?? 0),
    isDemo: j['isDemo'] as bool? ?? false,
  );

  EmotionalTag? get tag {
    if (tagFull == null) return null;
    try { return _eTags.firstWhere((t) => t.full == tagFull); } catch (_) { return null; }
  }

  String get displayEmoji => tag?.emoji ?? '🎵';
  Color  get displayColor => tag?.color ?? const Color(0xFF334155);
}

// ── screen ─────────────────────────────────────────────────────────────────

class MyMusicScreen extends StatefulWidget {
  const MyMusicScreen({super.key});
  static const routeName = 'craveMyMusicScreen';
  static const routePath = '/crave-my-music';

  // ignore: library_private_types_in_public_api
  @override
  State<MyMusicScreen> createState() => _MyMusicScreenState();
}

class _MyMusicScreenState extends State<MyMusicScreen> {
  static const _prefsKey      = 'crave_user_songs_v1';
  static const _uuid          = Uuid();
  static const _demoAssetPath  = 'assets/audio/music/demo_song.mp3';
  static const _demoAssetPath2 = 'assets/audio/music/demo_song_2.mp3';
  static const _demoId         = 'demo_song_v1';
  static const _demoId2        = 'demo_song_v2';

  final List<UserSong> _songs = [];
  bool _loading = true;

  final _player = AudioPlayer();
  int?     _playingIndex;
  bool     _isPlaying     = false;
  Duration _position      = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool     _pendingTag    = false;

  // inline rename
  int?    _renamingIndex;
  final   _renameController = TextEditingController();
  final   _renameFocus      = FocusNode();

  // ── lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSongs();

    _renameFocus.addListener(() {
      if (!_renameFocus.hasFocus && _renamingIndex != null) _saveRename();
    });

    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _player.durationStream.listen((dur) {
      if (!mounted || dur == null || dur == Duration.zero) return;
      setState(() => _totalDuration = dur);
      if (_playingIndex != null) {
        final song = _songs[_playingIndex!];
        if (song.duration == Duration.zero) {
          song.duration = dur;
          _saveSongs();
        }
      }
    });

    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) _onComplete();
    });
  }

  @override
  void dispose() {
    _renameController.dispose();
    _renameFocus.dispose();
    _player.dispose();
    super.dispose();
  }

  // ── persistence ───────────────────────────────────────────────────────────

  Future<void> _loadSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      final loaded = list
          .map((e) => UserSong.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!kIsWeb) {
        loaded.removeWhere(
          (s) => s.filePath != null && !File(s.filePath!).existsSync(),
        );
      }
      _songs.addAll(loaded);
    }
    // first launch: seed with both demo songs
    if (_songs.isEmpty) {
      _songs.addAll([_buildDemoSong(), _buildDemoSong2()]);
      await _saveSongs();
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveSongs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_songs.map((s) => s.toJson()).toList()),
    );
  }

  UserSong _buildDemoSong() => UserSong(
    id: _demoId,
    displayName: 'Calm Beginnings',
    assetPath: _demoAssetPath,
    addedDate: DateTime.now(),
    tagFull: '🌊 Calms me',
    playCount: 1, // pre-tagged, skip post-listen sheet
    isDemo: true,
  );

  UserSong _buildDemoSong2() => UserSong(
    id: _demoId2,
    displayName: 'The Mountain Within',
    assetPath: _demoAssetPath2,
    addedDate: DateTime.now(),
    tagFull: '💪 Strengthens me',
    playCount: 1,
    isDemo: true,
  );

  void _restoreDemo() {
    final ids = _songs.map((s) => s.id).toSet();
    setState(() {
      if (!ids.contains(_demoId))  _songs.insert(0, _buildDemoSong());
      if (!ids.contains(_demoId2)) _songs.insert(1.clamp(0, _songs.length), _buildDemoSong2());
    });
    _saveSongs();
  }

  // ── add song ──────────────────────────────────────────────────────────────

  Future<void> _addSong() async {
    debugPrint('[MUSIC] Opening file picker...');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac'],
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty) {
      debugPrint('[MUSIC] File picker cancelled or empty.');
      return;
    }
    final file = result.files.first;
    debugPrint('[MUSIC] Picked file: ${file.name} (${file.size} bytes)');

    String? destPath;
    Uint8List? bytes;

    if (kIsWeb) {
      bytes = file.bytes;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${docDir.path}/crave_music');
      await dir.create(recursive: true);
      destPath = '${dir.path}/${_uuid.v4()}.mp3';
      await File(file.path!).copy(destPath);
      debugPrint('[MUSIC] Copied to: $destPath');
    }

    final cleaned = _cleanName(file.name);
    final song = UserSong(
      id: _uuid.v4(),
      displayName: cleaned,
      filePath: destPath,
      addedDate: DateTime.now(),
      bytes: bytes,
    );

    debugPrint('[MUSIC] Display name: "$cleaned"');
    setState(() => _songs.insert(0, song));
    await _saveSongs();
    debugPrint('[MUSIC] Saved. Total songs: ${_songs.length}');
  }

  String _cleanName(String raw) {
    return raw
        .replaceAll(RegExp(r'\.(mp3|m4a|wav|aac)$', caseSensitive: false), '')
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // ── inline rename ─────────────────────────────────────────────────────────

  void _startRename(int index) {
    setState(() {
      _renamingIndex = index;
      _renameController.text = _songs[index].displayName;
    });
    Future.microtask(() => _renameFocus.requestFocus());
  }

  void _saveRename() {
    if (_renamingIndex == null) return;
    final name = _renameController.text.trim();
    if (name.isNotEmpty) {
      setState(() => _songs[_renamingIndex!].displayName = name);
      _saveSongs();
    }
    setState(() => _renamingIndex = null);
  }

  // ── delete song ───────────────────────────────────────────────────────────

  Future<void> _confirmDelete(int index) async {
    final song = _songs[index];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove song?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove "${song.displayName}" from your library?',
          style: const TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    if (_playingIndex == index) await _closePlayer();
    if (_renamingIndex == index) setState(() => _renamingIndex = null);

    if (!kIsWeb && song.filePath != null) {
      try { await File(song.filePath!).delete(); } catch (_) {}
    }

    setState(() {
      _songs.removeAt(index);
      if (_playingIndex != null) {
        if (_playingIndex == index) {
          _playingIndex = null;
        } else if (_playingIndex! > index) {
          _playingIndex = _playingIndex! - 1;
        }
      }
    });
    await _saveSongs();
  }

  // ── playback ──────────────────────────────────────────────────────────────

  Future<void> _togglePlay(int index) async {
    debugPrint('[MUSIC] _togglePlay($index) — playingIndex=$_playingIndex isPlaying=$_isPlaying');
    if (_playingIndex == index) {
      _isPlaying ? await _player.pause() : await _player.play();
      setState(() {});
      return;
    }

    setState(() {
      _playingIndex = index;
      _position = Duration.zero;
      _totalDuration = Duration.zero;
    });

    final song = _songs[index];
    _pendingTag = song.playCount == 0;
    debugPrint('[MUSIC] "${song.displayName}" | playCount=${song.playCount} | pendingTag=$_pendingTag');

    try {
      if (kIsWeb && song.bytes != null) {
        debugPrint('[MUSIC] Web bytes → base64 data URI');
        final b64 = base64Encode(song.bytes!);
        await _player.setUrl('data:audio/mpeg;base64,$b64');
      } else if (song.assetPath != null) {
        debugPrint('[MUSIC] setAsset("${song.assetPath}")');
        await _player.setAsset(song.assetPath!);
      } else if (!kIsWeb && song.filePath != null) {
        debugPrint('[MUSIC] setFilePath("${song.filePath}")');
        await _player.setFilePath(song.filePath!);
      } else {
        debugPrint('[MUSIC ERROR] No source (web=$kIsWeb bytes=${song.bytes != null} file=${song.filePath})');
        setState(() => _playingIndex = null);
        return;
      }
      debugPrint('[MUSIC] play()');
      await _player.play();
    } catch (e, stack) {
      debugPrint('[MUSIC ERROR] $e');
      debugPrint('[MUSIC STACK] $stack');
      setState(() => _playingIndex = null);
    }
    setState(() {});
  }

  void _onComplete() {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
    if (_pendingTag && _playingIndex != null) {
      _pendingTag = false;
      final idx = _playingIndex!;
      setState(() => _songs[idx].playCount++);
      _saveSongs();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showTagSheet(idx);
      });
    }
  }

  Future<void> _closePlayer() async {
    await _player.stop();
    setState(() {
      _playingIndex = null;
      _position = Duration.zero;
      _totalDuration = Duration.zero;
    });
  }

  // ── tagging ───────────────────────────────────────────────────────────────

  Future<void> _showTagSheet(int index) async {
    if (index >= _songs.length) return;
    final song = _songs[index];
    await showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 16, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How did this song make you feel?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tag it so we can suggest it when you need it most.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _eTags.map((tag) {
                  final selected = song.tagFull == tag.full;
                  return GestureDetector(
                    onTap: () {
                      setState(() => song.tagFull = tag.full);
                      _saveSongs();
                      Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: selected
                            ? tag.color.withValues(alpha: 0.28)
                            : tag.color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected ? tag.color : tag.color.withValues(alpha: 0.35),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        tag.full,
                        style: TextStyle(
                          color: selected ? Colors.white : tag.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: _accent)),
              )
            else if (_songs.isEmpty)
              Expanded(child: _buildEmptyState())
            else ...[
              Expanded(child: _buildList()),
              if (_playingIndex != null) _buildMiniPlayer(),
              _buildAddButton('+ Add another song'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text(
                'MY MUSIC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Your personal playlist for staying free.',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎵', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 24),
          const Text(
            'Your music, your healing.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Add songs that help you stay strong in moments of craving.',
            style: TextStyle(color: _muted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addSong,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                '+ Add your first song',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _restoreDemo,
            child: const Text(
              'Or restore demo songs',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _songs.length,
      itemBuilder: (ctx, i) => _buildSongCard(i),
    );
  }

  Widget _buildSongCard(int index) {
    final song       = _songs[index];
    final isActive   = _playingIndex == index;
    final isPlaying  = isActive && _isPlaying;
    final isRenaming = _renamingIndex == index;
    final col        = song.displayColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? _accent : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // emoji square
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: col.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(song.displayEmoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),

            // info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // title: inline text field when renaming, otherwise long-pressable text
                  if (isRenaming)
                    TextField(
                      controller: _renameController,
                      focusNode: _renameFocus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      cursorColor: _accent,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: _accent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: _accent, width: 1.5),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: _saveRename,
                          child: const Icon(Icons.check_rounded, color: _accent, size: 18),
                        ),
                      ),
                      onSubmitted: (_) => _saveRename(),
                    )
                  else
                    GestureDetector(
                      onLongPress: () => _startRename(index),
                      child: Text(
                        song.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 3),

                  // subtitle + Demo badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.duration > Duration.zero
                              ? 'Added by you · ${_fmt(song.duration)}'
                              : 'Added by you',
                          style: const TextStyle(color: _muted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (song.isDemo) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Demo',
                            style: TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),

                  // tag chip
                  GestureDetector(
                    onTap: () => _showTagSheet(index),
                    child: song.tagFull != null
                        ? _tagChip(song.tag!)
                        : _addTagPlaceholder(),
                  ),

                  // rename hint (demo card only, while not renaming)
                  if (song.isDemo && !isRenaming) ...[
                    const SizedBox(height: 4),
                    const Text(
                      '✏️ Long-press title to rename',
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // play/pause button
            GestureDetector(
              onTap: () => _togglePlay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: isActive ? _accent : Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 22,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // delete
            GestureDetector(
              onTap: () => _confirmDelete(index),
              child: const Icon(Icons.close_rounded, color: _muted, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(EmotionalTag tag) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: tag.color.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      tag.full,
      style: TextStyle(color: tag.color, fontSize: 11, fontWeight: FontWeight.w500),
    ),
  );

  Widget _addTagPlaceholder() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white24),
    ),
    child: const Text('+ Tag', style: TextStyle(color: Colors.white38, fontSize: 11)),
  );

  Widget _buildAddButton(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _addSong,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _accent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: _accent,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );

  Widget _buildMiniPlayer() {
    final song = _songs[_playingIndex!];
    final progress = _totalDuration.inMilliseconds > 0
        ? (_position.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(song.displayEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  song.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _togglePlay(_playingIndex!),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: _accent, size: 30,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _closePlayer,
                child: const Icon(Icons.close_rounded, color: Colors.white38, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(_accent),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_position),      style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(_fmt(_totalDuration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
