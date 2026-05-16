import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class _Contact {
  _Contact({required this.name, required this.phone, required this.relationship});
  final String name;
  final String phone;
  final String relationship;
  Map<String, dynamic> toJson() =>
      {'name': name, 'phone': phone, 'relationship': relationship};
  factory _Contact.fromJson(Map<String, dynamic> j) => _Contact(
        name: j['name'] as String,
        phone: j['phone'] as String,
        relationship: (j['relationship'] as String?) ?? '',
      );
}

class _Therapist {
  _Therapist({this.name = '', this.phone = '', this.nextAppointment = ''});
  final String name;
  final String phone;
  final String nextAppointment;
  bool get isEmpty => name.isEmpty && phone.isEmpty;
  Map<String, dynamic> toJson() =>
      {'name': name, 'phone': phone, 'nextAppointment': nextAppointment};
  factory _Therapist.fromJson(Map<String, dynamic> j) => _Therapist(
        name: (j['name'] as String?) ?? '',
        phone: (j['phone'] as String?) ?? '',
        nextAppointment: (j['nextAppointment'] as String?) ?? '',
      );
}

class _Hotline {
  const _Hotline({
    required this.name,
    required this.number,
    required this.description,
    required this.canCall,
    this.textKeyword,
  });
  final String name;
  final String number;
  final String description;
  final bool canCall;
  final String? textKeyword;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MySupportScreen extends StatefulWidget {
  const MySupportScreen({super.key});
  static const routeName = 'craveMySupportScreen';
  static const routePath = '/crave-my-support';

  @override
  State<MySupportScreen> createState() => _MySupportScreenState();
}

class _MySupportScreenState extends State<MySupportScreen> {
  static const _contactsKey = 'support_contacts_v1';
  static const _therapistKey = 'support_therapist_v1';
  static const _bg = Color(0xFF0A192F);
  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);
  static const _green = Color(0xFF1DB954);
  static const _panicRed = Color(0xFFE53E3E);
  static const _panicOrange = Color(0xFFDD6B20);
  static const _purple = Color(0xFF7B5EA7);
  static const _purpleLight = Color(0xFFB794F4);

  static const _hotlines = [
    _Hotline(
      name: 'SAMHSA Helpline',
      number: '18006624357',
      description: '1-800-662-4357 · Substance Abuse & Mental Health',
      canCall: true,
    ),
    _Hotline(
      name: 'Crisis Text Line',
      number: '741741',
      description: 'Text HOME to 741741',
      canCall: false,
      textKeyword: 'HOME',
    ),
    _Hotline(
      name: '988 Suicide & Crisis Lifeline',
      number: '988',
      description: '988 · Call or text anytime',
      canCall: true,
    ),
  ];

  List<_Contact> _contacts = [];
  _Therapist _therapist = _Therapist();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawC = prefs.getString(_contactsKey);
    final rawT = prefs.getString(_therapistKey);
    if (!mounted) return;
    setState(() {
      if (rawC != null) {
        _contacts = (jsonDecode(rawC) as List<dynamic>)
            .map((e) => _Contact.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (rawT != null) {
        _therapist =
            _Therapist.fromJson(jsonDecode(rawT) as Map<String, dynamic>);
      }
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _contactsKey, jsonEncode(_contacts.map((c) => c.toJson()).toList()));
  }

  Future<void> _saveTherapist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_therapistKey, jsonEncode(_therapist.toJson()));
  }

  // ── Panic ─────────────────────────────────────────────────────────────

