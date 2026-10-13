import 'package:three_js/three_js.dart' as three;

/// Environmental interaction point where the player can casually blend in
/// with workers, crowds, or scenery to neutralize hostile suspicion.
class BlendSpot {
  final String id;
  final String name;
  final String blendAction;
  final three.Vector3 position;
  final double radius;

  BlendSpot({
    required this.id,
    required this.name,
    required this.blendAction,
    required this.position,
    this.radius = 2.0,
  });

  /// Evaluates whether entity coordinates overlap with the blending zone.
  bool containsPosition(three.Vector3 pos) {
    final dx = pos.x - position.x;
    final dz = pos.z - position.z;
    return (dx * dx + dz * dz) <= (radius * radius);
  }
}
