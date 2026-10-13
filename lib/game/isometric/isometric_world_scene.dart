import 'isometric_coords.dart';
import 'isometric_camera.dart';
import 'isometric_player_entity.dart';
import 'isometric_prop_entity.dart';
import '../world/world_object.dart';

/// 2.5D Isometric World Scene representing Veyrapuram in Minecraft-inspired block art.
class IsometricWorldScene {
  final IsometricCoords coords = const IsometricCoords();
  late final IsometricCamera camera;
  late final IsometricPlayerEntity player;

  final List<IsometricPropEntity> props = [];
  final List<WorldBounds> solidColliders = [];

  // Ground grid dimensions
  final int gridMinX = -25;
  final int gridMaxX = 25;
  final int gridMinZ = -25;
  final int gridMaxZ = 25;

  IsometricWorldScene() {
    camera = IsometricCamera(coords: coords, zoom: 1.25);
    // Aadi begins at the village entrance road
    player = IsometricPlayerEntity(
      id: 'player_aadi',
      worldX: 0.0,
      worldZ: 5.0,
    );
    camera.snapTo(player.worldX, player.worldZ);

    _buildVeyrapuramVillage();
  }

  void _buildVeyrapuramVillage() {
    // 1. Aadi's Family House (West road, target for Homecoming mission)
    // Matches existing coordinates in MissionData: (-14.0, -10.0)
    props.add(IsometricPropEntity(
      id: 'aadi_family_house',
      worldX: -14.0,
      worldZ: -10.0,
      propType: PropType.keralaHouse,
      title: "Aadi's Family Home",
    ));
    // Solid collider for the house body
    solidColliders.add(WorldBounds.fromCenter(
      cx: -14.0,
      cz: -10.0,
      width: 4.8,
      depth: 4.8,
    ));

    // Interactive front door of Aadi's house
    props.add(IsometricPropEntity(
      id: 'aadi_house_door',
      worldX: -13.5,
      worldZ: -8.0,
      propType: PropType.doorwayTrigger,
      title: 'Front Door',
      layerPriority: 2,
    ));

    // 2. Balan's Tea Stall at the town crossroad (0, 0)
    props.add(IsometricPropEntity(
      id: 'balan_tea_stall',
      worldX: 4.0,
      worldZ: -2.0,
      propType: PropType.teaStall,
      title: "Balan's Tea Stall",
    ));
    solidColliders.add(WorldBounds.fromCenter(
      cx: 4.0,
      cz: -2.0,
      width: 3.0,
      depth: 3.0,
    ));

    // 3. Palm Trees line along the paddy fields
    final treeLocations = [
      [-6.0, 8.0],
      [-10.0, 4.0],
      [-18.0, -4.0],
      [-8.0, -14.0],
      [8.0, 6.0],
      [12.0, -6.0],
      [6.0, -12.0],
      [14.0, 10.0],
    ];

    for (var i = 0; i < treeLocations.length; i++) {
      final loc = treeLocations[i];
      props.add(IsometricPropEntity(
        id: 'tree_$i',
        worldX: loc[0],
        worldZ: loc[1],
        propType: PropType.palmTree,
      ));
      solidColliders.add(WorldBounds.fromCenter(
        cx: loc[0],
        cz: loc[1],
        width: 1.2,
        depth: 1.2,
      ));
    }

    // 4. Street Lantern posts along main dirt path
    final lampLocations = [
      [-1.5, 3.0],
      [-1.5, -3.0],
      [-8.0, -7.0],
      [2.5, -6.0],
    ];

    for (var i = 0; i < lampLocations.length; i++) {
      final loc = lampLocations[i];
      props.add(IsometricPropEntity(
        id: 'lantern_$i',
        worldX: loc[0],
        worldZ: loc[1],
        propType: PropType.lanternPost,
      ));
      solidColliders.add(WorldBounds.fromCenter(
        cx: loc[0],
        cz: loc[1],
        width: 0.8,
        depth: 0.8,
      ));
    }
  }

  /// Checks if moving to (targetX, targetZ) collides with any solid obstacle.
  bool checkCollision(double targetX, double targetZ, double radius) {
    for (final col in solidColliders) {
      if (col.overlapsCircle(targetX, targetZ, radius)) {
        return true;
      }
    }
    return false;
  }

  /// Updates game physics, camera, and entities each frame.
  void update(double dt) {
    camera.setTarget(player.worldX, player.worldZ, worldY: player.worldY);
    camera.update(dt);
  }
}
