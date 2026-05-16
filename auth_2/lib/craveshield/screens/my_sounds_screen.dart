import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';

const _bgColor    = Color(0xFF0A192F);
const _cardColor  = Color(0xFF112240);
const _activeChip = Color(0xFF1E6FFF);
const _inactiveChip = Color(0xFF1A2A42);

class _SoundData {
  final String emoji;
  final String title;
  final String effect;
  final String category;
  final String? assetPath;
  String? filePath;
  Duration duration = Duration.zero;

  _SoundData({
    required this.emoji,
    required this.title,
    required this.effect,
    required this.category,
    this.assetPath,
    this.filePath,
  });

  bool get isUserAdded => assetPath == null;
}

class MySoundsScreen extends StatefulWidget {
  const MySoundsScreen({super.key});
  static const routeName = 'craveMySoundsScreen';
  static const routePath = '/crave-my-sounds';

  @override
  State<MySoundsScreen> createState() => _MySoundsScreenState();
}

class _MySoundsScreenState extends State<MySoundsScreen> {
  static const _filters = [
    'All',
    'Calm the urge',
    'Reset my mind',
    'Help me sleep',
    'Strengthen me',
  ];

  String _activeFilter = 'All';

  final List<_SoundData> _sounds = [
    _SoundData(
      emoji: '🌊', title: '432Hz Frequency',
      effect: 'Deep nervous system reset',
      category: 'Reset my mind',
      assetPath: 'assets/audio/sounds/relax_432hz.mp3',
    ),
    _SoundData(
      emoji: '🌧️', title: 'Dark Rain',
      effect: 'Wraps you in calm darkness',
      category: 'Calm the urge',
      assetPath: 'assets/audio/sounds/dark_rain.mp3',
    ),
    _SoundData(
      emoji: '🔔', title: 'Gong Reset',
      effect: 'Resets the mind in seconds',
      category: 'Reset my mind',
      assetPath: 'assets/audio/sounds/gong_reset.mp3',
    ),
    _SoundData(
      emoji: '✨', title: 'Golden Cleanse',
      effect: 'Clears mental noise',
      category: 'Reset my mind',
      assetPath: 'assets/audio/sounds/golden_cleanse.mp3',
    ),
    _SoundData(
      emoji: '🎐', title: 'Wind Chimes',
      effect: 'Gentle anchor to the present',
      category: 'Help me sleep',
      assetPath: 'assets/audio/sounds/wind_chimes.mp3',
    ),
    _SoundData(
      emoji: '🕳️', title: 'The Cave',
      effect: 'Deep grounding stillness',
      category: 'Calm the urge',
      assetPath: 'assets/audio/sounds/the_cave.mp3',
    ),
    _SoundData(
      emoji: '🔥', title: 'Hearth & Piano',
      effect: 'Grounds racing thoughts',
      category: 'Reset my mind',
      assetPath: 'assets/audio/sounds/hearth_piano.mp3',
    ),
    _SoundData(
      emoji: '💓', title: 'Slow Heartbeat',
      effect: 'Syncs your pulse, eases anxiety',
      category: 'Calm the urge',
      assetPath: 'assets/audio/sounds/slow_heartbeat.mp3',
    ),
    _SoundData(
      emoji: '🌌', title: 'Delta Brown Noise',
      effect: 'Deep nervous system reset',
      category: 'Help me sleep',
      assetPath: 'assets/audio/sounds/delta_brown.mp3',
    ),
    _SoundData(
      emoji: '🪔', title: 'Tibetan Bowl',
      effect: 'Calms body in 30 seconds',
      category: 'Calm the urge',
      assetPath: 'assets/audio/sounds/tibetan_bowl.mp3',
    ),
  ];

