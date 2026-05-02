import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/memory_item.dart';

class MemoryVaultService {
  MemoryVaultService._();
  static final MemoryVaultService instance = MemoryVaultService._();

  static const _prefsKey = 'memory_vault_items';
  static const _uuid = Uuid();

  static MemoryItem _demoItem() => MemoryItem(
        id: 'demo_family_video',
        filePath: 'assets/videos/FAMILY.mp4',
        type: MemoryType.video,
        caption: 'Your family is waiting for you ❤️',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        isDemo: true,
      );

  /// Returns persisted items, seeding the demo item on first launch.
  Future<List<MemoryItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) {
      final demo = _demoItem();
      await _save([demo]);
      return [demo];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MemoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Persists a new memory item.
  ///
  /// On native platforms the file is copied to the app documents directory.
  /// On web, [file.path] is already a blob URL provided by the picker — we
  /// store it directly because dart:io File I/O is unavailable on web.
  /// Removes the demo item automatically when the first real item is added.
  Future<void> addItem(
    XFile file,
    MemoryType type, {
    String? caption,
  }) async {
    final id = _uuid.v4();
    final String savedPath;

    if (kIsWeb) {
      // image_picker_web and file_picker_web both set XFile.path to a blob URL.
      savedPath = file.path;
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      final ext = file.path.contains('.') ? file.path.split('.').last : 'bin';
      final dest = File('${docsDir.path}/memory_vault_$id.$ext');
      await dest.writeAsBytes(await file.readAsBytes());
      savedPath = dest.path;
    }

    final items = await loadItems();
    items.removeWhere((item) => item.isDemo);

    // Enforce 8-item cap: delete oldest real items (by createdAt) if needed.
    while (items.length >= 8) {
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final oldest = items.removeAt(0);
      if (!kIsWeb) {
        final f = File(oldest.filePath);
        if (await f.exists()) await f.delete();
      }
    }

    items.add(MemoryItem(
      id: id,
      filePath: savedPath,
      type: type,
      caption: caption,
      createdAt: DateTime.now(),
    ));
    await _save(items);
  }

  /// Deletes the physical file (unless demo or web) and removes the item.
  Future<void> deleteItem(String id) async {
    final items = await loadItems();
    final index = items.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final item = items[index];
    if (!item.isDemo && !kIsWeb) {
      final file = File(item.filePath);
      if (await file.exists()) await file.delete();
    }

    items.removeAt(index);
    await _save(items);
  }

  /// Persists a new item order supplied by the caller.
  Future<void> reorderItems(List<MemoryItem> newOrder) async {
    await _save(newOrder);
  }

  Future<void> _save(List<MemoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
