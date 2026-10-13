import 'package:flutter/material.dart';

/// Helper utility for rendering Minecraft-inspired isometric 3D cubes / blocks
/// directly onto a Flutter Canvas with authentic pixel/block lighting and textures.
class IsometricBlockPainter {
  /// Draws an isometric block with distinct top, left, and right lit faces.
  /// [baseCenter] is the screen coordinate of the bottom ground point of the cube.
  static void drawBlock({
    required Canvas canvas,
    required Offset baseCenter,
    required double width, // horizontal diameter (e.g. 64)
    required double height, // vertical diameter of top diamond (e.g. 32)
    required double blockHeight, // extruded height of cube walls (e.g. 32)
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
    Color? outlineColor,
  }) {
    final halfW = width * 0.5;
    final halfH = height * 0.5;

    // Ground anchor (center-bottom)
    final bx = baseCenter.dx;
    final by = baseCenter.dy;

    // Top surface coordinates (shifted upward by blockHeight)
    final ty = by - blockHeight;

    // Points for top diamond
    final topN = Offset(bx, ty - halfH);
    final topE = Offset(bx + halfW, ty);
    final topS = Offset(bx, ty + halfH);
    final topW = Offset(bx - halfW, ty);

    // Points for bottom perimeter
    final botW = Offset(bx - halfW, by);
    final botS = Offset(bx, by + halfH);
    final botE = Offset(bx + halfW, by);

    // 1. Left Face (in shade)
    final leftPath = Path()
      ..moveTo(topW.dx, topW.dy)
      ..lineTo(topS.dx, topS.dy)
      ..lineTo(botS.dx, botS.dy)
      ..lineTo(botW.dx, botW.dy)
      ..close();

    final leftPaint = Paint()..color = leftColor;
    canvas.drawPath(leftPath, leftPaint);

    // 2. Right Face (medium light)
    final rightPath = Path()
      ..moveTo(topS.dx, topS.dy)
      ..lineTo(topE.dx, topE.dy)
      ..lineTo(botE.dx, botE.dy)
      ..lineTo(botS.dx, botS.dy)
      ..close();

    final rightPaint = Paint()..color = rightColor;
    canvas.drawPath(rightPath, rightPaint);

    // 3. Top Face (direct sunlight)
    final topPath = Path()
      ..moveTo(topN.dx, topN.dy)
      ..lineTo(topE.dx, topE.dy)
      ..lineTo(topS.dx, topS.dy)
      ..lineTo(topW.dx, topW.dy)
      ..close();

    final topPaint = Paint()..color = topColor;
    canvas.drawPath(topPath, topPaint);

    // Optional pixel outline for Minecraft block aesthetic
    if (outlineColor != null) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawPath(topPath, outlinePaint);
      canvas.drawPath(leftPath, outlinePaint);
      canvas.drawPath(rightPath, outlinePaint);
    }
  }

  /// Draws a flat ground tile (diamond shape).
  static void drawGroundTile({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double height,
    required Color color,
    Color? borderColor,
  }) {
    final halfW = width * 0.5;
    final halfH = height * 0.5;

    final path = Path()
      ..moveTo(center.dx, center.dy - halfH)
      ..lineTo(center.dx + halfW, center.dy)
      ..lineTo(center.dx, center.dy + halfH)
      ..lineTo(center.dx - halfW, center.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = color);

    if (borderColor != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }
}
