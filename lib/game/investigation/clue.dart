/// Evidence category in the detective dossier.
enum ClueCategory {
  photograph,
  document,
  physical,
  forensics,
  testimony,
}

/// Represents an evidence piece that can be examined, read, and connected
/// on the Investigation Board to deduce narrative leads.
class Clue {
  final String id;
  final String title;
  final String? subtitle;
  final String description;
  final ClueCategory category;
  final String source;
  final List<String> tags;
  final String? associatedItemId;
  final String? associatedCollectibleId;

  bool isDiscovered;
  DateTime? discoveredAt;

  Clue({
    required this.id,
    required this.title,
    this.subtitle,
    required this.description,
    required this.category,
    required this.source,
    this.tags = const [],
    this.associatedItemId,
    this.associatedCollectibleId,
    this.isDiscovered = false,
    this.discoveredAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDiscovered': isDiscovered,
        'discoveredAt': discoveredAt?.toIso8601String(),
      };

  void markDiscovered([DateTime? timestamp]) {
    isDiscovered = true;
    discoveredAt = timestamp ?? DateTime.now();
  }
}
