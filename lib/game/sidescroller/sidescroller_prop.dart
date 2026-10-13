import 'package:flutter/material.dart';

enum SceneryType {
  banyanTree,
  palmTree,
  keralaHouse,
  teaStall,
  woodenFence,
  stoneShrine,
  paddyFieldPatch,
  villageSignpost,
  meeraNpc,
}

/// A 2D interactive or decorative object placed along the Veyrapuram village street.
class SideScrollerProp {
  final String id;
  final String name;
  final SceneryType type;
  final double worldX;
  final double width;
  final double height;
  final bool isSolid;
  final bool isInteractive;
  final String? interactionPrompt;

  const SideScrollerProp({
    required this.id,
    required this.name,
    required this.type,
    required this.worldX,
    this.width = 2.0,
    this.height = 3.0,
    this.isSolid = false,
    this.isInteractive = false,
    this.interactionPrompt,
  });

  void render(Canvas canvas, Offset screenFootPos, double scale) {
    final s = scale;
    final x = screenFootPos.dx;
    final y = screenFootPos.dy;

    switch (type) {
      case SceneryType.keralaHouse:
        _renderKeralaHouse(canvas, x, y, s);
        break;
      case SceneryType.teaStall:
        _renderTeaStall(canvas, x, y, s);
        break;
      case SceneryType.banyanTree:
        _renderBanyanTree(canvas, x, y, s);
        break;
      case SceneryType.palmTree:
        _renderPalmTree(canvas, x, y, s);
        break;
      case SceneryType.stoneShrine:
        _renderStoneShrine(canvas, x, y, s);
        break;
      case SceneryType.woodenFence:
        _renderWoodenFence(canvas, x, y, s);
        break;
      case SceneryType.villageSignpost:
        _renderSignpost(canvas, x, y, s);
        break;
      case SceneryType.meeraNpc:
        _renderMeeraNpc(canvas, x, y, s);
        break;
      case SceneryType.paddyFieldPatch:
        _renderPaddyField(canvas, x, y, s);
        break;
    }
  }

