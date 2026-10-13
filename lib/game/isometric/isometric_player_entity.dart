import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'isometric_entity.dart';
import 'isometric_block_painter.dart';

enum IsoFacing { southEast, southWest, northEast, northWest }

/// Aadithyan "Aadi" Menon — Minecraft-inspired block-art character representation.
/// Features authentic pixel block proportions: head, torso, arms, legs, South Indian attire
/// (casual shirt and folded mundu/trousers), directional facing, and walk oscillation.
class IsometricPlayerEntity extends IsometricEntity {
  IsoFacing facing = IsoFacing.southEast;
  double walkCycle = 0.0;
  bool isMoving = false;
  bool isSprinting = false;

  IsometricPlayerEntity({
    required super.id,
    required super.worldX,
    required super.worldZ,
    super.worldY = 0.0,
  }) : super(layerPriority: 0);

  void updateAnimation(double dt, double speed) {
    if (speed > 0.1) {
      isMoving = true;
      final cycleSpeed = isSprinting ? 12.0 : 8.0;
      walkCycle += dt * cycleSpeed;
    } else {
      isMoving = false;
      walkCycle = 0.0;
    }
  }

  void setFacingFromMovement(double moveX, double moveZ) {
    if (moveX.abs() < 0.01 && moveZ.abs() < 0.01) return;

    if (moveX >= 0 && moveZ >= 0) {
      facing = IsoFacing.southEast;
    } else if (moveX < 0 && moveZ >= 0) {
      facing = IsoFacing.southWest;
    } else if (moveX >= 0 && moveZ < 0) {
      facing = IsoFacing.northEast;
    } else {
      facing = IsoFacing.northWest;
    }
  }

  @override
  void render(Canvas canvas, Offset screenPos, double scale) {
    final legSwing = isMoving ? math.sin(walkCycle) * 4.0 : 0.0;
    final armSwing = isMoving ? math.cos(walkCycle) * 4.0 : 0.0;

    // Shadow at feet
    final shadowPaint = Paint()..color = Colors.black.withAlpha(90);
    canvas.drawOval(
      Rect.fromCenter(center: screenPos, width: 28 * scale, height: 14 * scale),
      shadowPaint,
    );

    // 1. Legs / Mundu lower half
    final legBaseY = screenPos.dy;
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx - (4 * scale), legBaseY + legSwing),
      width: 10 * scale,
      height: 5 * scale,
      blockHeight: 14 * scale,
      topColor: const Color(0xFFE5E7EB),
      leftColor: const Color(0xFFD1D5DB),
      rightColor: const Color(0xFF9CA3AF),
    );
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx + (4 * scale), legBaseY - legSwing),
      width: 10 * scale,
      height: 5 * scale,
      blockHeight: 14 * scale,
      topColor: const Color(0xFFE5E7EB),
      leftColor: const Color(0xFFD1D5DB),
      rightColor: const Color(0xFF9CA3AF),
    );

    // 2. Torso (Aadi's Dark Navy / Noir Shirt)
    final torsoBaseY = legBaseY - (14 * scale);
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx, torsoBaseY),
      width: 18 * scale,
      height: 9 * scale,
      blockHeight: 18 * scale,
      topColor: const Color(0xFF1E293B),
      leftColor: const Color(0xFF0F172A),
      rightColor: const Color(0xFF334155),
    );

    // Arms
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx - (11 * scale), torsoBaseY + armSwing),
      width: 6 * scale,
      height: 3 * scale,
      blockHeight: 16 * scale,
      topColor: const Color(0xFFB45309), // Dusky skin tone
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFFD97706),
    );
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx + (11 * scale), torsoBaseY - armSwing),
      width: 6 * scale,
      height: 3 * scale,
      blockHeight: 16 * scale,
      topColor: const Color(0xFFB45309),
      leftColor: const Color(0xFF92400E),
      rightColor: const Color(0xFFD97706),
    );

    // 3. Head (Dusky Indian complexioned block + Dark Hair/Beard)
    final headBaseY = torsoBaseY - (18 * scale);
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: Offset(screenPos.dx, headBaseY),
      width: 14 * scale,
      height: 7 * scale,
      blockHeight: 14 * scale,
      topColor: const Color(0xFF18181B), // Black hair on top
      leftColor: const Color(0xFF92400E), // Face side in shadow
      rightColor: const Color(0xFFB45309), // Face front lit
    );
  }
}
