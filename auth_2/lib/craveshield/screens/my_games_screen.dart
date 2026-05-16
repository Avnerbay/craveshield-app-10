import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'aquarium_screen.dart';
import 'bubble_pop_screen.dart';
import 'color_tap_screen.dart';
import 'game_webview_screen.dart';
import 'memory_match_screen.dart';
import 'pattern_match_screen.dart';
import 'web_storage.dart';

// ── palette ────────────────────────────────────────────────────────────────

const _bg     = Color(0xFF0A192F);
const _card   = Color(0xFF112240);
const _accent = Color(0xFF1E6FFF);
const _muted  = Color(0xFF8892B0);

// ── user game model ────────────────────────────────────────────────────────

class UserGame {
  final String id;
  String name;
  String url;
  String emoji;
  String tagline;
  final DateTime addedDate;

  UserGame({
    required this.id,
    required this.name,
    required this.url,
    required this.emoji,
    required this.tagline,
    required this.addedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'emoji': emoji,
    'tagline': tagline,
    'addedDateMs': addedDate.millisecondsSinceEpoch,
  };

  factory UserGame.fromJson(Map<String, dynamic> j) => UserGame(
    id: j['id'] as String,
    name: j['name'] as String,
    url: j['url'] as String,
    emoji: j['emoji'] as String? ?? '🎮',
    tagline: j['tagline'] as String? ?? '',
    addedDate: DateTime.fromMillisecondsSinceEpoch(j['addedDateMs'] as int),
  );
}

// ── dialog suggestions ─────────────────────────────────────────────────────

class _Suggestion {
  const _Suggestion(this.emoji, this.name, this.url, this.tagline);
  final String emoji, name, url, tagline;
}

const _suggestions = [
  _Suggestion('♟️', 'Lichess',          'https://lichess.org/play',        'Chess — 100% ad-free'),
  _Suggestion('♠️', 'Solitaired',       'https://solitaired.com',          'Solitaire — ad-free'),
  _Suggestion('🧩', 'Sudoku.com',       'https://sudoku.com',              'Logic training'),
  _Suggestion('🔤', 'Wordle Unlimited', 'https://www.wordleunlimited.org', 'Word puzzle — no ads'),
  _Suggestion('🎯', 'Aim Trainer',      'https://aimtrainer.io',           'Focus & reflex training'),
  _Suggestion('🐍', 'Slither.io',       'https://slither.io',              'Classic snake — minimal ads'),
  _Suggestion('🎨', 'Sketchpad',        'https://sketch.io/sketchpad',     'Drawing — ad-free'),
  _Suggestion('🧠', '2048',             'https://play2048.co',             'Number puzzle — no ads'),
  _Suggestion('🎲', 'Tetris',           'https://tetris.com/play-tetris',  'Official Tetris — free to play'),
];

// ── screen ─────────────────────────────────────────────────────────────────

class MyGamesScreen extends StatefulWidget {
  const MyGamesScreen({super.key});

  static const routeName = 'craveMyGames';
  static const routePath = '/crave-my-games';

  @override
  State<MyGamesScreen> createState() => _MyGamesScreenState();
}

class _MyGamesScreenState extends State<MyGamesScreen>
    with SingleTickerProviderStateMixin {
  static const _prefsKey = 'user_games';

  List<UserGame> _userGames = [];
  bool _loading = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.25, end: 0.85).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadGames();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── persistence ────────────────────────────────────────────────────────────

