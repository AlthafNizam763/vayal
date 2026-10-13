import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/damage_system.dart';
import '../npc/npc.dart';
import '../player/player.dart';
import '../player/player_camera.dart';
import 'vehicle.dart';

/// Manages vehicle driving physics, acceleration, Ackermann steering,
/// camera chase interpolation, boundary impacts, and pedestrian collision checks.
class VehicleController {
  Vehicle? activeVehicle;
  bool get isDriving => activeVehicle != null && activeVehicle!.isOccupied;

  // Dynamic Chase camera parameters adapting to vehicle size
  double get cameraDistance => activeVehicle?.vehicleType == VehicleType.truck
      ? 11.5
      : (activeVehicle?.vehicleType == VehicleType.bike ? 5.8 : 8.0);
  double get cameraHeight => activeVehicle?.vehicleType == VehicleType.truck
      ? 4.5
      : (activeVehicle?.vehicleType == VehicleType.bike ? 2.3 : 3.2);

  // Callbacks
  void Function(NPC hitNpc, double impactSpeed)? onPedestrianHit;
  void Function(Vehicle vehicle, double impactDamage)? onVehicleCrashed;

  /// Enters vehicle, positioning player inside and switching camera state.
  void enterVehicle(Vehicle vehicle, Player player) {
    activeVehicle = vehicle;
    vehicle.isOccupied = true;

    // Hide or snap player to vehicle
    player.position.setFrom(vehicle.position);
    player.group.visible = false;
  }

  /// Exits vehicle, placing player safely alongside the driver door.
  void exitVehicle(Player player) {
    if (activeVehicle == null) return;

    final vehicle = activeVehicle!;
    vehicle.isOccupied = false;
    vehicle.speed = 0.0;

    // Drop player on driver's side proportional to vehicle width
    final halfW = (vehicle.width / 2.0) + 0.6;
    final exitOffsetX = -math.cos(vehicle.rotationY) * halfW;
    final exitOffsetZ = math.sin(vehicle.rotationY) * halfW;

    player.setPosition(
      vehicle.position.x + exitOffsetX,
      0.0,
      vehicle.position.z + exitOffsetZ,
    );
    player.rotationY = vehicle.rotationY;
    player.targetRotationY = vehicle.rotationY;
    player.group.visible = true;

    activeVehicle = null;
  }

