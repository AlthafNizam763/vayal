import 'package:flutter/material.dart';

/// 2D Side-Scrolling Coordinate System for VAYAL.
///
/// In world space:
/// - X axis: Horizontal position across Veyrapuram (pixels or world units).
///   Aadi moves along the horizontal street (left <-> right).
/// - Y axis: Vertical elevation (ground level is 0.0, positive Y is upward).
class SideScrollingCoords {
  static const double pixelsPerMeter = 32.0;

  final double scale;

  const SideScrollingCoords({this.scale = pixelsPerMeter});

  /// Converts logical world position (worldX, worldY) to screen pixel coordinates,
  /// accounting for camera tracking, zoom, and ground line offset.
  Offset worldToScreen({
    required double worldX,
    double worldY = 0.0,
    required double cameraX,
    double cameraY = 0.0,
    double zoom = 1.0,
    required Size viewport,
    double groundScreenYRatio = 0.72,
  }) {
    final groundY = viewport.height * groundScreenYRatio;

    final screenX = (worldX - cameraX) * scale * zoom + (viewport.width * 0.5);
    final screenY = groundY - (worldY - cameraY) * scale * zoom;

    return Offset(screenX, screenY);
  }

  /// Converts screen pixel position back to logical world coordinate.
  Offset screenToWorld({
    required Offset screenPoint,
    required double cameraX,
    double cameraY = 0.0,
    double zoom = 1.0,
    required Size viewport,
    double groundScreenYRatio = 0.72,
  }) {
    final groundY = viewport.height * groundScreenYRatio;

    final worldX = (screenPoint.dx - (viewport.width * 0.5)) / (scale * zoom) + cameraX;
    final worldY = (groundY - screenPoint.dy) / (scale * zoom) + cameraY;

    return Offset(worldX, worldY);
  }
}
