import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

import '../characters/humanoid_builder.dart';

/// Categories of characters in Veyrapuram.
enum NpcType {
  civilian,
  shopkeeper,
  friend,
  familyMember,
  criminal,
  police,
}

/// Dynamic behavioral state of an NPC.
enum NpcState {
  idle,
  walking,
  talking,
  alerted,
}

/// Reusable 3D NPC entity featuring modular styling by role,
/// articulated limbs, procedural idle/walk animations, and player-facing awareness.
typedef Npc = NPC;

class NPC {
  final String id;
  final String name;
  final NpcType type;

  late final three.Group group;
  late final three.Mesh bodyMesh;
  late final three.Mesh headMesh;
  late final three.Mesh leftArm;
  late final three.Mesh rightArm;
  late final three.Mesh leftLeg;
  late final three.Mesh rightLeg;

  final three.Vector3 position = three.Vector3(0, 0, 0);
  double rotationY = 0.0;
  double targetRotationY = 0.0;

  NpcState state = NpcState.idle;
  final double radius = 0.45;
  final double height = 1.8;
  final double interactionRadius = 2.8;

  double _animTime = 0.0;

  NPC({
    required this.id,
    required this.name,
    required this.type,
    three.Vector3? initialPosition,
    double initialRotation = 0.0,
  }) {
    if (initialPosition != null) {
      position.setFrom(initialPosition);
    }
    rotationY = initialRotation;
    targetRotationY = initialRotation;
    _createMesh();
  }

  void _createMesh() {
    group = three.Group();

    // Palette tailoring based on NPC archetype
    int clothingColorHex;
    int secondaryColorHex;
    int hairColorHex;
    HumanoidHairStyle hairStyle;
    int skinHex = 0xcbb094;

    switch (type) {
      case NpcType.familyMember:
        clothingColorHex = 0xb06c54; // Warm terracotta / traditional saree palette
        secondaryColorHex = 0xd4a58e;
        hairColorHex = 0x191008;
        hairStyle = HumanoidHairStyle.long; // Meera / Diya — southern families
        break;
      case NpcType.shopkeeper:
        clothingColorHex = 0x3d5c5c; // Muted teal merchant vest
        secondaryColorHex = 0x223636;
        hairColorHex = 0x2c2c2c; // Salting-grey for Balan
        hairStyle = HumanoidHairStyle.bearded;
        break;
      case NpcType.civilian:
        clothingColorHex = 0x4a5d4e; // Earthy green casual attire
        secondaryColorHex = 0x2c3b30;
        hairColorHex = 0x1a140c;
        hairStyle = HumanoidHairStyle.short;
        break;
      case NpcType.friend:
        clothingColorHex = 0x6e473b; // Weathered leather brown
        secondaryColorHex = 0x1f2329;
        hairColorHex = 0x241a10;
        hairStyle = HumanoidHairStyle.short;
        break;
      case NpcType.criminal:
        clothingColorHex = 0x1e222b; // Dark covert jacket
        secondaryColorHex = 0x8a2820; // Crimson accent
        hairColorHex = 0x131010;
        hairStyle = HumanoidHairStyle.hooded; // Rahu / Devraj hooded or informed coding below
        break;
      case NpcType.police:
        clothingColorHex = 0x827759; // Police khaki uniform
        secondaryColorHex = 0x3d3624;
        hairColorHex = 0x1d1712;
        hairStyle = HumanoidHairStyle.short;
        break;
    }

    // Story-specific identity dispatches
    if (id == 'informant') {
      hairStyle = HumanoidHairStyle.hooded;
    } else if (id == 'devraj') {
      clothingColorHex = 0x4a0a16; // Syndicate royal maroon
      secondaryColorHex = 0xd4af37; // Gold trim
      hairColorHex = 0x10100e;
      hairStyle = HumanoidHairStyle.bearded;
    } else if (id == 'rahu') {
      hairColorHex = 0x0f0d0a;
      hairStyle = HumanoidHairStyle.short;
    }

    final isFemale = id == 'meera' || id == 'diya';

    final rig = buildHumanoid(
      group,
      HumanoidPalette(
        torsoHex: clothingColorHex,
        pantsHex: secondaryColorHex,
        sleeveHex: clothingColorHex,
        skinHex: skinHex,
        hairHex: hairColorHex,
        accentHex: secondaryColorHex,
        hairStyle: hairStyle,
        isFemale: isFemale,
        sareeHex: isFemale ? clothingColorHex : null,
      ),
      torsoY: 1.15,
      headY: 1.75,
      shoulderY: 1.42,
      hipY: 0.78,
      shoulderHalfWidth: isFemale ? 0.28 : 0.30,
      bulk: isFemale ? 0.95 : 1.0,
    );

    bodyMesh = rig.bodyMesh;
    headMesh = rig.headMesh;
    leftArm = rig.leftArm;
    rightArm = rig.rightArm;
    leftLeg = rig.leftLeg;
    rightLeg = rig.rightLeg;

    _syncTransform();
  }

  void setPosition(double x, double y, double z) {
    position.setValues(x, y, z);
    _syncTransform();
  }

  /// Turns NPC smoothly toward a target point (e.g. Aadi).
  void lookAtPosition(three.Vector3 target) {
    final dx = target.x - position.x;
    final dz = target.z - position.z;
    if (math.sqrt(dx * dx + dz * dz) > 0.1) {
      targetRotationY = math.atan2(dx, dz);
    }
  }

  /// Procedural animations for idle breathing or walking cycle.
  void updateAnimation(double dt, double speed) {
    if (speed > 0.05) {
      _animTime += dt * (speed * 2.2);
      final swing = math.sin(_animTime) * 0.6;

      leftLeg.rotation.x = swing;
      rightLeg.rotation.x = -swing;
      leftArm.rotation.x = -swing * 0.7;
      rightArm.rotation.x = swing * 0.7;

      bodyMesh.position.y = 1.15 + (math.sin(_animTime * 2.0).abs() * 0.04);
      headMesh.position.y = 1.75 + (math.sin(_animTime * 2.0).abs() * 0.04);
    } else {
      // Idle breathing cycle
      _animTime += dt * 2.0;
      final breath = math.sin(_animTime) * 0.02;

      leftLeg.rotation.x *= 0.9;
      rightLeg.rotation.x *= 0.9;
      leftArm.rotation.x *= 0.9;
      rightArm.rotation.x *= 0.9;

      bodyMesh.position.y = 1.15 + breath;
      headMesh.position.y = 1.75 + (breath * 1.5);
    }
  }

  void updateRotation(double dt) {
    double diff = targetRotationY - rotationY;
    while (diff < -math.pi) {
      diff += 2 * math.pi;
    }
    while (diff > math.pi) {
      diff -= 2 * math.pi;
    }

    final turnSpeed = 8.0 * dt;
    if (diff.abs() > 0.001) {
      rotationY += diff * math.min(1.0, turnSpeed);
    }
    group.rotation.y = rotationY;
  }

  void _syncTransform() {
    group.position.setFrom(position);
    group.rotation.y = rotationY;
  }
}
