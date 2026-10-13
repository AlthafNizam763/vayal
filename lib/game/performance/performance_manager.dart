import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import '../npc/npc.dart';
import '../world/world_object.dart';
import '../../ui/menu/settings_dialog.dart';

/// Performance snapshot data for real-time diagnostics.
class PerformanceMetrics {
  final double currentFps;
  final double frameTimeMs;
  final int visibleChunksCount;
  final int totalChunksCount;
  final int activeNpcsSimulated;
  final int totalNpcsCount;
  final int collisionChecksCount;
  final GraphicsPreset preset;

  const PerformanceMetrics({
    required this.currentFps,
    required this.frameTimeMs,
    required this.visibleChunksCount,
    required this.totalChunksCount,
    required this.activeNpcsSimulated,
    required this.totalNpcsCount,
    required this.collisionChecksCount,
    required this.preset,
  });
}

/// Central performance and optimization manager enforcing mobile-first LOD,
/// spatial broadphase collision acceleration, dynamic NPC simulation budgeting,
/// and metrics monitoring.
class PerformanceManager extends ChangeNotifier {
  GraphicsPreset _currentPreset = GraphicsPreset.high;

  // Rolling FPS window tracking
  final List<double> _frameTimes = [];
  double _lastFps = 60.0;
  double _lastFrameMs = 16.6;

  // Collision checks tracking
  int _collisionChecksInCurrentFrame = 0;

  // Spatial Grid for Broadphase Collision (20m cell size)
  static const double spatialCellSize = 20.0;
  final Map<String, List<WorldObject>> _spatialGrid = {};

  PerformanceManager({GraphicsPreset defaultPreset = GraphicsPreset.high})
      : _currentPreset = defaultPreset;

  GraphicsPreset get currentPreset => _currentPreset;

  /// Dynamic Render / Visibility Distance based on active quality preset.
  double get renderDistance {
    switch (_currentPreset) {
      case GraphicsPreset.low:
        return 65.0;
      case GraphicsPreset.medium:
        return 95.0;
      case GraphicsPreset.high:
        return 125.0;
      case GraphicsPreset.ultra:
        return 180.0;
    }
  }

  /// Maximum radius from player within which NPC animations and limb rotations are updated.
  double get npcActiveRadius {
    switch (_currentPreset) {
      case GraphicsPreset.low:
        return 18.0;
      case GraphicsPreset.medium:
        return 32.0;
      case GraphicsPreset.high:
        return 48.0;
      case GraphicsPreset.ultra:
        return 65.0;
    }
  }

  /// Applies a new graphics and performance preset.
  void setPreset(GraphicsPreset preset) {
    _currentPreset = preset;
    notifyListeners();
  }

  /// Rebuilds the spatial hashing grid for solid and interactive world objects.
  void buildSpatialGrid(List<WorldObject> objects) {
    _spatialGrid.clear();
    for (final obj in objects) {
      final minCellX = (obj.bounds.minX / spatialCellSize).floor();
      final maxCellX = (obj.bounds.maxX / spatialCellSize).floor();
      final minCellZ = (obj.bounds.minZ / spatialCellSize).floor();
      final maxCellZ = (obj.bounds.maxZ / spatialCellSize).floor();

      for (int cx = minCellX; cx <= maxCellX; cx++) {
        for (int cz = minCellZ; cz <= maxCellZ; cz++) {
          final key = '$cx:$cz';
          _spatialGrid.putIfAbsent(key, () => []).add(obj);
        }
      }
    }
  }

  /// Queries only nearby candidate objects for collision within 3x3 cells of player coordinates.
  List<WorldObject> queryNearbyObjects(three.Vector3 position) {
    final cellX = (position.x / spatialCellSize).floor();
    final cellZ = (position.z / spatialCellSize).floor();

    final List<WorldObject> candidates = [];
    final Set<String> seenIds = {};

    for (int dx = -1; dx <= 1; dx++) {
      for (int dz = -1; dz <= 1; dz++) {
        final key = '${cellX + dx}:${cellZ + dz}';
        final list = _spatialGrid[key];
        if (list != null) {
          for (final obj in list) {
            if (seenIds.add(obj.id)) {
              candidates.add(obj);
            }
          }
        }
      }
    }

    _collisionChecksInCurrentFrame += candidates.length;
    return candidates;
  }

  /// Filters NPCs within simulation budget radius to skip expensive distant updates.
  List<Npc> filterActiveNpcs(List<Npc> allNpcs, three.Vector3 playerPos) {
    final maxDistSq = npcActiveRadius * npcActiveRadius;
    final List<Npc> active = [];

    for (final npc in allNpcs) {
      final dx = npc.position.x - playerPos.x;
      final dz = npc.position.z - playerPos.z;
      if (dx * dx + dz * dz <= maxDistSq) {
        active.add(npc);
      }
    }
    return active;
  }

  /// Records frame tick and computes smoothed rolling average FPS.
  void recordFrame(double dt) {
    if (dt > 0.0) {
      _frameTimes.add(dt);
      if (_frameTimes.length > 30) {
        _frameTimes.removeAt(0);
      }

      final avgDt = _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
      _lastFps = (1.0 / avgDt).clamp(1.0, 120.0);
      _lastFrameMs = avgDt * 1000.0;
    }
  }

  /// Extracts instant performance metrics.
  PerformanceMetrics getMetrics({
    required int visibleChunks,
    required int totalChunks,
    required int activeNpcs,
    required int totalNpcs,
  }) {
    final checks = _collisionChecksInCurrentFrame;
    _collisionChecksInCurrentFrame = 0; // Reset for next frame

    return PerformanceMetrics(
      currentFps: _lastFps,
      frameTimeMs: _lastFrameMs,
      visibleChunksCount: visibleChunks,
      totalChunksCount: totalChunks,
      activeNpcsSimulated: activeNpcs,
      totalNpcsCount: totalNpcs,
      collisionChecksCount: checks,
      preset: _currentPreset,
    );
  }
}
