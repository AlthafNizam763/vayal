import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vayal/game/isometric/isometric_coords.dart';
import 'package:vayal/game/isometric/isometric_camera.dart';
import 'package:vayal/game/isometric/isometric_entity.dart';
import 'package:vayal/game/isometric/isometric_player_entity.dart';
import 'package:vayal/game/isometric/isometric_world_scene.dart';
import 'package:vayal/game/missions/mission.dart';
import 'package:vayal/game/missions/mission_manager.dart';
import 'package:three_js/three_js.dart' as three;

void main() {
  group('VAYAL 2.5D Isometric Engine Tests', () {
    test('IsometricCoords accurately performs 2:1 dimetric projection and round-trip conversion', () {
      const coords = IsometricCoords(tileWidth: 64.0, tileHeight: 32.0);

      const worldX = 12.0;
      const worldZ = -8.0;

      final screenPoint = coords.worldToScreen(
        worldX: worldX,
        worldZ: worldZ,
        cameraX: 0.0,
        cameraY: 0.0,
        zoom: 1.0,
        viewport: const Size(800, 600),
      );

      final recoveredWorld = coords.screenToWorld(
        screenPoint: screenPoint,
        cameraX: 0.0,
        cameraY: 0.0,
        zoom: 1.0,
        viewport: const Size(800, 600),
      );

      expect((recoveredWorld.dx - worldX).abs(), lessThan(0.001));
      expect((recoveredWorld.dy - worldZ).abs(), lessThan(0.001));
    });

    test('Isometric Depth Sorting correctly places entities in front based on ground distance', () {
      final entityBack = IsometricPlayerEntity(id: 'back', worldX: -5.0, worldZ: -5.0);
      final entityFront = IsometricPlayerEntity(id: 'front', worldX: 2.0, worldZ: 2.0);

      final list = <IsometricEntity>[entityFront, entityBack];
      list.sort();

      expect(list.first.id, equals('back'));
      expect(list.last.id, equals('front'));
      expect(entityFront.sortKey, greaterThan(entityBack.sortKey));
    });

    test('IsometricCamera smoothly tracks target world position with exponential easing', () {
      final camera = IsometricCamera();
      camera.snapTo(0.0, 0.0);

      expect(camera.x, equals(0.0));
      expect(camera.y, equals(0.0));

      // Move target
      camera.setTarget(10.0, 10.0);
      expect(camera.targetX, isNotNull);

      // Advance by dt = 0.16s
      camera.update(0.16);

      // Camera position moves toward target
      expect(camera.x.abs() + camera.y.abs(), greaterThan(0.0));
    });

    test('Aadi Menon Isometric Player animates walking cycle and changes directional facing', () {
      final player = IsometricPlayerEntity(id: 'aadi', worldX: 0.0, worldZ: 0.0);

      player.setFacingFromMovement(1.0, 1.0);
      expect(player.facing, equals(IsoFacing.southEast));

      player.setFacingFromMovement(-1.0, 1.0);
      expect(player.facing, equals(IsoFacing.southWest));

      player.updateAnimation(0.2, 4.0);
      expect(player.isMoving, isTrue);
      expect(player.walkCycle, greaterThan(0.0));

      player.updateAnimation(0.2, 0.0);
      expect(player.isMoving, isFalse);
      expect(player.walkCycle, equals(0.0));
    });

    test('IsometricWorldScene prevents player movement through solid obstacles', () {
      final scene = IsometricWorldScene();

      // House is located at (-14.0, -10.0) with width/depth 4.8
      final insideHouse = scene.checkCollision(-14.0, -10.0, 0.6);
      expect(insideHouse, isTrue);

      // Open road at (0.0, 0.0) is free of collision
      final onOpenRoad = scene.checkCollision(0.0, 0.0, 0.6);
      expect(onOpenRoad, isFalse);
    });

    test('Mission 01: Homecoming works seamlessly with logical isometric coordinates', () {
      final missionManager = MissionManager();
      expect(missionManager.activeMission, isNotNull);
      expect(missionManager.activeMission!.id, equals('mission_01_homecoming'));

      // Step 1: Objective 1 is reach crossroad
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_reach_crossroad'));

      // Simulate reaching crossroad at (0, 0, 0)
      missionManager.checkLocation(three.Vector3(0.0, 0.0, 0.0));
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_reach_house'));

      // Step 2: Reach Aadi's family house at (-14.0, 0.0, -10.0)
      missionManager.checkLocation(three.Vector3(-14.0, 0.0, -10.0));
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_talk_meera'));

      // Step 3: Talk to Meera on veranda
      missionManager.notifyNpcTalked('meera');
      expect(missionManager.activeMission!.currentObjective!.id, equals('obj_enter_house'));

      // Step 4: Enter family home door
      missionManager.notifyObjectInteracted('aadi_house_door');
      expect(missionManager.completedMissions, contains('mission_01_homecoming'));
      expect(missionManager.activeMission!.id, equals('mission_02_new_start'));
      expect(missionManager.isCheckpointSaved, isTrue);
    });
  });
}
