import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vayal/game/sidescroller/sidescroller_coords.dart';
import 'package:vayal/game/sidescroller/sidescroller_camera.dart';
import 'package:vayal/game/sidescroller/sidescroller_player.dart';
import 'package:vayal/game/sidescroller/sidescroller_world_scene.dart';
import 'package:vayal/game/missions/mission.dart';
import 'package:vayal/game/missions/mission_manager.dart';
import 'package:three_js/three_js.dart' as three;

void main() {
  group('VAYAL 2D Side-Scrolling Engine Tests', () {
    test('SideScrollingCoords performs reversible world-to-screen transforms', () {
      const coords = SideScrollingCoords();
      const worldX = 14.5;
      const worldY = 0.0;
      const viewport = Size(1280, 720);

      final screenPoint = coords.worldToScreen(
        worldX: worldX,
        worldY: worldY,
        cameraX: 10.0,
        viewport: viewport,
      );

      final recoveredWorld = coords.screenToWorld(
        screenPoint: screenPoint,
        cameraX: 10.0,
        viewport: viewport,
      );

      expect((recoveredWorld.dx - worldX).abs(), lessThan(0.001));
      expect((recoveredWorld.dy - worldY).abs(), lessThan(0.001));
    });

    test('SideScrollingCamera clamps within level boundaries and eases smoothly', () {
      final camera = SideScrollingCamera(
        initialX: 0.0,
        minWorldX: -10.0,
        maxWorldX: 50.0,
      );

      expect(camera.x, equals(0.0));

      // Attempt to target beyond world boundary
      camera.setTarget(100.0);
      expect(camera.targetX, equals(50.0)); // Clamped to maxWorldX

      // Advance by delta time
      camera.update(0.16);
      expect(camera.x, greaterThan(0.0));
      expect(camera.x, lessThanOrEqualTo(50.0));
    });

    test('SideScrollerPlayer animates walking cycle and flips directional facing', () {
      final player = SideScrollerPlayer(worldX: 0.0);

      player.facing = PlayerFacing.right;
      player.isMoving = true;
      player.update(0.2);

      expect(player.walkCycle, greaterThan(0.0));

      player.facing = PlayerFacing.left;
      expect(player.facing, equals(PlayerFacing.left));

      player.isMoving = false;
      player.update(0.2);
      expect(player.walkCycle, equals(0.0));
    });

    test('SideScrollerWorldScene catalogs Veyrapuram village street props and landmarks', () {
      final scene = SideScrollerWorldScene();

      expect(scene.props.any((p) => p.id == 'aadi_house'), isTrue);
      expect(scene.props.any((p) => p.id == 'stall_balan'), isTrue);
      expect(scene.props.any((p) => p.id == 'meera_npc'), isTrue);
      expect(scene.props.any((p) => p.id == 'tree_banyan'), isTrue);
    });

    test('Mission 01: Homecoming progresses to completion along 2D village street', () {
      final missionManager = MissionManager();
      expect(missionManager.activeMission, isNotNull);
      expect(missionManager.activeMission!.id, equals('mission_01_homecoming'));

      // 1. Walk past Banyan tree crossroad (triggers crossroad objective)
      missionManager.checkLocation(three.Vector3(0.0, 0.0, 0.0));
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_reach_house'));

      // 2. Approach Aadi's family house on west road
      missionManager.checkLocation(three.Vector3(-14.0, 0.0, -10.0));
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_talk_meera'));

      // 3. Talk to Meera on veranda
      missionManager.notifyNpcTalked('meera');
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_enter_house'));

      // 4. Enter family house door
      missionManager.notifyObjectInteracted('aadi_house_door');
      expect(missionManager.completedMissions, contains('mission_01_homecoming'));
      expect(missionManager.activeMission!.id, equals('mission_02_new_start'));
      expect(missionManager.isCheckpointSaved, isTrue);
    });
  });
}
