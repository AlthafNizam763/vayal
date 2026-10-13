import 'package:three_js/three_js.dart' as three;

/// Categories of environmental concealment objects.
enum HidingSpotType {
  bushes,
  dumpster,
  darkAlcove,
  crates,
}

/// An environmental volume (dense shrubbery, dumpster, shadowed alcove)
/// providing full optical concealment against hostile vision cones.
class HidingSpot {
  final String id;
  final String name;
  final HidingSpotType type;
  final three.Vector3 position;
  final double radius;

  HidingSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.radius = 1.8,
  });

  /// Evaluates whether the entity position falls within the concealment radius.
  bool containsPosition(three.Vector3 pos) {
    final dx = pos.x - position.x;
    final dz = pos.z - position.z;
    return (dx * dx + dz * dz) <= (radius * radius);
  }
}
