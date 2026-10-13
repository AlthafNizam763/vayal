import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

import '../characters/humanoid_builder.dart';

/// Enhanced 3D placeholder character for Aadithyan "Aadi" Menon.
/// Features articulated limbs with procedural walk/run animation,
/// collision radius, and transform synchronization.
class Player {
  late final three.Group group;
  late final three.Mesh bodyMesh;
  late final three.Mesh headMesh;
  late final three.Mesh leftArm;
  late final three.Mesh rightArm;
  late final three.Mesh leftLeg;
  late final three.Mesh rightLeg;
  late final three.Mesh directionMarker;

  final three.Vector3 position = three.Vector3(0, 0, 0);
  double rotationY = 0.0;
  double targetRotationY = 0.0;

  // Collision dimensions
  final double radius = 0.45;
  final double height = 1.8;

  // Vital stats
  double health = 100.0;
  double maxHealth = 100.0;

  // Animation cycle tracking
  double _animTime = 0.0;

  Player() {
    _createMesh();
  }

  void _createMesh() {
    group = three.Group();

    // Aadi "velvet streetwear" palette — Noir / Crime Thriller aesthetic
    final rig = buildHumanoid(
      group,
      const HumanoidPalette(
        torsoHex: 0x19212c, // Dark charcoal jacket
        pantsHex: 0x11161d, // Deep dark trousers
        sleeveHex: 0x19212c,
        skinHex: 0xc5aa91, // Warm tanned skin
        hairHex: 0x141009,
        accentHex: 0xbf4d28, // Muted red/amber collar accent
        hairStyle: HumanoidHairStyle.short,
      ),
      torsoY: 1.15,
      headY: 1.8,
      shoulderY: 1.42,
      hipY: 0.78,
    );

    bodyMesh = rig.bodyMesh;
    headMesh = rig.headMesh;
    leftArm = rig.leftArm;
    rightArm = rig.rightArm;
    leftLeg = rig.leftLeg;
    rightLeg = rig.rightLeg;

    // 3. Realistic Jacket Zipper & Collar Lapel Trim (noir crime thriller styling)
    final accentMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xbf4d28) // Muted red/amber collar accent
      ..roughness = 0.5
      ..metalness = 0.3;
    final markerGeo = three.CylinderGeometry(0.015, 0.015, 0.38, 8);
    directionMarker = three.Mesh(markerGeo, accentMat);
    directionMarker.position.setValues(0, 1.25, 0.22);
    group.add(directionMarker);

    _syncTransform();
  }

  void setPosition(double x, double y, double z) {
    position.setValues(x, y, z);
    _syncTransform();
  }

  /// Updates procedural limb animation based on speed, delta time, and combat stance.
  void updateAnimation(
    double dt,
    double speed,
    bool isGrounded, {
    bool isLightAttacking = false,
    bool isHeavyAttacking = false,
    bool isBlocking = false,
    bool isDodging = false,
    bool isKnockedDown = false,
    bool isCrouching = false,
  }) {
    if (isKnockedDown) {
      group.rotation.x = -math.pi / 2;
      return;
    } else {
      group.rotation.x = 0.0;
    }

    if (isCrouching) {
      bodyMesh.position.y = 0.92;
      headMesh.position.y = 1.48;
    }

    if (isLightAttacking) {
      rightArm.rotation.x = -1.55;
      leftArm.rotation.x = -0.3;
      return;
    }

    if (isHeavyAttacking) {
      rightArm.rotation.x = -1.7;
      leftArm.rotation.x = -1.4;
      return;
    }

    if (isBlocking) {
      leftArm.rotation.x = -1.25;
      rightArm.rotation.x = -1.25;
      return;
    }

    if (isDodging) {
      bodyMesh.position.y = 0.85;
      headMesh.position.y = 1.45;
      return;
    }

    if (!isGrounded) {
      // In air / jumping pose: slight tuck
      leftLeg.rotation.x = -0.4;
      rightLeg.rotation.x = 0.3;
      leftArm.rotation.x = -0.6;
      rightArm.rotation.x = 0.5;
      return;
    }

    if (speed > 0.1) {
      // Step frequency scales with movement speed
      final frequency = speed * 1.8;
      _animTime += dt * frequency;

      final swing = math.sin(_animTime) * 0.7;

      // Opposing arm and leg swing
      leftLeg.rotation.x = swing;
      rightLeg.rotation.x = -swing;
      leftArm.rotation.x = -swing * 0.8;
      rightArm.rotation.x = swing * 0.8;

      // Subtle vertical body bobbing
      bodyMesh.position.y = 1.15 + (math.sin(_animTime * 2.0).abs() * 0.05);
      headMesh.position.y = 1.8 + (math.sin(_animTime * 2.0).abs() * 0.05);
    } else {
      // Settle smoothly to idle stance
      leftLeg.rotation.x *= 0.85;
      rightLeg.rotation.x *= 0.85;
      leftArm.rotation.x *= 0.85;
      rightArm.rotation.x *= 0.85;
      bodyMesh.position.y = isCrouching ? 0.92 : 1.15;
      headMesh.position.y = isCrouching ? 1.48 : 1.8;
      _animTime = 0.0;
    }
  }

  /// Smoothly rotates character facing toward desired angle.
  void updateRotation(double dt) {
    double diff = targetRotationY - rotationY;
    while (diff < -math.pi) {
      diff += 2 * math.pi;
    }
    while (diff > math.pi) {
      diff -= 2 * math.pi;
    }

    final turnSpeed = 12.0 * dt;
    if (diff.abs() > 0.001) {
      rotationY += diff * math.min(1.0, turnSpeed);
    }
    group.rotation.y = rotationY;
  }

  /// Updates 3D mesh palette to visually reflect active disguise.
  void applyDisguiseVisuals({
    required int bodyColorHex,
    required int accentColorHex,
  }) {
    if (bodyMesh.material is three.MeshStandardMaterial) {
      (bodyMesh.material as three.MeshStandardMaterial).color =
          three.Color.fromHex32(bodyColorHex);
    }
    // Sleeves share the jacket palette, repaint them too so the disguise
    // reads across the whole outfit.
    for (final arm in [leftArm, rightArm]) {
      if (arm.material is three.MeshStandardMaterial) {
        (arm.material as three.MeshStandardMaterial).color =
            three.Color.fromHex32(bodyColorHex);
      }
    }
    if (directionMarker.material is three.MeshStandardMaterial) {
      (directionMarker.material as three.MeshStandardMaterial).color =
          three.Color.fromHex32(accentColorHex);
    }
  }

  void _syncTransform() {
    group.position.setFrom(position);
    group.rotation.y = rotationY;
  }
}
