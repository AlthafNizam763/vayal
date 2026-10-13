import 'package:flutter/material.dart';

/// Base class for all visual entities drawn within the 2.5D isometric world.
abstract class IsometricEntity implements Comparable<IsometricEntity> {
  final String id;
  double worldX;
  double worldZ;
  double worldY;
  int layerPriority;

  IsometricEntity({
    required this.id,
    required this.worldX,
    required this.worldZ,
    this.worldY = 0.0,
    this.layerPriority = 0,
  });

  /// Depth sorting value: entities positioned further in the positive X/Z direction
  /// appear in front of entities further back.
  double get sortKey => (worldX + worldZ) * 1000.0 + (worldY * 10.0) + layerPriority;

  @override
  int compareTo(IsometricEntity other) => sortKey.compareTo(other.sortKey);

  /// Renders this entity to the canvas at its projected screen origin.
  void render(Canvas canvas, Offset screenPos, double scale);
}