  final _player = AudioPlayer();
  int? _playingIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.durationStream.listen((dur) {
      if (mounted) {
        setState(() {
          _totalDuration = dur ?? Duration.zero;
          if (_playingIndex != null && dur != null) {
            _sounds[_playingIndex!].duration = dur;
          }
        });
      }
    });
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  List<_SoundData> get _filteredSounds =>
      _activeFilter == 'All' ? _sounds : _sounds.where((s) => s.category == _activeFilter).toList();

  Future<void> _togglePlay(int globalIndex) async {
    final sound = _sounds[globalIndex];

    if (_playingIndex == globalIndex) {
      _isPlaying ? await _player.pause() : await _player.play();
      setState(() {});
      return;
    }

    setState(() => _playingIndex = globalIndex);

    try {
      if (sound.isUserAdded && sound.filePath != null) {
        debugPrint('[SOUND] Loading file path: ${sound.filePath}');
        await _player.setFilePath(sound.filePath!);
        debugPrint('[SOUND] File path loaded OK');
      } else if (sound.assetPath != null) {
        debugPrint('[SOUND] Loading asset: ${sound.assetPath}');
        await _player.setAsset(sound.assetPath!);
        debugPrint('[SOUND] Asset loaded OK');
      } else {
        return;
      }
      debugPrint('[SOUND] Calling play()...');
      await _player.play();
      debugPrint('[SOUND] Playing');
    } catch (e, stack) {
      debugPrint('[SOUND ERROR] $e');
      debugPrint('[SOUND STACK] $stack');
      setState(() => _playingIndex = null);
    }

    setState(() {});
  }

  Future<void> _closePlayer() async {
    await _player.stop();
    setState(() {
      _playingIndex = null;
      _position = Duration.zero;
      _totalDuration = Duration.zero;
    });
  }

  Future<void> _addLocalSound() async {
    if (kIsWeb) {
      _showSnack('Local file upload works on iOS & Android.');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) {
      _showSnack('Could not access file path on this platform.');
      return;
    }
    setState(() {
      _sounds.add(_SoundData(
        emoji: '🎵',
        title: file.name.replaceAll(RegExp(r'\.\w+$'), ''),
        effect: 'Your custom sound',
        category: 'All',
        filePath: file.path,
      ));
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _cardColor,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Calm the urge':  return const Color(0xFF0B8BFF);
      case 'Reset my mind':  return const Color(0xFF7C3AED);
      case 'Help me sleep':  return const Color(0xFF2563EB);
      case 'Strengthen me':  return const Color(0xFF059669);
      default:               return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredSounds;
    final hasPlayer = _playingIndex != null;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildFilterRow(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final sound = filtered[i];
                  final gi = _sounds.indexOf(sound);
                  return _buildSoundCard(sound, gi);
                },
              ),
            ),
            if (hasPlayer) _buildMiniPlayer(),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
      child: Stack(
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
            'MY SOUND',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final label = _filters[i];
          final active = label == _activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? _activeChip : _inactiveChip,
                  borderRadius: BorderRadius.circular(20),
                  border: active ? null : Border.all(color: Colors.white12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.white54,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoundCard(_SoundData sound, int globalIndex) {
    final isActive = _playingIndex == globalIndex;
    final isThisPlaying = isActive && _isPlaying;
    final catColor = _categoryColor(sound.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? _activeChip : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji square
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(sound.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 12),
            // Title + effect + category badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sound.effect,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _badge(sound.category, catColor),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play/Pause button
            GestureDetector(
              onTap: () => _togglePlay(globalIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isActive ? _activeChip : Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _addLocalSound,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _activeChip),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            '+ Add Sound',
            style: TextStyle(
              color: _activeChip,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    final sound = _sounds[_playingIndex!];
    final progress = _totalDuration.inMilliseconds > 0
        ? (_position.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _activeChip, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _activeChip.withValues(alpha: 0.25),
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
              Text(sound.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sound.effect,
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _togglePlay(_playingIndex!),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: _activeChip,
                  size: 30,
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
              valueColor: const AlwaysStoppedAnimation(_activeChip),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_position), style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(_fmt(_totalDuration), style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
