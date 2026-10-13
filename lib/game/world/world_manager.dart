import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'world_object.dart';

/// Coordinates world lifecycle, spatial bounds, spawn points,
/// dynamic day/night atmospheric lighting, and collision resolution.
class WorldManager {
  final List<WorldObject> objects = [];

  // Designated Named Spawn / Mission Coordinates
  final three.Vector3 spawnPointArrival = three.Vector3(0.0, 0.0, 24.0);
  final three.Vector3 aadiHouseFront = three.Vector3(-14.0, 0.0, -10.0);
  final three.Vector3 generalStoreFront = three.Vector3(12.0, 0.0, -2.0);
  final three.Vector3 parkBenchArea = three.Vector3(-14.0, 0.0, 10.0);
  final three.Vector3 crossroadCenter = three.Vector3(0.0, 0.0, 0.0);

  // Day/Night cycle: hours 0.0 to 24.0 (18.5 is dramatic dusk/sunset)
  double timeOfDay = 18.5;
  bool isDayNightActive = true;
  final double daySpeed = 0.05; // Gentle time progression

  void registerObject(WorldObject obj) {
    objects.add(obj);
  }

  void clear() {
    objects.clear();
  }

  /// Resolves collisions with all solid world objects using sliding response.
  three.Vector2 resolveCollisions({
    required double oldX,
    required double oldZ,
    required double newX,
    required double newZ,
    required double radius,
  }) {
    double resolvedX = newX;
    double resolvedZ = newZ;

    for (final obj in objects) {
      if (!obj.isSolid) continue;
      final step = obj.resolveCollision(oldX, oldZ, resolvedX, resolvedZ, radius);
      resolvedX = step.x;
      resolvedZ = step.y;
    }

    return three.Vector2(resolvedX, resolvedZ);
  }

  /// Locates the closest interactive object in range (e.g. Aadi's front door).
  WorldObject? getInteractiveObjectNearby(three.Vector3 playerPos) {
    WorldObject? closest;
    double minDistance = double.infinity;

    for (final obj in objects) {
      if (!obj.isInteractive) continue;
      final center = obj.mesh.position;
      final dist = math.sqrt(
        math.pow(playerPos.x - center.x, 2) + math.pow(playerPos.z - center.z, 2),
      );

      if (dist <= obj.interactionRadius && dist < minDistance) {
        minDistance = dist;
        closest = obj;
      }
    }

    return closest;
  }

  /// Advances atmospheric time of day and modulates directional sunlight and sky.
  void updateAtmosphere(
    double dt,
    three.Scene scene,
    three.DirectionalLight sun,
    three.AmbientLight ambient,
  ) {
    if (isDayNightActive) {
      timeOfDay = (timeOfDay + dt * daySpeed) % 24.0;
    }

    // Sun angle based on time of day (12.0 = noon, 18.0 = sunset, 24.0 = midnight)
    final sunAngle = ((timeOfDay - 6.0) / 12.0) * math.pi;
    final sunY = math.sin(sunAngle) * 35.0;
    final sunX = math.cos(sunAngle) * 35.0;

    sun.position.setValues(sunX, math.max(0.0, sunY), 20.0);

    // Dusk / Night lighting transitions (Noir Crime Thriller Palette)
    if (timeOfDay >= 18.0 && timeOfDay < 20.0) {
      // Golden Hour to Deep Crimson Twilight
      scene.background = three.Color.fromHex32(0x19161e);
      sun.color = three.Color.fromHex32(0xeb8b52);
      sun.intensity = 1.1;
      ambient.color = three.Color.fromHex32(0x565d70);
      ambient.intensity = 0.5;
    } else if (timeOfDay >= 20.0 || timeOfDay < 5.5) {
      // Midnight Crime Thriller Atmosphere
      scene.background = three.Color.fromHex32(0x0c0f14);
      sun.color = three.Color.fromHex32(0x2f4260);
      sun.intensity = 0.25;
      ambient.color = three.Color.fromHex32(0x202938);
      ambient.intensity = 0.35;
    } else {
      // Daylight / Morning
      scene.background = three.Color.fromHex32(0x1e242d);
      sun.color = three.Color.fromHex32(0xffeedb);
      sun.intensity = 1.3;
      ambient.color = three.Color.fromHex32(0xa6b2c2);
      ambient.intensity = 0.65;
    }
  }
}
