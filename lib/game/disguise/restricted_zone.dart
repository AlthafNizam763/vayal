import 'package:three_js/three_js.dart' as three;
import 'disguise.dart';

/// Defines a high-security territorial sector (port warehouse, police outpost,
/// syndicate safehouse) that triggers trespassing alerts unless the player is
/// wearing an authorized faction disguise.
class RestrictedZone {
  final String id;
  final String name;
  final String description;
  final three.Vector3 center;
  final double radius;
  final List<DisguiseType> allowedDisguiseTypes;

  RestrictedZone({
    required this.id,
    required this.name,
    required this.description,
    required this.center,
    required this.radius,
    required this.allowedDisguiseTypes,
  });

  /// Evaluates whether coordinates fall within the restricted perimeter.
  bool containsPosition(three.Vector3 pos) {
    final dx = pos.x - center.x;
    final dz = pos.z - center.z;
    return (dx * dx + dz * dz) <= (radius * radius);
  }

  /// Verifies whether the supplied disguise has legitimate security clearance.
  bool isAuthorized(Disguise disguise) {
    return allowedDisguiseTypes.contains(disguise.type);
  }
}
