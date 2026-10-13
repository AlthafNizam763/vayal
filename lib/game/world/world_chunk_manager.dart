import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'world_region.dart';

/// Phase 15: World Chunk & Streaming Manager for open-world Veyrapuram.
/// Tracks player position across regions, performs view distance culling,
/// and manages district entry notifications.
class WorldChunkManager {
  WorldRegion activeRegion = WorldRegion.village;
  WorldRegion get currentRegion => activeRegion;
  final Map<WorldRegion, three.Group> regionGroups = {};

  // Maximum active rendering distance for regional props (meters)
  double renderDistance = 115.0;

  // Callbacks
  void Function(WorldRegion oldRegion, WorldRegion newRegion)? onRegionChanged;

  /// Registers a ThreeJS scene group for a specific world region.
  void registerRegionGroup(WorldRegion region, three.Group group) {
    regionGroups[region] = group;
  }

  /// Evaluates player position, identifies the closest region,
  /// triggers region transition events, and culls distant 3D groups.
  WorldRegion update(three.Vector3 playerPosition) {
    WorldRegion closestRegion = WorldRegion.village;
    double minDistanceSq = double.infinity;

    // 1. Identify closest region
    for (final entry in RegionData.registry.entries) {
      final center = entry.value.center;
      final dx = playerPosition.x - center.x;
      final dz = playerPosition.z - center.z;
      final distSq = dx * dx + dz * dz;

      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        closestRegion = entry.key;
      }
    }

    // 2. Fire transition event if region changed
    if (closestRegion != activeRegion) {
      final old = activeRegion;
      activeRegion = closestRegion;
      onRegionChanged?.call(old, activeRegion);
    }

    // 3. Perform distance-based chunk culling for optimal rendering performance
    for (final entry in regionGroups.entries) {
      final regionData = RegionData.registry[entry.key];
      if (regionData == null) continue;

      final dx = playerPosition.x - regionData.center.x;
      final dz = playerPosition.z - regionData.center.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      // Keep active region and adjacent visible regions alive; cull far objects
      final shouldBeVisible = dist <= (renderDistance + regionData.radius);
      if (entry.value.visible != shouldBeVisible) {
        entry.value.visible = shouldBeVisible;
      }
    }

    return activeRegion;
  }

  /// Gets metadata for the currently active region.
  RegionData get activeRegionData => RegionData.registry[activeRegion]!;
}