  /// Updates vehicle physics, kinematics, and visual components each frame.
  void update({
    required double dt,
    required double throttleInput, // -1.0 (reverse/brake) to 1.0 (accelerate)
    required double steerInput, // -1.0 (left) to 1.0 (right)
    required bool handbrake,
    required List<NPC> npcs,
    required PlayerCamera camera,
  }) {
    if (activeVehicle == null || !activeVehicle!.isOccupied) return;

    final vehicle = activeVehicle!;
    if (vehicle.isWrecked) {
      vehicle.speed = 0.0;
      return;
    }

    // 1. Steering calculation
    final targetSteer = steerInput.clamp(-1.0, 1.0) * vehicle.maxSteeringAngle;
    if (steerInput.abs() > 0.05) {
      final steerDelta = targetSteer - vehicle.steeringAngle;
      vehicle.steeringAngle += steerDelta.clamp(-4.0 * dt, 4.0 * dt);
    } else {
      // Auto-center steering wheels
      if (vehicle.steeringAngle > 0) {
        vehicle.steeringAngle = math.max(0.0, vehicle.steeringAngle - vehicle.steeringReturnRate * dt);
      } else if (vehicle.steeringAngle < 0) {
        vehicle.steeringAngle = math.min(0.0, vehicle.steeringAngle + vehicle.steeringReturnRate * dt);
      }
    }

    // Phase 34: Blown tire steering pull and drag
    if (vehicle.hasBlownTire && vehicle.speed.abs() > 2.0) {
      if (vehicle.tiresBlown[0]) vehicle.steeringAngle -= 0.15 * dt; // FL pulls left
      if (vehicle.tiresBlown[1]) vehicle.steeringAngle += 0.15 * dt; // FR pulls right
    }

    // 2. Throttle & Speed calculation
    if (handbrake) {
      // Powerful handbrake deceleration
      if (vehicle.speed > 0) {
        vehicle.speed = math.max(0.0, vehicle.speed - vehicle.brakeRate * 1.5 * dt);
      } else if (vehicle.speed < 0) {
        vehicle.speed = math.min(0.0, vehicle.speed + vehicle.brakeRate * 1.5 * dt);
      }
    } else if (throttleInput > 0.05) {
      if (vehicle.speed < 0) {
        // Braking while in reverse
        vehicle.speed += vehicle.brakeRate * dt;
      } else {
        // Accelerating forward
        vehicle.speed += throttleInput * vehicle.accelerationRate * dt;
        final topSpeed = vehicle.effectiveMaxForwardSpeed;
        if (vehicle.speed > topSpeed) {
          vehicle.speed = topSpeed;
        }
      }
    } else if (throttleInput < -0.05) {
      if (vehicle.speed > 0) {
        // Braking while going forward
        vehicle.speed += throttleInput * vehicle.brakeRate * dt;
        if (vehicle.speed < 0) vehicle.speed = 0.0;
      } else {
        // Reversing
        vehicle.speed += throttleInput * (vehicle.accelerationRate * 0.6) * dt;
        if (vehicle.speed < vehicle.maxReverseSpeed) {
          vehicle.speed = vehicle.maxReverseSpeed;
        }
      }
    } else {
      // Coasting friction drag
      if (vehicle.speed > 0) {
        vehicle.speed = math.max(0.0, vehicle.speed - vehicle.frictionRate * dt);
      } else if (vehicle.speed < 0) {
        vehicle.speed = math.min(0.0, vehicle.speed + vehicle.frictionRate * dt);
      }
    }

    // 3. Ackermann kinematic motion
    if (vehicle.speed.abs() > 0.05) {
      final turnRate = (vehicle.speed / vehicle.wheelBase) * math.tan(vehicle.steeringAngle);
      vehicle.rotationY += turnRate * dt;

      final forwardX = math.sin(vehicle.rotationY);
      final forwardZ = math.cos(vehicle.rotationY);

      vehicle.position.x += forwardX * vehicle.speed * dt;
      vehicle.position.z += forwardZ * vehicle.speed * dt;
    }

    // 4. Perimeter World Boundary Collision (-38 to 38)
    const bound = 37.5;
    if (vehicle.position.x < -bound || vehicle.position.x > bound ||
        vehicle.position.z < -bound || vehicle.position.z > bound) {
      // Rebound impact
      final crashSpeed = vehicle.speed.abs();
      if (crashSpeed > 3.0) {
        final dmg = crashSpeed * 2.5;
        vehicle.takeDamage(DamageInfo(
          amount: dmg,
          type: DamageType.vehicleImpact,
        ));
        onVehicleCrashed?.call(vehicle, dmg);
      }
      vehicle.position.x = vehicle.position.x.clamp(-bound, bound);
      vehicle.position.z = vehicle.position.z.clamp(-bound, bound);
      vehicle.speed = -vehicle.speed * 0.35; // Bounce recoil
    }

    // 5. Update 3D wheel visuals & mesh transforms
    vehicle.updateVisuals(dt);

    // 6. Pedestrian Collision Detection
    _checkPedestrianCollisions(vehicle, npcs);

    // 7. Cinematic Camera Chase Follow
    _updateChaseCamera(camera, vehicle, dt);
  }

  void _checkPedestrianCollisions(Vehicle vehicle, List<NPC> npcs) {
    if (vehicle.speed.abs() < 2.5) return;

    for (final npc in npcs) {
      final dx = npc.position.x - vehicle.position.x;
      final dz = npc.position.z - vehicle.position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      // Within vehicle bounding radius (~2.2m)
      if (dist < 2.2) {
        final impactSpeed = vehicle.speed.abs();
        onPedestrianHit?.call(npc, impactSpeed);

        // Push pedestrian slightly away
        final nx = dist > 0.1 ? dx / dist : 1.0;
        final nz = dist > 0.1 ? dz / dist : 0.0;
        npc.position.x += nx * 2.5;
        npc.position.z += nz * 2.5;
        npc.group.position.setFrom(npc.position);
      }
    }
  }

  void _updateChaseCamera(PlayerCamera camera, Vehicle vehicle, double dt) {
    // Forward heading vector
    final headingX = math.sin(vehicle.rotationY);
    final headingZ = math.cos(vehicle.rotationY);

    // Camera target sits behind the vehicle
    final desiredCamX = vehicle.position.x - (headingX * cameraDistance);
    final desiredCamY = vehicle.position.y + cameraHeight;
    final desiredCamZ = vehicle.position.z - (headingZ * cameraDistance);

    // Smoothly interpolate camera position
    final lerpRate = math.min(1.0, 7.0 * dt);
    camera.camera.position.x += (desiredCamX - camera.camera.position.x) * lerpRate;
    camera.camera.position.y += (desiredCamY - camera.camera.position.y) * lerpRate;
    camera.camera.position.z += (desiredCamZ - camera.camera.position.z) * lerpRate;

    // Look at target point slightly above hood
    final lookTargetX = vehicle.position.x + (headingX * 2.0);
    final lookTargetY = vehicle.position.y + 1.2;
    final lookTargetZ = vehicle.position.z + (headingZ * 2.0);

    camera.camera.lookAt(three.Vector3(lookTargetX, lookTargetY, lookTargetZ));
  }
}