  void _onPanicPressed() {
    if (_contacts.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('No Contacts Saved',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          content: const Text(
            'Add a trusted person to your contacts, or call a crisis line right now.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showAddContactDialog();
              },
              child: const Text('Add Contact',
                  style: TextStyle(color: _accent)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _call('988');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _panicRed,
                  foregroundColor: Colors.white),
              child: const Text('Call 988'),
            ),
          ],
        ),
      );
    } else {
      _call(_contacts.first.phone);
    }
  }

  // ── Safe Message ──────────────────────────────────────────────────────

  Future<void> _sendSafeMessage() async {
    if (_contacts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Add a contact first to send a safe message.'),
        backgroundColor: _accentDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    const msg =
        "I'm struggling right now. Please call me when you can.";
    final encoded = Uri.encodeComponent(msg);
    final number = _contacts.first.phone;
    final uri = Uri.parse('sms:$number?body=$encoded');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Therapist ─────────────────────────────────────────────────────────

  Future<void> _showTherapistDialog() async {
    final result = await showDialog<_Therapist>(
      context: context,
      builder: (_) => _TherapistDialog(initial: _therapist),
    );
    if (result != null && mounted) {
      setState(() => _therapist = result);
      await _saveTherapist();
    }
  }

  // ── Contacts ──────────────────────────────────────────────────────────

  Future<void> _showAddContactDialog() async {
    final result = await showDialog<_Contact>(
      context: context,
      builder: (_) => const _AddContactDialog(),
    );
    if (result != null && mounted) {
      setState(() => _contacts.add(result));
      await _saveContacts();
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Contact?',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to remove this contact?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(
                    color: Color(0xFFFF4444),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _contacts.removeAt(index));
      await _saveContacts();
    }
  }

  // ── URL helpers ───────────────────────────────────────────────────────

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _sms(String number) async {
    final uri = Uri(scheme: 'sms', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String number) async {
    final clean = number.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _copy(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied: $label'),
      backgroundColor: _accentDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
          'My Support',
          style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPanicBar(),
          Expanded(child: _buildScrollBody()),
          _buildHotlinesPanel(),
        ],
      ),
    );
  }

  // ── Panic bar ─────────────────────────────────────────────────────────

  Widget _buildPanicBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _onPanicPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_panicRed, _panicOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _panicRed.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'I NEED HELP NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _sendSafeMessage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, color: _accent, size: 17),
                  SizedBox(width: 8),
                  Text(
                    'Send Safe Message',
                    style: TextStyle(
                        color: _accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scrollable body ───────────────────────────────────────────────────

  Widget _buildScrollBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        _buildTherapistSection(),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('My Support Contacts'),
            GestureDetector(
              onTap: _showAddContactDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentDark.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accentDark.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: _accent, size: 14),
                    SizedBox(width: 4),
                    Text('Add', style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_contacts.isEmpty)
          _buildContactsEmpty()
        else
          ..._contacts.asMap().entries.map((e) => _ContactCard(
                contact: e.value,
                onCall: () => _call(e.value.phone),
                onSms: () => _sms(e.value.phone),
                onWhatsApp: () => _openWhatsApp(e.value.phone),
                onDelete: () => _confirmDelete(e.key),
              )),
      ],
    );
  }

  // ── Therapist section ─────────────────────────────────────────────────

  Widget _buildTherapistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('My Therapist'),
        const SizedBox(height: 10),
        _therapist.isEmpty
            ? _buildTherapistEmpty()
            : _buildTherapistCard(),
      ],
    );
  }

  Widget _buildTherapistEmpty() {
    return GestureDetector(
      onTap: _showTherapistDialog,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _purple.withValues(alpha: 0.4), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _purpleLight, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Your Therapist',
              style: TextStyle(
                  color: _purpleLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTherapistCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _purple.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_outlined,
                    color: _purpleLight, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _therapist.name.isNotEmpty
                          ? _therapist.name
                          : 'My Therapist',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    if (_therapist.phone.isNotEmpty)
                      Text(_therapist.phone,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: Colors.white30, size: 18),
                onPressed: _showTherapistDialog,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (_therapist.nextAppointment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: _purpleLight, size: 13),
                  const SizedBox(width: 6),
                  Text(
                    'Next: ${_therapist.nextAppointment}',
                    style: const TextStyle(
                        color: _purpleLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          if (_therapist.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _call(_therapist.phone),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _purple.withValues(alpha: 0.45)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, color: _purpleLight, size: 16),
                    SizedBox(width: 6),
                    Text('Call Therapist',
                        style: TextStyle(
                            color: _purpleLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.people_outline, color: Colors.white12, size: 56),
            SizedBox(height: 12),
            Text('No contacts yet',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            SizedBox(height: 4),
            Text('Tap + to add someone you trust',
                style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Hotlines panel ────────────────────────────────────────────────────

  Widget _buildHotlinesPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded,
                  color: Color(0xFFFF6B6B), size: 15),
              const SizedBox(width: 6),
              _sectionLabel('US Emergency Hotlines'),
            ],
          ),
          const SizedBox(height: 10),
          ..._hotlines.map((h) => _buildHotlineRow(h)),
        ],
      ),
    );
  }

  Widget _buildHotlineRow(_Hotline h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(h.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(h.description,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          if (h.canCall)
            _chipBtn(
                icon: Icons.phone,
                label: 'Call',
                color: _green,
                onTap: () => _call(h.number))
          else
            _chipBtn(
                icon: Icons.copy,
                label: 'Copy',
                color: _accent,
                onTap: () => _copy(
                    h.textKeyword ?? h.number,
                    h.textKeyword ?? h.number)),
          const SizedBox(width: 6),
          _chipBtn(
              icon: Icons.copy_outlined,
              label: 'Copy #',
              color: _accent,
              onTap: () => _copy(h.number, h.number)),
        ],
      ),
    );
  }

  Widget _chipBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _accent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      );
}

