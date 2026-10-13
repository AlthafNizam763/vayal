import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sidescroller_world_scene.dart';

/// CustomPainter rendering multi-layered parallax backgrounds, village street,
/// scenery props, and Aadi Menon in side-scrolling pixel art.
class SideScrollerPainter extends CustomPainter {
  final SideScrollerWorldScene scene;
  final double animationTime;

  SideScrollerPainter({
    required this.scene,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final coords = scene.coords;
    final camera = scene.camera;
    final groundY = size.height * 0.72;

    // ══════════════════════════════════════════════════════════════════
    // LAYER 1: VIBRANT KERALA SKY & ROLLING CLOUDS (PARALLAX FACTOR 0.05)
    // ══════════════════════════════════════════════════════════════════
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1D4ED8), // Deep blue sky
          Color(0xFF38BDF8), // Cyan mid-sky
          Color(0xFFBAE6FD), // Soft horizon haze
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, groundY));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, groundY), skyPaint);

    // Billowing Pixel Clouds
    final cloudOffset = (camera.x * 0.05) % size.width;
    _drawPixelCloud(canvas, Offset(80 - cloudOffset, 60), 60);
    _drawPixelCloud(canvas, Offset(260 - cloudOffset, 40), 80);
    _drawPixelCloud(canvas, Offset(480 - cloudOffset, 75), 70);
    _drawPixelCloud(canvas, Offset(720 - cloudOffset, 50), 90);
    _drawPixelCloud(canvas, Offset(960 - cloudOffset, 65), 75);

    // ══════════════════════════════════════════════════════════════════
    // LAYER 2: DISTANT WESTERN GHATS MOUNTAINS (PARALLAX FACTOR 0.15)
    // ══════════════════════════════════════════════════════════════════
    final mountainOffset = camera.x * 0.15 * coords.scale;
    _drawMountainRange(canvas, size, groundY - 80, mountainOffset);

    // ══════════════════════════════════════════════════════════════════
    // LAYER 3: MID-GROUND PADDY FIELDS & PALM SILHOUETTES (FACTOR 0.40)
    // ══════════════════════════════════════════════════════════════════
    final paddyOffset = camera.x * 0.40 * coords.scale;
    _drawMidgroundPaddy(canvas, size, groundY - 35, paddyOffset);

    // ══════════════════════════════════════════════════════════════════
    // LAYER 4: MAIN VILLAGE STREET (GROUND LEVEL 1.0)
    // ══════════════════════════════════════════════════════════════════
    // Rural packed soil road
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      Paint()..color = const Color(0xFF78350F), // Rich Kerala terracotta soil
    );

    // Grassy border along the roadside
    canvas.drawRect(
      Rect.fromLTWH(0, groundY - 6, size.width, 6),
      Paint()..color = const Color(0xFF4D7C0F), // Fresh lawn grass rim
    );

    // ══════════════════════════════════════════════════════════════════
    // LAYER 5: ENVIRONMENT PROPS & BUILDINGS
    // ══════════════════════════════════════════════════════════════════
    for (final prop in scene.props) {
      final screenFootPos = coords.worldToScreen(
        worldX: prop.worldX,
        worldY: 0.0,
        cameraX: camera.x,
        zoom: camera.zoom,
        viewport: size,
      );

      // Viewport culling
      if (screenFootPos.dx < -150 || screenFootPos.dx > size.width + 150) {
        continue;
      }

      prop.render(canvas, screenFootPos, camera.zoom);
    }

    // ══════════════════════════════════════════════════════════════════
    // LAYER 6: PLAYER CHARACTER (AADI MENON)
    // ══════════════════════════════════════════════════════════════════
    final playerFootPos = coords.worldToScreen(
      worldX: scene.player.worldX,
      worldY: scene.player.worldY,
      cameraX: camera.x,
      zoom: camera.zoom,
      viewport: size,
    );

    scene.player.render(canvas, playerFootPos, camera.zoom);

    // ══════════════════════════════════════════════════════════════════
    // LAYER 7: FOREGROUND TROPICAL FOLIAGE (SUBTLE VIGNETTE EFFECT)
    // ══════════════════════════════════════════════════════════════════
    _drawForegroundTufts(canvas, size, groundY);
  }

  void _drawPixelCloud(Canvas canvas, Offset pos, double w) {
    final cloudPaint = Paint()..color = Colors.white.withAlpha(220);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx, pos.dy, w, w * 0.45), const Radius.circular(8)), cloudPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + 12, pos.dy - 12, w * 0.65, w * 0.5), const Radius.circular(8)), cloudPaint);
  }

  void _drawMountainRange(Canvas canvas, Size size, double baseHeight, double offset) {
    final mountainPath = Path();
    mountainPath.moveTo(0, size.height);
    mountainPath.lineTo(0, baseHeight);

    const step = 90.0;
    for (double x = -step; x < size.width + step * 2; x += step) {
      final peakX = x - (offset % step);
      final peakY = baseHeight - 45 - (math.sin(peakX * 0.015) * 35.0);
      mountainPath.lineTo(peakX + step * 0.5, peakY);
      mountainPath.lineTo(peakX + step, baseHeight);
    }

    mountainPath.lineTo(size.width, size.height);
    mountainPath.close();

    final mountainPaint = Paint()..color = const Color(0xFF38BDF8).withAlpha(160);
    canvas.drawPath(mountainPath, mountainPaint);
  }

  void _drawMidgroundPaddy(Canvas canvas, Size size, double baseHeight, double offset) {
    // Lush rolling green hills of Veyrapuram in the mid distance
    final hillPath = Path();
    hillPath.moveTo(0, size.height);
    hillPath.lineTo(0, baseHeight);

    const step = 140.0;
    for (double x = -step; x < size.width + step * 2; x += step) {
      final peakX = x - (offset % step);
      final peakY = baseHeight - 20 - (math.sin(peakX * 0.02) * 15.0);
      hillPath.lineTo(peakX + step * 0.5, peakY);
      hillPath.lineTo(peakX + step, baseHeight);
    }

    hillPath.lineTo(size.width, size.height);
    hillPath.close();

    final hillPaint = Paint()..color = const Color(0xFF15803D).withAlpha(200);
    canvas.drawPath(hillPath, hillPaint);
  }

  void _drawForegroundTufts(Canvas canvas, Size size, double groundY) {
    final grassPaint = Paint()..color = const Color(0xFF166534);
    for (var x = 10.0; x < size.width; x += 45.0) {
      canvas.drawRect(Rect.fromLTWH(x, groundY - 4, 3, 4), grassPaint);
      canvas.drawRect(Rect.fromLTWH(x + 3, groundY - 7, 3, 7), grassPaint);
      canvas.drawRect(Rect.fromLTWH(x + 6, groundY - 3, 3, 3), grassPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SideScrollerPainter oldDelegate) => true;
}
