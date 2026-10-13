import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/damage_system.dart';
import '../systems/wanted_system.dart';
import 'vehicle.dart';

/// 3D Police Pursuit Cruiser with flashing sirens, interceptor speed,
/// and aggressive PIT maneuver tactical AI.
class PolicePursuitCruiser {
  final String id;
  final three.Vector3 position;
  double rotationY = 0.0;
  double speed = 0.0;
  final double maxSpeed = 24.0; // Interceptor top speed (~86 km/h)

  late final three.Group group;
  late final three.Mesh sirenLightLeft;
  late final three.Mesh sirenLightRight;
  double _sirenTimer = 0.0;
  bool isExecutingPit = false;

  PolicePursuitCruiser({
    required this.id,
    required three.Vector3 spawnPos,
    this.rotationY = 0.0,
  }) : position = spawnPos.clone() {
    _createMesh();
  }

  void _createMesh() {
    group = three.Group();

    // White & Navy Kerala Police Cruiser
    final whiteMat = three.MeshStandardMaterial();
    whiteMat.color = three.Color.fromHex32(0xe8edf2);
    whiteMat.metalness = 0.5;
    whiteMat.roughness = 0.4;

    final navyMat = three.MeshStandardMaterial();
    navyMat.color = three.Color.fromHex32(0x10243e); // Deep police navy

    final glassMat = three.MeshStandardMaterial();
    glassMat.color = three.Color.fromHex32(0x0a121a);

    final sirenBlueMat = three.MeshStandardMaterial();
    sirenBlueMat.color = three.Color.fromHex32(0x0066ff);
    sirenBlueMat.emissive = three.Color.fromHex32(0x0044cc);

    final sirenRedMat = three.MeshStandardMaterial();
    sirenRedMat.color = three.Color.fromHex32(0xff2233);
    sirenRedMat.emissive = three.Color.fromHex32(0xcc1122);

    // Chassis
    final bodyMesh = three.Mesh(three.BoxGeometry(1.9, 0.65, 4.3), whiteMat);
    bodyMesh.position.setValues(0, 0.58, 0);
    group.add(bodyMesh);

    // Navy side stripe
    final stripe = three.Mesh(three.BoxGeometry(1.92, 0.2, 4.0), navyMat);
    stripe.position.setValues(0, 0.62, 0);
    group.add(stripe);

    // Cabin
    final cabin = three.Mesh(three.BoxGeometry(1.6, 0.65, 2.2), glassMat);
    cabin.position.setValues(0, 1.15, -0.2);
    group.add(cabin);

    // Flashing Siren Bar on Roof
    sirenLightLeft = three.Mesh(three.BoxGeometry(0.35, 0.15, 0.2), sirenBlueMat);
    sirenLightLeft.position.setValues(-0.35, 1.55, -0.2);
    group.add(sirenLightLeft);

    sirenLightRight = three.Mesh(three.BoxGeometry(0.35, 0.15, 0.2), sirenRedMat);
    sirenLightRight.position.setValues(0.35, 1.55, -0.2);
    group.add(sirenLightRight);

    _syncTransform();
  }

  void _syncTransform() {
    group.position.setFrom(position);
    group.rotation.y = rotationY;
  }

  /// AI pursuit tick tracking player vehicle and calculating intercept vectors.
  void update(double dt, Vehicle playerVehicle) {
    _sirenTimer += dt * 8.0;

    // Flashing siren lights
    final blueBright = math.sin(_sirenTimer) > 0;
    (sirenLightLeft.material as three.MeshStandardMaterial).emissiveIntensity =
        blueBright ? 2.5 : 0.2;
    (sirenLightRight.material as three.MeshStandardMaterial).emissiveIntensity =
        blueBright ? 0.2 : 2.5;

    final dx = playerVehicle.position.x - position.x;
    final dz = playerVehicle.position.z - position.z;
    final dist = math.sqrt(dx * dx + dz * dz);

    if (dist > 1.2) {
      // Steer heading towards player vehicle
      final targetAngle = math.atan2(dx, dz);
      double angleDiff = targetAngle - rotationY;
      while (angleDiff < -math.pi) {
        angleDiff += 2 * math.pi;
      }
      while (angleDiff > math.pi) {
        angleDiff -= 2 * math.pi;
      }

      rotationY += angleDiff * math.min(1.0, 3.5 * dt);

      // Accelerate towards player
      final desiredSpeed = (dist > 8.0) ? maxSpeed : playerVehicle.speed + 3.0;
      speed += (desiredSpeed - speed) * math.min(1.0, 4.0 * dt);

      // PIT maneuver check: close distance alongside rear quarter
      if (dist < 4.8 && playerVehicle.speed.abs() > 6.0) {
        isExecutingPit = true;
        // Aggressive ram cut inwards
        rotationY += (angleDiff > 0 ? 0.35 : -0.35) * dt;
      } else {
        isExecutingPit = false;
      }

      // Translate forward
      final forwardX = math.sin(rotationY);
      final forwardZ = math.cos(rotationY);
      position.x += forwardX * speed * dt;
      position.z += forwardZ * speed * dt;
    }

    _syncTransform();
  }
}

