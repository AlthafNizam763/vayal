import 'package:three_js/three_js.dart' as three;

/// Categories of hidden and exploration collectibles in Veyrapuram.
enum CollectibleType {
  photograph,
  document,
  hiddenLetter,
  memory,
  storyClue,
}

/// Represents an exploration collectible scattered across the 3D world.
class Collectible {
  final String id;
  final String title;
  final String subtitle;
  final CollectibleType type;
  final String description;
  final String memoryText;
  final three.Vector3 worldPosition;
  final String locationName;
  final String? clueId;
  final Map<String, dynamic>? metadata;

  bool isCollected;
  DateTime? collectedAt;

  Collectible({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.description,
    required this.memoryText,
    required this.worldPosition,
    required this.locationName,
    this.clueId,
    this.metadata,
    this.isCollected = false,
    this.collectedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isCollected': isCollected,
        'collectedAt': collectedAt?.toIso8601String(),
      };

  void markCollected([DateTime? timestamp]) {
    isCollected = true;
    collectedAt = timestamp ?? DateTime.now();
  }
}
