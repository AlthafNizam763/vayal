import 'package:flutter/material.dart';
import 'isometric_world_scene.dart';
import 'isometric_entity.dart';
import 'isometric_block_painter.dart';

/// CustomPainter rendering the 2.5D Isometric World of Veyrapuram.
class IsometricWorldPainter extends CustomPainter {
  final IsometricWorldScene scene;
  final double animationTime;

  IsometricWorldPainter({
    required this.scene,
    required this.animationTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final coords = scene.coords;
    final camera = scene.camera;

    // Background clearing — Dark earthy mist / atmosphere
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F172A),
    );

    // 1. Render Visible Ground Grid (Dirt roads, grassy patches, and paddy borders)
    _renderGroundTiles(canvas, size);

    // 2. Gather All Dynamic and Static Entities for Z-Depth Sorting
    final List<IsometricEntity> renderList = [
      ...scene.props,
      scene.player,
    ];

    // Sort strictly back-to-front by depth sort key
    renderList.sort();

    // 3. Render Each Entity at its Calculated Screen Offset
    for (final entity in renderList) {
      final screenPos = coords.worldToScreen(
        worldX: entity.worldX,
        worldZ: entity.worldZ,
        worldY: entity.worldY,
        cameraX: camera.x,
        cameraY: camera.y,
        zoom: camera.zoom,
        viewport: size,
      );

      // Simple viewport culling check
      if (screenPos.dx < -150 ||
          screenPos.dx > size.width + 150 ||
          screenPos.dy < -150 ||
          screenPos.dy > size.height + 150) {
        continue;
      }

      entity.render(canvas, screenPos, camera.zoom);
    }
  }

  void _renderGroundTiles(Canvas canvas, Size size) {
    final coords = scene.coords;
    final camera = scene.camera;

    // Viewport bounds in world space
    const range = 18;
    final centerTileX = scene.player.worldX.round();
    final centerTileZ = scene.player.worldZ.round();

    for (var x = centerTileX - range; x <= centerTileX + range; x++) {
      for (var z = centerTileZ - range; z <= centerTileZ + range; z++) {
        final screenPos = coords.worldToScreen(
          worldX: x.toDouble(),
          worldZ: z.toDouble(),
          cameraX: camera.x,
          cameraY: camera.y,
          zoom: camera.zoom,
          viewport: size,
        );

        if (screenPos.dx < -80 ||
            screenPos.dx > size.width + 80 ||
            screenPos.dy < -80 ||
            screenPos.dy > size.height + 80) {
          continue;
        }

        // Determine ground surface type:
        // Road running along x=0, and branch going to west (x < 0, z between -11 and -9)
        final isMainRoad = (x >= -1 && x <= 1);
        final isHouseRoad = (z >= -10 && z <= -8 && x <= 0 && x >= -14);

        Color tileColor;
        Color? borderColor;

        if (isMainRoad || isHouseRoad) {
          // Rural red soil / packed gravel dirt road
          tileColor = const Color(0xFF78350F);
          borderColor = const Color(0xFF451A03);
        } else if ((x.abs() > 4 && z.abs() > 4)) {
          // Lush Kerala Paddy Green
          tileColor = ((x + z) % 2 == 0)
              ? const Color(0xFF3F6212)
              : const Color(0xFF4D7C0F);
          borderColor = const Color(0xFF365314);
        } else {
          // Village grassy turf
          tileColor = ((x + z) % 2 == 0)
              ? const Color(0xFF15803D)
              : const Color(0xFF166534);
          borderColor = const Color(0xFF14532D);
        }

        IsometricBlockPainter.drawGroundTile(
          canvas: canvas,
          center: screenPos,
          width: coords.tileWidth * camera.zoom,
          height: coords.tileHeight * camera.zoom,
          color: tileColor,
          borderColor: borderColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant IsometricWorldPainter oldDelegate) => true;
}
