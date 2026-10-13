import 'dart:math' as math;
import 'isometric_coords.dart';

/// Smooth 2.5D Isometric Camera with configurable damping and zoom.
class IsometricCamera {
  final IsometricCoords coords;

  // Current camera focus point in isometric pixel space
  double x = 0.0;
  double y = 0.0;

  // Target camera focus point in isometric pixel space
  double targetX = 0.0;
  double targetY = 0.0;

  // Viewport zoom level
  double zoom = 1.0;
  double targetZoom = 1.0;

  // Smoothing stiffness (higher = faster snap, lower = smoother cinematic follow)
  double followSpeed = 6.0;

  IsometricCamera({
    this.coords = const IsometricCoords(),
    this.zoom = 1.0,
  }) {
    targetZoom = zoom;
  }

  /// Instantly teleports the camera to focus on world coordinates (worldX, worldZ).
  void snapTo(double worldX, double worldZ, {double worldY = 0.0}) {
    final isoX = (worldX - worldZ) * (coords.tileWidth * 0.5);
    final isoY = (worldX + worldZ) * (coords.tileHeight * 0.5) - (worldY * coords.heightScale);
    x = isoX;
    y = isoY;
    targetX = isoX;
    targetY = isoY;
  }

  /// Sets the target for the camera to smoothly follow.
  void setTarget(double worldX, double worldZ, {double worldY = 0.0}) {
    targetX = (worldX - worldZ) * (coords.tileWidth * 0.5);
    targetY = (worldX + worldZ) * (coords.tileHeight * 0.5) - (worldY * coords.heightScale);
  }

  /// Updates camera position each frame with frame-rate independent easing.
  void update(double dt) {
    final t = 1.0 - math.exp(-followSpeed * dt);
    x += (targetX - x) * t;
    y += (targetY - y) * t;
    zoom += (targetZoom - zoom) * t;
  }
}