// ── Contact Card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onCall,
    required this.onSms,
    required this.onWhatsApp,
    required this.onDelete,
  });

  final _Contact contact;
  final VoidCallback onCall;
  final VoidCallback onSms;
  final VoidCallback onWhatsApp;
  final VoidCallback onDelete;

  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);
  static const _green = Color(0xFF1DB954);
  static const _waGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    _accentDark.withValues(alpha: 0.3),
                child: Text(
                  contact.name.isNotEmpty
                      ? contact.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: _accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    if (contact.relationship.isNotEmpty)
                      Text(contact.relationship,
                          style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.white24, size: 20),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56, top: 2),
            child: Text(contact.phone,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip(
                  icon: Icons.phone,
                  label: 'Call',
                  color: _green,
                  onTap: onCall),
              const SizedBox(width: 8),
              _chip(
                  icon: Icons.message_outlined,
                  label: 'SMS',
                  color: _accentDark,
                  onTap: onSms),
              const SizedBox(width: 8),
              _chip(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  color: _waGreen,
                  onTap: onWhatsApp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Therapist Dialog ──────────────────────────────────────────────────────────

class _TherapistDialog extends StatefulWidget {
  const _TherapistDialog({required this.initial});
  final _Therapist initial;

  @override
  State<_TherapistDialog> createState() => _TherapistDialogState();
}

class _TherapistDialogState extends State<_TherapistDialog> {
  static const _card = Color(0xFF112240);
  static const _purple = Color(0xFF7B5EA7);
  static const _purpleLight = Color(0xFFB794F4);

  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl =
      TextEditingController(text: widget.initial.name);
  late final _phoneCtrl =
      TextEditingController(text: widget.initial.phone);
  late final _apptCtrl =
      TextEditingController(text: widget.initial.nextAppointment);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _apptCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _purpleLight),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      );

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
                  Icon(Icons.psychology_outlined,
                      color: _purpleLight, size: 22),
                  SizedBox(width: 10),
                  Text('My Therapist',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _dec('Therapist name', Icons.person_outline),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration:
                    _dec('Phone number', Icons.phone_outlined),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apptCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                    'Next appointment (e.g. Thu May 22, 3pm)',
                    Icons.calendar_today_outlined),
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
                              color:
                                  Colors.white.withValues(alpha: 0.12)),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          _Therapist(
                            name: _nameCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            nextAppointment: _apptCtrl.text.trim(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Save',
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
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

// ── Add Contact Dialog ────────────────────────────────────────────────────────

class _AddContactDialog extends StatefulWidget {
  const _AddContactDialog();

  @override
  State<_AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<_AddContactDialog> {
  static const _card = Color(0xFF112240);
  static const _accent = Color(0xFF72B9FF);
  static const _accentDark = Color(0xFF0B4EA2);

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.15)),
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
      _Contact(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        relationship: _relCtrl.text.trim(),
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
              const Text('Add Contact',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Name', Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required'
                    : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration:
                    _dec('Phone number', Icons.phone_outlined),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Phone is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                    'Relationship (optional)', Icons.favorite_border),
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
                              color:
                                  Colors.white.withValues(alpha: 0.12)),
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
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
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
