import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class _Quote {
  _Quote({
    required this.id,
    required this.text,
    required this.author,
    this.isBuiltIn = false,
  });

  final String id;
  final String text;
  final String author;
  final bool isBuiltIn;

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'author': author};

  factory _Quote.fromJson(Map<String, dynamic> j) => _Quote(
        id: j['id'] as String,
        text: j['text'] as String,
        author: (j['author'] as String?) ?? 'Unknown',
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({super.key});
  static const routeName = 'craveMyQuotes';
  static const routePath = '/crave-my-quotes';

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  static const _customKey = 'my_quotes_custom_v1';
  static const _favsKey = 'my_quotes_favs_v1';

  static const _bg = Color(0xFF0A192F);
  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);
  static const _heart = Color(0xFFE53E6E);

  static final _builtIn = <_Quote>[
    _Quote(
      id: 'b1',
      text:
          'Recovery is not a race. You don\'t have to feel guilty if it takes you longer than you thought it would.',
      author: 'Unknown',
      isBuiltIn: true,
    ),
    _Quote(
      id: 'b2',
      text:
          'Rock bottom became the solid foundation on which I rebuilt my life.',
      author: 'J.K. Rowling',
      isBuiltIn: true,
    ),
    _Quote(
      id: 'b3',
      text:
          'You don\'t have to see the whole staircase, just take the first step.',
      author: 'Martin Luther King Jr.',
      isBuiltIn: true,
    ),
    _Quote(
      id: 'b4',
      text:
          'Strength does not come from what you can do. It comes from overcoming the things you once thought you couldn\'t.',
      author: 'Rikki Rogers',
      isBuiltIn: true,
    ),
    _Quote(
      id: 'b5',
      text:
          'One day at a time. This is enough. Do not look back and grieve over the past, for it is gone.',
      author: 'Ida Scott Taylor',
      isBuiltIn: true,
    ),
  ];

  List<_Quote> _custom = [];
  Set<String> _favIds = {};
  bool _favFilter = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawC = prefs.getString(_customKey);
    final rawF = prefs.getStringList(_favsKey);
    if (!mounted) return;
    setState(() {
      if (rawC != null) {
        _custom = (jsonDecode(rawC) as List<dynamic>)
            .map((e) => _Quote.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (rawF != null) _favIds = rawF.toSet();
    });
  }

  Future<void> _saveCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _customKey, jsonEncode(_custom.map((q) => q.toJson()).toList()));
  }

  Future<void> _saveFavs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favsKey, _favIds.toList());
  }

  List<_Quote> get _visible {
    final all = [..._builtIn, ..._custom];
    return _favFilter ? all.where((q) => _favIds.contains(q.id)).toList() : all;
  }

  void _toggleFav(String id) {
    setState(() {
      _favIds.contains(id) ? _favIds.remove(id) : _favIds.add(id);
    });
    _saveFavs();
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<_Quote>(
      context: context,
      builder: (_) => const _AddQuoteDialog(),
    );
    if (result != null && mounted) {
      setState(() => _custom.add(result));
      await _saveCustom();
    }
  }

  Future<void> _deleteCustom(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Quote?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Remove this quote from your collection?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
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
    if (ok == true && mounted) {
      setState(() {
        _custom.removeWhere((q) => q.id == id);
        _favIds.remove(id);
      });
      await _saveCustom();
      await _saveFavs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quotes = _visible;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MY QUOTES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: _accentDark,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          _buildFilterBar(quotes.length),
          Expanded(
            child: quotes.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: quotes.length,
                    itemBuilder: (_, i) => _buildCard(quotes[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          _filterChip(
            label: 'All',
            selected: !_favFilter,
            onTap: () => setState(() => _favFilter = false),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Favorites',
            icon: Icons.favorite_rounded,
            selected: _favFilter,
            onTap: () => setState(() => _favFilter = true),
          ),
          const Spacer(),
          Text(
            '$count ${count == 1 ? 'quote' : 'quotes'}',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    IconData? icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _accentDark
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _accent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: selected ? Colors.white : Colors.white38),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_Quote q) {
    final isFav = _favIds.contains(q.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFav
              ? _heart.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.07),
          width: isFav ? 1.2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '“',
                style: TextStyle(
                  color: _accent,
                  fontSize: 38,
                  height: 0.75,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  q.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— ${q.author}',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleFav(q.id),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isFav),
                    color: isFav ? _heart : Colors.white24,
                    size: 22,
                  ),
                ),
              ),
              if (!q.isBuiltIn) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _deleteCustom(q.id),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white24, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: Colors.white12, size: 64),
          const SizedBox(height: 16),
          Text(
            _favFilter ? 'No favorites yet' : 'No quotes yet',
            style: const TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            _favFilter
                ? 'Tap the heart on any quote to save it here'
                : 'Tap + to add your own quote',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Add Quote Dialog ──────────────────────────────────────────────────────────

class _AddQuoteDialog extends StatefulWidget {
  const _AddQuoteDialog();

  @override
  State<_AddQuoteDialog> createState() => _AddQuoteDialogState();
}

class _AddQuoteDialogState extends State<_AddQuoteDialog> {
  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);

  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _Quote(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        text: _textCtrl.text.trim(),
        author: _authorCtrl.text.trim().isEmpty
            ? 'Unknown'
            : _authorCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _card,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.format_quote_rounded,
                      color: _accent, size: 22),
                  SizedBox(width: 10),
                  Text('Add Quote',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _textCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                    'Quote text', Icons.format_quote_outlined),
                maxLines: 4,
                minLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Quote text is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _authorCtrl,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _dec('Author (optional)', Icons.person_outline),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.white
                                  .withValues(alpha: 0.12)),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentDark,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Add',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