  void _renderKeralaHouse(Canvas canvas, double x, double y, double s) {
    // White/cream plastered house base
    final houseRect = Rect.fromLTWH(x - 60 * s, y - 90 * s, 120 * s, 90 * s);
    canvas.drawRect(houseRect, Paint()..color = const Color(0xFFF1F5F9));

    // Wooden timber framing
    canvas.drawRect(Rect.fromLTWH(x - 60 * s, y - 90 * s, 6 * s, 90 * s), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(x + 54 * s, y - 90 * s, 6 * s, 90 * s), Paint()..color = const Color(0xFF78350F));

    // Wooden Front Door (Entrance to Aadi's family home)
    final doorRect = Rect.fromLTWH(x - 14 * s, y - 50 * s, 28 * s, 50 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(doorRect, Radius.circular(3 * s)), Paint()..color = const Color(0xFF451A03));

    // Sloped Mangalore Terracotta Roof
    final roofPath = Path()
      ..moveTo(x - 75 * s, y - 90 * s)
      ..lineTo(x, y - 140 * s)
      ..lineTo(x + 75 * s, y - 90 * s)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFFB91C1C)); // Rich Kerala clay red

    // Veranda porch overhang
    canvas.drawRect(Rect.fromLTWH(x - 70 * s, y - 92 * s, 140 * s, 8 * s), Paint()..color = const Color(0xFF7F1D1D));
  }

  void _renderTeaStall(Canvas canvas, double x, double y, double s) {
    // Balan's Tea Stall
    final baseRect = Rect.fromLTWH(x - 35 * s, y - 55 * s, 70 * s, 55 * s);
    canvas.drawRect(baseRect, Paint()..color = const Color(0xFFD97706));

    // Canopy striped roof
    final roofRect = Rect.fromLTWH(x - 40 * s, y - 68 * s, 80 * s, 16 * s);
    canvas.drawRect(roofRect, Paint()..color = const Color(0xFFDC2626));

    // Counter shelf
    canvas.drawRect(Rect.fromLTWH(x - 30 * s, y - 28 * s, 60 * s, 6 * s), Paint()..color = const Color(0xFF78350F));
  }

  void _renderBanyanTree(Canvas canvas, double x, double y, double s) {
    // Massive lush Kerala banyan tree with hanging vines
    // Trunk
    canvas.drawRect(Rect.fromLTWH(x - 18 * s, y - 120 * s, 36 * s, 120 * s), Paint()..color = const Color(0xFF451A03));

    // Canopy clusters (Deep pixel foliage)
    canvas.drawCircle(Offset(x - 25 * s, y - 130 * s), 45 * s, Paint()..color = const Color(0xFF15803D));
    canvas.drawCircle(Offset(x + 25 * s, y - 135 * s), 48 * s, Paint()..color = const Color(0xFF166534));
    canvas.drawCircle(Offset(x, y - 155 * s), 50 * s, Paint()..color = const Color(0xFF22C55E));

    // Hanging aerial roots / vines
    canvas.drawRect(Rect.fromLTWH(x - 35 * s, y - 100 * s, 3 * s, 60 * s), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(x + 35 * s, y - 95 * s, 3 * s, 55 * s), Paint()..color = const Color(0xFF78350F));
  }

  void _renderPalmTree(Canvas canvas, double x, double y, double s) {
    // Tall segmented coconut palm
    canvas.drawRect(Rect.fromLTWH(x - 5 * s, y - 130 * s, 10 * s, 130 * s), Paint()..color = const Color(0xFF78350F));
    // Palm leaves radiating at top
    canvas.drawOval(Rect.fromCenter(center: Offset(x - 20 * s, y - 135 * s), width: 45 * s, height: 18 * s), Paint()..color = const Color(0xFF15803D));
    canvas.drawOval(Rect.fromCenter(center: Offset(x + 20 * s, y - 135 * s), width: 45 * s, height: 18 * s), Paint()..color = const Color(0xFF166534));
  }

  void _renderStoneShrine(Canvas canvas, double x, double y, double s) {
    final shrineRect = Rect.fromLTWH(x - 12 * s, y - 35 * s, 24 * s, 35 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(shrineRect, Radius.circular(4 * s)), Paint()..color = const Color(0xFF64748B));
  }

  void _renderWoodenFence(Canvas canvas, double x, double y, double s) {
    canvas.drawRect(Rect.fromLTWH(x - 25 * s, y - 20 * s, 50 * s, 4 * s), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(x - 25 * s, y - 12 * s, 50 * s, 4 * s), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(x - 20 * s, y - 24 * s, 5 * s, 24 * s), Paint()..color = const Color(0xFF451A03));
    canvas.drawRect(Rect.fromLTWH(x + 15 * s, y - 24 * s, 5 * s, 24 * s), Paint()..color = const Color(0xFF451A03));
  }

  void _renderSignpost(Canvas canvas, double x, double y, double s) {
    canvas.drawRect(Rect.fromLTWH(x - 3 * s, y - 35 * s, 6 * s, 35 * s), Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(x - 18 * s, y - 36 * s, 36 * s, 14 * s), Paint()..color = const Color(0xFFFEF3C7));
  }

  void _renderMeeraNpc(Canvas canvas, double x, double y, double s) {
    // Meera (Mother) in traditional Kerala Kasavu Sari (cream cotton + golden border)
    // Saree body
    final bodyRect = Rect.fromLTWH(x - 7 * s, y - 36 * s, 14 * s, 36 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(2 * s)), Paint()..color = const Color(0xFFF8FAFC));
    // Gold Kasavu border
    canvas.drawRect(Rect.fromLTWH(x - 7 * s, y - 24 * s, 14 * s, 3 * s), Paint()..color = const Color(0xFFEAB308));
    // Head with neat silver-streaked hair
    final headRect = Rect.fromLTWH(x - 5 * s, y - 48 * s, 10 * s, 12 * s);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(2 * s)), Paint()..color = const Color(0xFFD97706));
    // Hair
    canvas.drawRect(Rect.fromLTWH(x - 6 * s, y - 50 * s, 12 * s, 5 * s), Paint()..color = const Color(0xFF334155));
  }

  void _renderPaddyField(Canvas canvas, double x, double y, double s) {
    canvas.drawRect(Rect.fromLTWH(x - 40 * s, y - 8 * s, 80 * s, 8 * s), Paint()..color = const Color(0xFF4D7C0F));
  }
}
