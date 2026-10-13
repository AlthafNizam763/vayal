import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PlayerFacing { right, left }

/// Aadithyan "Aadi" Menon — 2D Pixel-Art Side-Scrolling Character.
/// Rendered with authentic pixel clusters matching the game visual style:
/// - Distinctive red-brown hair
/// - Dusky South Indian skin tone
/// - Dark noir jacket / backpack
/// - Folded trousers / boots
/// - Walking leg swing and arm bobbing
class SideScrollerPlayer {
  double worldX = 0.0;
  double worldY = 0.0;
  double velocityX = 0.0;
  double velocityY = 0.0;

  bool isGrounded = true;
  bool isMoving = false;
  bool isSprinting = false;

  PlayerFacing facing = PlayerFacing.right;
  double walkCycle = 0.0;

  // Collision box dimensions (meters)
  final double width = 0.9;
  final double height = 1.8;

  SideScrollerPlayer({
    this.worldX = 0.0,
    this.worldY = 0.0,
  });

  void update(double dt) {
    if (isMoving) {
      final speedRate = isSprinting ? 12.0 : 8.0;
      walkCycle += dt * speedRate;
    } else {
      walkCycle = 0.0;
    }
  }

  void render(Canvas canvas, Offset screenFootPos, double scale) {
    final isFlipped = (facing == PlayerFacing.left);
    final legSwing = isMoving ? math.sin(walkCycle) * 6.0 : 0.0;
    final armSwing = isMoving ? math.cos(walkCycle) * 5.0 : 0.0;
    final breathBob = isMoving ? 0.0 : math.sin(walkCycle) * 1.5;

    canvas.save();
    canvas.translate(screenFootPos.dx, screenFootPos.dy);
    if (isFlipped) {
      canvas.scale(-1.0, 1.0);
    }

    // 1. Shadow beneath feet
    final shadowPaint = Paint()..color = Colors.black.withAlpha(90);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 0), width: 28 * scale, height: 10 * scale),
      shadowPaint,
    );

    final s = scale;

    // 2. Legs & Boots (Dark trousers + leather boots)
    final bootColor = const Color(0xFF7F1D1D); // Red-brown leather boots
    final pantColor = const Color(0xFF1E293B); // Dark slate trousers

    // Left Leg
    final lLegRect = Rect.fromLTWH(-8 * s + legSwing, -18 * s, 6 * s, 18 * s);
    canvas.drawRect(lLegRect, Paint()..color = pantColor);
    final lBootRect = Rect.fromLTWH(-9 * s + legSwing, -6 * s, 8 * s, 6 * s);
    canvas.drawRect(lBootRect, Paint()..color = bootColor);

    // Right Leg
    final rLegRect = Rect.fromLTWH(2 * s - legSwing, -18 * s, 6 * s, 18 * s);
    canvas.drawRect(rLegRect, Paint()..color = pantColor);
    final rBootRect = Rect.fromLTWH(1 * s - legSwing, -6 * s, 8 * s, 6 * s);
    canvas.drawRect(rBootRect, Paint()..color = bootColor);

    // 3. Torso, Tunic & Backpack
    final torsoY = -38 * s + breathBob;
    final tunicRect = Rect.fromLTWH(-9 * s, torsoY, 18 * s, 20 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tunicRect, Radius.circular(2 * s)),
      Paint()..color = const Color(0xFF991B1B), // Crimson-brown tunic
    );

    // Leather belt & buckled harness
    canvas.drawRect(
      Rect.fromLTWH(-9 * s, torsoY + 12 * s, 18 * s, 4 * s),
      Paint()..color = const Color(0xFF78350F), // Leather brown belt
    );
    canvas.drawRect(
      Rect.fromLTWH(-2 * s, torsoY + 12 * s, 4 * s, 4 * s),
      Paint()..color = const Color(0xFFFBBF24), // Gold buckle
    );

    // Backpack visible on back
    final packRect = Rect.fromLTWH(-14 * s, torsoY + 2 * s, 6 * s, 15 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(packRect, Radius.circular(2 * s)),
      Paint()..color = const Color(0xFF0284C7), // Blue travel pack
    );

    // 4. Arms & Hands
    final armColor = const Color(0xFFB45309); // Dusky skin
    final armY = torsoY + 2 * s;
    final armRect = Rect.fromLTWH(8 * s, armY + armSwing, 5 * s, 16 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(armRect, Radius.circular(2 * s)),
      Paint()..color = armColor,
    );

    // 5. Head, Facial Features & Hair
    final headY = torsoY - 14 * s;
    final faceRect = Rect.fromLTWH(-6 * s, headY, 12 * s, 14 * s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, Radius.circular(2 * s)),
      Paint()..color = const Color(0xFFD97706), // Warm dusky skin tone
    );

    // Eyes
    canvas.drawRect(
      Rect.fromLTWH(2 * s, headY + 5 * s, 2 * s, 2 * s),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Red-brown stylized hair (matching the prompt art)
    final hairPaint = Paint()..color = const Color(0xFFEA580C);
    // Hair bangs & ponytail
    canvas.drawRect(Rect.fromLTWH(-7 * s, headY - 3 * s, 14 * s, 6 * s), hairPaint);
    canvas.drawRect(Rect.fromLTWH(-8 * s, headY - 5 * s, 5 * s, 5 * s), hairPaint);
    canvas.drawRect(Rect.fromLTWH(-10 * s, headY + 1 * s, 4 * s, 10 * s), hairPaint);

    canvas.restore();
  }
}