/// Tactical police roadblock with cruiser barricades and spiked road strips.
class Roadblock {
  final String id;
  final three.Vector3 center;
  final double radius;
  final bool hasSpikeStrip;
  bool isTriggered = false;

  Roadblock({
    required this.id,
    required this.center,
    this.radius = 6.0,
    this.hasSpikeStrip = true,
  });

  bool containsPosition(three.Vector3 pos) {
    final dx = pos.x - center.x;
    final dz = pos.z - center.z;
    return (dx * dx + dz * dz) <= (radius * radius);
  }
}

/// Advanced Vehicle Pursuit Controller.
/// Coordinates multi-cruiser tactical pursuits, high-speed PIT maneuvers,
/// and roadblock spike strips deployed during police wanted levels.
class PolicePursuitManager {
  final List<PolicePursuitCruiser> activeCruisers = [];
  final List<Roadblock> activeRoadblocks = [];

  bool isPitImminent = false;
  double _spawnCooldown = 0.0;

  // Callbacks
  void Function(double damage)? onPitManeuverLanded;
  void Function()? onSpikeStripImpact;

  PolicePursuitManager() {
    _seedDefaultRoadblocks();
  }

  void _seedDefaultRoadblocks() {
    activeRoadblocks.addAll([
      Roadblock(
        id: 'roadblock_bridge',
        center: three.Vector3(0.0, 0.0, 28.0),
        hasSpikeStrip: true,
      ),
      Roadblock(
        id: 'roadblock_highway',
        center: three.Vector3(25.0, 0.0, 0.0),
        hasSpikeStrip: true,
      ),
    ]);
  }

  /// Updates all active pursuit cruisers and evaluates tactical collisions.
  void update({
    required double dt,
    required Vehicle playerVehicle,
    required WantedSystem wantedSystem,
    required three.Scene scene,
  }) {
    if (!playerVehicle.isOccupied) {
      isPitImminent = false;
      return;
    }

    final wantedStars = wantedSystem.wantedLevel;

    // 1. Spawning / despawning cruisers based on wanted stars
    if (wantedStars >= 2 && activeCruisers.length < (wantedStars >= 4 ? 3 : 2)) {
      _spawnCooldown -= dt;
      if (_spawnCooldown <= 0) {
        _spawnPursuitCruiser(playerVehicle, scene);
        _spawnCooldown = 8.0;
      }
    } else if (wantedStars < 2 && activeCruisers.isNotEmpty) {
      for (final c in activeCruisers) {
        scene.remove(c.group);
      }
      activeCruisers.clear();
      isPitImminent = false;
    }

    // 2. Cruisers tick and PIT collision evaluation
    isPitImminent = false;
    for (final cruiser in activeCruisers) {
      cruiser.update(dt, playerVehicle);

      if (cruiser.isExecutingPit) {
        isPitImminent = true;
      }

      // Check direct collision with player vehicle
      final dx = playerVehicle.position.x - cruiser.position.x;
      final dz = playerVehicle.position.z - cruiser.position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      // Contact threshold (~2.8m)
      if (dist < 2.8) {
        final impactSpeed = (cruiser.speed - playerVehicle.speed).abs();
        if (impactSpeed > 4.0) {
          // PIT maneuver ram contact: apply spinout torque and damage
          final impactDamage = math.min(30.0, impactSpeed * 3.2);
          playerVehicle.takeDamage(DamageInfo(
            amount: impactDamage,
            type: DamageType.vehicleImpact,
            attackerId: cruiser.id,
          ));

          // Spin player car
          playerVehicle.rotationY += (dx > 0 ? 0.35 : -0.35);
          playerVehicle.speed *= 0.65; // Speed loss from collision

          onPitManeuverLanded?.call(impactDamage);
        }
      }
    }

    // 3. Roadblock & Spike Strip Collision Detection
    if (wantedStars >= 3) {
      for (final roadblock in activeRoadblocks) {
        if (!roadblock.isTriggered && roadblock.containsPosition(playerVehicle.position)) {
          if (roadblock.hasSpikeStrip && playerVehicle.speed.abs() > 4.0) {
            roadblock.isTriggered = true;
            playerVehicle.punctureAllTires();
            onSpikeStripImpact?.call();
          }
        }
      }
    }
  }

  void _spawnPursuitCruiser(Vehicle playerVehicle, three.Scene scene) {
    // Spawn 28 meters behind player vehicle
    final behindX = playerVehicle.position.x - math.sin(playerVehicle.rotationY) * 28.0;
    final behindZ = playerVehicle.position.z - math.cos(playerVehicle.rotationY) * 28.0;

    final cruiser = PolicePursuitCruiser(
      id: 'cruiser_${DateTime.now().millisecondsSinceEpoch}',
      spawnPos: three.Vector3(behindX, 0.0, behindZ),
      rotationY: playerVehicle.rotationY,
    );
    cruiser.speed = playerVehicle.speed + 6.0;

    activeCruisers.add(cruiser);
    scene.add(cruiser.group);
  }

  /// Removes all active cruisers from the scene and resets pursuit state.
  void clear(three.Scene scene) {
    for (final c in activeCruisers) {
      scene.remove(c.group);
    }
    activeCruisers.clear();
    isPitImminent = false;
  }
}

