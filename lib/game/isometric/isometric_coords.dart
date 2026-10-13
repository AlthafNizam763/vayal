import 'package:flutter/material.dart';

/// Standard 2:1 Dimetric Isometric Projection Coordinate System for VAYAL.
///
/// In world space:
/// - X axis extends East (+X) / West (-X)
/// - Z axis extends South (+Z) / North (-Z)
/// - Y axis represents vertical elevation (+Y up)
///
/// Standard tile dimensions:
/// - tileWidth: 64 px
/// - tileHeight: 32 px (2:1 ratio)
class IsometricCoords {
  static const double defaultTileWidth = 64.0;
  static const double defaultTileHeight = 32.0;
  static const double defaultHeightScale = 24.0;

  final double tileWidth;
  final double tileHeight;
  final double heightScale;

  const IsometricCoords({
    this.tileWidth = defaultTileWidth,
    this.tileHeight = defaultTileHeight,
    this.heightScale = defaultHeightScale,
  });

  /// Converts 3D/logical ground coordinates (worldX, worldZ, worldY)
  /// into 2D isometric screen canvas coordinates (Offset).
  Offset worldToScreen({
    required double worldX,
    required double worldZ,
    double worldY = 0.0,
    double cameraX = 0.0,
    double cameraY = 0.0,
    double zoom = 1.0,
    Size viewport = Size.zero,
  }) {
    // Standard 2:1 isometric projection:
    // screenX = (worldX - worldZ) * (tileWidth / 2)
    // screenY = (worldX + worldZ) * (tileHeight / 2) - (worldY * heightScale)
    final isoX = (worldX - worldZ) * (tileWidth * 0.5);
    final isoY = (worldX + worldZ) * (tileHeight * 0.5) - (worldY * heightScale);

    // Camera transform + viewport center
    final screenX = (isoX - cameraX) * zoom + (viewport.width * 0.5);
    final screenY = (isoY - cameraY) * zoom + (viewport.height * 0.5);

    return Offset(screenX, screenY);
  }

  /// Converts 2D screen coordinates back to 2D logical ground coordinates (worldX, worldZ)
  /// assuming worldY = 0 (ground plane).
  Offset screenToWorld({
    required Offset screenPoint,
    double cameraX = 0.0,
    double cameraY = 0.0,
    double zoom = 1.0,
    Size viewport = Size.zero,
    double worldY = 0.0,
  }) {
    // Invert viewport center & zoom
    final isoX = (screenPoint.dx - (viewport.width * 0.5)) / zoom + cameraX;
    final isoY = (screenPoint.dy - (viewport.height * 0.5)) / zoom + cameraY + (worldY * heightScale);

    // Invert projection matrix:
    // isoX / (tileWidth/2) = worldX - worldZ
    // isoY / (tileHeight/2) = worldX + worldZ
    final halfW = tileWidth * 0.5;
    final halfH = tileHeight * 0.5;

    final termA = isoX / halfW;
    final termB = isoY / halfH;

    final worldX = (termA + termB) * 0.5;
    final worldZ = (termB - termA) * 0.5;

    return Offset(worldX, worldZ);
  }

  /// Computes a depth sorting key for proper back-to-front rendering.
  /// Objects positioned further along (worldX + worldZ) are rendered later (in front).
  static double getDepthKey({
    required double worldX,
    required double worldZ,
    double worldY = 0.0,
    int layerPriority = 0,
  }) {
    // Primary sort: ground distance (worldX + worldZ)
    // Secondary sort: height elevation (worldY)
    // Tertiary: layer priority (-10 for ground decals, 0 for entities, +10 for roofs/canopies)
    return (worldX + worldZ) * 1000.0 + (worldY * 10.0) + layerPriority;
  }
}