  Future<void> _loadGames() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_prefsKey);

    // Belt-and-suspenders: on web, fall back to direct localStorage if prefs empty
    if (raw == null && kIsWeb) {
      raw = webStorageLoad(_prefsKey);
      if (raw != null) {
        await prefs.setString(_prefsKey, raw);
        debugPrint('[GAMES] Recovered ${_countGames(raw)} games from localStorage fallback');
      }
    }

    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _userGames = list
          .map((e) => UserGame.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    debugPrint('[GAMES] Loaded ${_userGames.length} user games from storage');
    if (mounted) setState(() => _loading = false);
  }

  int _countGames(String raw) {
    try { return (jsonDecode(raw) as List).length; } catch (_) { return 0; }
  }

  Future<void> _saveGames() async {
    final encoded = jsonEncode(_userGames.map((g) => g.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, encoded);
    if (kIsWeb) webStorageSave(_prefsKey, encoded);
  }

  // ── add / edit ─────────────────────────────────────────────────────────────

  Future<void> _showAddDialog([UserGame? existing]) async {
    final result = await _AddGameDialog.show(context, existing: existing);
    if (result == null || !mounted) return;
    setState(() {
      if (existing != null) {
        final idx = _userGames.indexWhere((g) => g.id == existing.id);
        if (idx >= 0) {
          _userGames[idx]
            ..name = result.name
            ..url = result.url
            ..emoji = result.emoji
            ..tagline = result.tagline;
        }
      } else {
        _userGames.add(result);
      }
    });
    await _saveGames();
    debugPrint('[GAMES] Saved user game: ${result.name}. Total: ${_userGames.length}');
  }

  Future<void> _deleteGame(int index) async {
    final name = _userGames[index].name;
    setState(() => _userGames.removeAt(index));
    await _saveGames();
    debugPrint('[GAMES] Deleted: $name. Total: ${_userGames.length}');
  }

  // ── long-press options ─────────────────────────────────────────────────────

  void _showGameOptions(int index) {
    final game = _userGames[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        if (game.tagline.isNotEmpty)
                          Text(game.tagline,
                              style: const TextStyle(color: _muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.white70),
                title: const Text('Edit', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddDialog(game);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded,
                    color: Colors.redAccent),
                title: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteGame(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── navigation ─────────────────────────────────────────────────────────────

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const builtInCount = 5;
    final totalItems =
        builtInCount + _userGames.length + 1; // +1 for Add card

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: totalItems,
                      itemBuilder: (ctx, i) {
                        // built-in: Bubble Pop
                        if (i == 0) {
                          return _BuiltInCard(
                            emoji: '🫧',
                            title: 'Bubble Pop',
                            tagline: 'Pop away the tension',
                            accentColor: const Color(0xFF2BC0E4),
                            onTap: () => _go(const BubblePopScreen()),
                          );
                        }
                        // built-in: Color Tap
                        if (i == 1) {
                          return _BuiltInCard(
                            emoji: '🎨',
                            title: 'Color Tap',
                            tagline: 'Train your focus',
                            accentColor: _accent,
                            onTap: () => _go(const ColorTapScreen()),
                          );
                        }
                        // built-in: Pattern Match
                        if (i == 2) {
                          return _BuiltInCard(
                            emoji: '🧩',
                            title: 'Pattern Match',
                            tagline: 'Spot the odd one',
                            accentColor: const Color(0xFF8A2BE2),
                            onTap: () => _go(const PatternMatchScreen()),
                          );
                        }
                        // built-in: Memory Match
                        if (i == 3) {
                          return _BuiltInCard(
                            emoji: '🧠',
                            title: 'Memory Match',
                            tagline: 'Quiet your mind',
                            accentColor: const Color(0xFF1E6FFF),
                            onTap: () => _go(const MemoryMatchScreen()),
                          );
                        }
                        // built-in: Aquarium
                        if (i == 4) {
                          return _BuiltInCard(
                            emoji: '🐟',
                            title: 'Aquarium',
                            tagline: 'Sit and breathe',
                            accentColor: const Color(0xFF2BCDC1),
                            onTap: () => _go(const AquariumScreen()),
                          );
                        }
                        // user games
                        if (i < builtInCount + _userGames.length) {
                          final game = _userGames[i - builtInCount];
                          return _UserGameCard(
                            game: game,
                            onTap: () => _go(GameWebViewScreen(
                              name: game.name,
                              url: game.url,
                              emoji: game.emoji,
                            )),
                            onLongPress: () =>
                                _showGameOptions(i - builtInCount),
                          );
                        }
                        // Add Your Own card
                        return _AddCard(
                          pulseAnim: _userGames.isEmpty ? _pulseAnim : null,
                          onTap: () => _showAddDialog(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Text(
                'MY GAMES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 2, 0, 16),
            child: Text(
              'Choose your challenge',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── built-in game card ─────────────────────────────────────────────────────

class _BuiltInCard extends StatelessWidget {
  const _BuiltInCard({
    required this.emoji,
    required this.title,
    required this.tagline,
    required this.accentColor,
    required this.onTap,
  });

  final String emoji, title, tagline;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(tagline,
                  style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Play →',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

// ── user game card ─────────────────────────────────────────────────────────

class _UserGameCard extends StatelessWidget {
  const _UserGameCard({
    required this.game,
    required this.onTap,
    required this.onLongPress,
  });

  final UserGame game;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.emoji,
                      style: const TextStyle(fontSize: 40)),
                  const Spacer(),
                  Text(
                    game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.tagline.isNotEmpty ? game.tagline : game.url,
                    style: const TextStyle(color: _muted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Open →',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Custom badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Custom',
                  style: TextStyle(color: Colors.white38, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── add your own card ──────────────────────────────────────────────────────

class _AddCard extends StatelessWidget {
  const _AddCard({required this.pulseAnim, required this.onTap});

  final Animation<double>? pulseAnim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('➕', style: TextStyle(fontSize: 36)),
            SizedBox(height: 10),
            Text(
              'Add Your Own',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Add a game or distraction site',
                style: TextStyle(color: _muted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    if (pulseAnim == null) return child;

    return AnimatedBuilder(
      animation: pulseAnim!,
      builder: (_, __) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _card.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _accent.withValues(alpha: pulseAnim!.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: pulseAnim!.value * 0.2),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('➕', style: TextStyle(fontSize: 36)),
              SizedBox(height: 10),
              Text(
                'Add Your Own',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Add a game or distraction site',
                  style: TextStyle(color: _muted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── add / edit game dialog ─────────────────────────────────────────────────

class _AddGameDialog extends StatefulWidget {
  const _AddGameDialog({this.existing});
  final UserGame? existing;

  static Future<UserGame?> show(BuildContext context,
      {UserGame? existing}) {
    return showDialog<UserGame>(
      context: context,
      builder: (ctx) => _AddGameDialog(existing: existing),
    );
  }

  @override
  State<_AddGameDialog> createState() => _AddGameDialogState();
}

class _AddGameDialogState extends State<_AddGameDialog> {
  static const _uuid = Uuid();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _emojiCtrl;
  late final TextEditingController _taglineCtrl;
  bool _isCustomUrl = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl    = TextEditingController(text: e?.name ?? '');
    _urlCtrl     = TextEditingController(text: e?.url ?? '');
    _emojiCtrl   = TextEditingController(text: e?.emoji ?? '');
    _taglineCtrl = TextEditingController(text: e?.tagline ?? '');
    // editing an existing entry counts as custom
    if (e != null) _isCustomUrl = true;
    _urlCtrl.addListener(() {
      if (!mounted) return;
      setState(() => _isCustomUrl = true);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _emojiCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  void _applySuggestion(_Suggestion s) {
    setState(() {
      _nameCtrl.text    = s.name;
      _urlCtrl.text     = s.url;
      _emojiCtrl.text   = s.emoji;
      _taglineCtrl.text = s.tagline;
      _isCustomUrl      = false;
    });
  }

  String _sanitizeUrl(String raw) {
    raw = raw.trim();
    if (raw.isNotEmpty &&
        !raw.startsWith('http://') &&
        !raw.startsWith('https://')) {
      return 'https://$raw';
    }
    return raw;
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final url  = _sanitizeUrl(_urlCtrl.text);
    if (name.isEmpty || url.isEmpty) return;

    final game = UserGame(
      id: widget.existing?.id ?? _uuid.v4(),
      name: name,
      url: url,
      emoji: _emojiCtrl.text.trim().isEmpty ? '🎮' : _emojiCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      addedDate: widget.existing?.addedDate ?? DateTime.now(),
    );
    Navigator.pop(context, game);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Dialog(
      backgroundColor: _card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Game' : 'Add Your Distraction',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Name a site or game that helps you shift focus.',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // suggestion chips
            const Text(
              'Quick add',
              style: TextStyle(color: _muted, fontSize: 11, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((s) => GestureDetector(
                onTap: () => _applySuggestion(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    '${s.emoji} ${s.name}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            // disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF112240).withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD60A).withValues(alpha: 0.30),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'External sites are managed by their owners. CraveShield is not responsible for ads, content, or triggering material. Add at your own discretion.',
                      style: TextStyle(
                        color: Color(0xFFFFD60A),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // form fields
            _Field(ctrl: _emojiCtrl,   label: 'Emoji',    hint: '🎮'),
            const SizedBox(height: 10),
            _Field(ctrl: _nameCtrl,    label: 'Name',     hint: 'e.g. Solitaired'),
            const SizedBox(height: 10),
            if (_isCustomUrl && _urlCtrl.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFFD60A), size: 14),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'External sites may contain ads or triggering content. Only add sites you trust.',
                        style: TextStyle(
                          color: Color(0xFFFFD60A),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _Field(ctrl: _urlCtrl,     label: 'URL',      hint: 'e.g. solitaired.com'),
            const SizedBox(height: 10),
            _Field(ctrl: _taglineCtrl, label: 'Tagline',  hint: 'Optional — shown on the card'),
            const SizedBox(height: 20),

            // action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── text field helper ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
  });

  final TextEditingController ctrl;
  final String label, hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _muted, fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: _accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25),
                fontSize: 14),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
