import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import 'collectible.dart';
import 'collectible_database.dart';

/// Central offline manager for tracking world exploration collectibles,
/// memory inspections, and discovery progression.
class CollectibleManager extends ChangeNotifier {
  final List<Collectible> collectibles;

  void Function(Collectible collectible)? onCollectibleFound;

  CollectibleManager({List<Collectible>? initialList})
      : collectibles = initialList ?? CollectibleDatabase.createDefaultCollectibles();

  int get totalCount => collectibles.length;
  int get collectedCount => collectibles.where((c) => c.isCollected).length;
  double get completionRatio =>
      totalCount > 0 ? (collectedCount / totalCount).clamp(0.0, 1.0) : 0.0;

  /// Retrieves a collectible by ID.
  Collectible? getById(String id) {
    try {
      return collectibles.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Marks a collectible as discovered and collected.
  Collectible? collect(String id) {
    final item = getById(id);
    if (item == null || item.isCollected) return item;

    item.markCollected();
    onCollectibleFound?.call(item);
    notifyListeners();
    return item;
  }

  /// Finds the closest uncollected collectible within interaction distance of the player.
  Collectible? getNearbyCollectible(three.Vector3 playerPos, {double maxRadius = 3.0}) {
    Collectible? closest;
    double closestDistanceSq = maxRadius * maxRadius;

    for (final c in collectibles) {
      if (c.isCollected) continue;

      final dx = c.worldPosition.x - playerPos.x;
      final dz = c.worldPosition.z - playerPos.z;
      final distSq = dx * dx + dz * dz;

      if (distSq <= closestDistanceSq) {
        closestDistanceSq = distSq;
        closest = c;
      }
    }

    return closest;
  }

  /// Returns collected items filtered by category, or all collected if type is null.
  List<Collectible> getCollectedByType(CollectibleType? type) {
    return collectibles.where((c) {
      if (!c.isCollected) return false;
      if (type == null) return true;
      return c.type == type;
    }).toList();
  }

  /// Exports list of collected collectible IDs for save game persistence.
  List<String> getCollectedIds() {
    return collectibles.where((c) => c.isCollected).map((c) => c.id).toList();
  }

  /// Restores collected status from save file.
  void restoreCollectedIds(List<String> ids) {
    final idSet = ids.toSet();
    for (final c in collectibles) {
      if (idSet.contains(c.id)) {
        c.isCollected = true;
      }
    }
    notifyListeners();
  }

  void reset() {
    for (final c in collectibles) {
      c.isCollected = false;
      c.collectedAt = null;
    }
    notifyListeners();
  }
}
