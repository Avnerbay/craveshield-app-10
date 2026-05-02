enum MemoryType { video, image }

class MemoryItem {
  MemoryItem({
    required this.id,
    required this.filePath,
    required this.type,
    required this.createdAt,
    this.caption,
    this.isDemo = false,
  });

  final String id;
  final String filePath;
  final MemoryType type;
  final String? caption;
  final DateTime createdAt;
  final bool isDemo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'type': type.name,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'isDemo': isDemo,
      };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
        id: json['id'] as String,
        filePath: json['filePath'] as String,
        type: MemoryType.values.firstWhere((e) => e.name == json['type']),
        caption: json['caption'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isDemo: json['isDemo'] as bool? ?? false,
      );
}
