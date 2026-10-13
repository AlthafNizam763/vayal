import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

/// Axis-Aligned Bounding Box for fast, robust 3D/2D collision detection.
class WorldBounds {
  final double minX;
  final double maxX;
  final double minZ;
  final double maxZ;
  final double minY;
  final double maxY;

  const WorldBounds({
    required this.minX,
    required this.maxX,
    required this.minZ,
    required this.maxZ,
    this.minY = 0.0,
    this.maxY = 10.0,
  });

  /// Factory helper for center-based box dimensions.
  factory WorldBounds.fromCenter({
    required double cx,
    required double cz,
    required double width,
    required double depth,
    double height = 5.0,
    double cy = 0.0,
  }) {
    final halfW = width / 2;
    final halfD = depth / 2;
    return WorldBounds(
      minX: cx - halfW,
      maxX: cx + halfW,
      minZ: cz - halfD,
      maxZ: cz + halfD,
      minY: cy,
      maxY: cy + height,
    );
  }

  /// Checks if a 2D circle (player footprint) overlaps this bounding box.
  bool overlapsCircle(double cx, double cz, double radius) {
    final closestX = cx.clamp(minX, maxX);
    final closestZ = cz.clamp(minZ, maxZ);

    final distX = cx - closestX;
    final distZ = cz - closestZ;

    return (distX * distX + distZ * distZ) < (radius * radius);
  }
}

/// Represents an interactive or physical entity placed in the world of Veyrapuram.
class WorldObject {
  final String id;
  final String name;
  final three.Object3D mesh;
  final WorldBounds bounds;
  final bool isSolid;
  final bool isInteractive;
  final double interactionRadius;
  final String? interactionPrompt;

  const WorldObject({
    required this.id,
    required this.name,
    required this.mesh,
    required this.bounds,
    this.isSolid = true,
    this.isInteractive = false,
    this.interactionRadius = 2.5,
    this.interactionPrompt,
  });

  /// Resolves circle collision against this AABB with sliding collision response.
  three.Vector2 resolveCollision(
    double oldX,
    double oldZ,
    double newX,
    double newZ,
    double radius,
  ) {
    if (!isSolid) return three.Vector2(newX, newZ);

    // If new position doesn't overlap, no collision
    if (!bounds.overlapsCircle(newX, newZ, radius)) {
      return three.Vector2(newX, newZ);
    }

    // Try sliding along X axis
    double resolvedX = newX;
    if (bounds.overlapsCircle(newX, oldZ, radius)) {
      resolvedX = oldX;
    }

    // Try sliding along Z axis
    double resolvedZ = newZ;
    if (bounds.overlapsCircle(resolvedX, newZ, radius)) {
      resolvedZ = oldZ;
    }

    return three.Vector2(resolvedX, resolvedZ);
  }

  /// Checks if player is within interactive range.
  bool canInteract(three.Vector3 playerPos) {
    if (!isInteractive) return false;
    final centerPos = mesh.position;
    final dx = playerPos.x - centerPos.x;
    final dz = playerPos.z - centerPos.z;
    return math.sqrt(dx * dx + dz * dz) <= interactionRadius;
  }
}
