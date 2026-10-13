import 'package:flutter/material.dart';
import 'isometric_entity.dart';
import 'isometric_block_painter.dart';

enum PropType {
  keralaHouse,
  palmTree,
  teaStall,
  stoneWall,
  lanternPost,
  paddyBlock,
  doorwayTrigger,
}

/// Isometric environmental building or prop block.
class IsometricPropEntity extends IsometricEntity {
  final PropType propType;
  final String title;

  IsometricPropEntity({
    required super.id,
    required super.worldX,
    required super.worldZ,
    super.worldY = 0.0,
    required this.propType,
    this.title = '',
    super.layerPriority = 0,
  });

  @override
  void render(Canvas canvas, Offset screenPos, double scale) {
    switch (propType) {
      case PropType.keralaHouse:
        _renderKeralaHouse(canvas, screenPos, scale);
        break;
      case PropType.palmTree:
        _renderPalmTree(canvas, screenPos, scale);
        break;
      case PropType.teaStall:
        _renderTeaStall(canvas, screenPos, scale);
        break;
      case PropType.stoneWall:
        _renderStoneWall(canvas, screenPos, scale);
        break;
      case PropType.lanternPost:
        _renderLantern(canvas, screenPos, scale);
        break;
      case PropType.paddyBlock:
        _renderPaddyBlock(canvas, screenPos, scale);
        break;
      case PropType.doorwayTrigger:
        _renderDoorway(canvas, screenPos, scale);
        break;
    }
  }

  void _renderKeralaHouse(Canvas canvas, Offset pos, double s) {
    // Ground foundation
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: pos,
      width: 120 * s,
      height: 60 * s,
      blockHeight: 65 * s,
      topColor: const Color(0xFFE2E8F0), // White/cream plastered walls
      leftColor: const Color(0xFFCBD5E1),
      rightColor: const Color(0xFF94A3B8),
    );

    // Terracotta Mangalore-tiled Roof (Red/orange sloped block)
    final roofBase = Offset(pos.dx, pos.dy - (65 * s));
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: roofBase,
      width: 136 * s,
      height: 68 * s,
      blockHeight: 35 * s,
      topColor: const Color(0xFFB91C1C), // Terracotta clay red
      leftColor: const Color(0xFF991B1B),
      rightColor: const Color(0xFF7F1D1D),
    );

    // Veranda pillars & wooden entrance
    final doorPos = Offset(pos.dx + (15 * s), pos.dy - (10 * s));
    final doorPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: doorPos, width: 22 * s, height: 38 * s),
        Radius.circular(2 * s),
      ),
      doorPaint,
    );
  }

  void _renderPalmTree(Canvas canvas, Offset pos, double s) {
    // Tree Trunk (Cubic segmented wood)
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: pos,
      width: 14 * s,
      height: 7 * s,
      blockHeight: 70 * s,
      topColor: const Color(0xFF78350F),
      leftColor: const Color(0xFF451A03),
      rightColor: const Color(0xFF92400E),
    );

    // Palm Canopy (Dense pixel block greenery)
    final canopyBase = Offset(pos.dx, pos.dy - (70 * s));
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: canopyBase,
      width: 70 * s,
      height: 35 * s,
      blockHeight: 25 * s,
      topColor: const Color(0xFF15803D), // Lush tropical palm green
      leftColor: const Color(0xFF166534),
      rightColor: const Color(0xFF14532D),
    );
  }

  void _renderTeaStall(Canvas canvas, Offset pos, double s) {
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: pos,
      width: 60 * s,
      height: 30 * s,
      blockHeight: 40 * s,
      topColor: const Color(0xFFD97706),
      leftColor: const Color(0xFFB45309),
      rightColor: const Color(0xFF78350F),
    );
  }

  void _renderStoneWall(Canvas canvas, Offset pos, double s) {
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: pos,
      width: 40 * s,
      height: 20 * s,
      blockHeight: 18 * s,
      topColor: const Color(0xFF64748B),
      leftColor: const Color(0xFF475569),
      rightColor: const Color(0xFF334155),
    );
  }

  void _renderLantern(Canvas canvas, Offset pos, double s) {
    IsometricBlockPainter.drawBlock(
      canvas: canvas,
      baseCenter: pos,
      width: 8 * s,
      height: 4 * s,
      blockHeight: 45 * s,
      topColor: const Color(0xFF334155),
      leftColor: const Color(0xFF1E293B),
      rightColor: const Color(0xFF0F172A),
    );

    // Glowing warm lamp top
    final lampPos = Offset(pos.dx, pos.dy - (45 * s));
    canvas.drawCircle(lampPos, 5 * s, Paint()..color = const Color(0xFFFDE047));
  }

  void _renderPaddyBlock(Canvas canvas, Offset pos, double s) {
    IsometricBlockPainter.drawGroundTile(
      canvas: canvas,
      center: pos,
      width: 64 * s,
      height: 32 * s,
      color: const Color(0xFF4D7C0F), // Kerala paddy emerald
      borderColor: const Color(0xFF365314),
    );
  }

  void _renderDoorway(Canvas canvas, Offset pos, double s) {
    // Subtle pulsating glow trigger on the veranda entrance
    final triggerPaint = Paint()
      ..color = const Color(0xFFD97736).withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 32 * s, height: 16 * s),
      triggerPaint,
    );
  }
}
