import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../world/world_manager.dart';
import 'player.dart';
import 'player_camera.dart';

/// Movement state for animation and HUD feedback.
enum MovementState {
  idle,
  crouching,
  walking,
  running,
  sprinting,
  jumping,
}

/// Handles player movement physics, camera-relative directional vectors,
/// collision checks, jumping, gravity, and input translation.
class PlayerController {
  final Player player;
  final PlayerCamera camera;

  // Speeds in units/second
  final double sneakSpeed = 1.6;
  final double walkSpeed = 3.2;
  final double runSpeed = 6.0;
  final double sprintSpeed = 9.2;
  final double jumpForce = 7.4;
  final double gravity = 22.0;

  // Stealth posture
  bool isCrouching = false;

  // World boundary collision limits
  final double worldBoundMinX = -38.0;
  final double worldBoundMaxX = 38.0;
  final double worldBoundMinZ = -38.0;
  final double worldBoundMaxZ = 38.0;

  // Input states
  Offset moveInput = Offset.zero; // (-1 to 1)
  bool isSprintRequested = false;
  bool isJumpRequested = false;

  // Physics states
  double verticalVelocity = 0.0;
  bool isGrounded = true;
  double currentSpeed = 0.0;
  MovementState state = MovementState.idle;

  final WorldManager? worldManager;

  PlayerController({
    required this.player,
    required this.camera,
    this.worldManager,
  });

  /// Mobile / Joystick input (normalized -1 to 1)
  void setMovementInput(Offset input) {
    if (input.distance > 1.0) {
      moveInput = input / input.distance;
    } else {
      moveInput = input;
    }
  }

  void triggerJump() {
    if (isGrounded) {
      isJumpRequested = true;
    }
  }

  void setSprint(bool sprint) {
    isSprintRequested = sprint;
    if (sprint) {
      isCrouching = false; // Sprinting breaks crouch
    }
  }

  void toggleCrouch() {
    isCrouching = !isCrouching;
  }

  void setCrouch(bool crouch) {
    isCrouching = crouch;
  }

  /// Main physics and movement tick.
  void update(double dt) {
    // 1. Calculate horizontal movement speed
    final inputMagnitude = moveInput.distance;
    double targetSpeed = 0.0;

    if (inputMagnitude > 0.05) {
      if (isCrouching) {
        targetSpeed = sneakSpeed;
        state = MovementState.crouching;
      } else if (isSprintRequested) {
        targetSpeed = sprintSpeed;
        state = MovementState.sprinting;
      } else if (inputMagnitude > 0.7) {
        targetSpeed = runSpeed;
        state = MovementState.running;
      } else {
        targetSpeed = walkSpeed;
        state = MovementState.walking;
      }
    } else {
      targetSpeed = 0.0;
      if (!isGrounded) {
        state = MovementState.jumping;
      } else if (isCrouching) {
        state = MovementState.crouching;
      } else {
        state = MovementState.idle;
      }
    }

    // Smooth acceleration / deceleration
    final accelRate = (targetSpeed > currentSpeed) ? 14.0 : 18.0;
    currentSpeed += (targetSpeed - currentSpeed) * math.min(1.0, accelRate * dt);

    // 2. Camera-relative movement translation
    // In camera space:
    // Forward direction from camera to target on XZ plane:
    final double camForwardX = -math.sin(camera.yaw);
    final double camForwardZ = -math.cos(camera.yaw);

    // Right vector (perpendicular to forward):
    final double camRightX = -camForwardZ;
    final double camRightZ = camForwardX;

    // Projected movement vector
    double moveX = 0.0;
    double moveZ = 0.0;

    if (inputMagnitude > 0.05) {
      // moveInput.dx is horizontal (left/right), moveInput.dy is forward/backward
      final double normalizedDx = moveInput.dx / (inputMagnitude > 1.0 ? inputMagnitude : 1.0);
      final double normalizedDy = moveInput.dy / (inputMagnitude > 1.0 ? inputMagnitude : 1.0);

      // Forward is positive dy, right is positive dx
      moveX = (camRightX * normalizedDx) + (camForwardX * normalizedDy);
      moveZ = (camRightZ * normalizedDx) + (camForwardZ * normalizedDy);

      // Normalize movement direction
      final moveLength = math.sqrt((moveX * moveX) + (moveZ * moveZ));
      if (moveLength > 0.001) {
        moveX /= moveLength;
        moveZ /= moveLength;
      }

      // Turn Aadi to face moving direction
      player.targetRotationY = math.atan2(moveX, moveZ);
    }

    // 3. Jump and Gravity
    if (isJumpRequested && isGrounded) {
      verticalVelocity = jumpForce;
      isGrounded = false;
      isJumpRequested = false;
      state = MovementState.jumping;
    }

    if (!isGrounded) {
      verticalVelocity -= gravity * dt;
      state = MovementState.jumping;
    }

    // 4. Update Position with delta velocity
    double newX = player.position.x + (moveX * currentSpeed * dt);
    double newY = player.position.y + (verticalVelocity * dt);
    double newZ = player.position.z + (moveZ * currentSpeed * dt);

    // 5. Ground collision check
    const double groundLevel = 0.0;
    if (newY <= groundLevel) {
      newY = groundLevel;
      verticalVelocity = 0.0;
      isGrounded = true;
    }

    // 6. World Object Collisions (Houses, Shops, Trees, Walls)
    if (worldManager != null) {
      final resolved = worldManager!.resolveCollisions(
        oldX: player.position.x,
        oldZ: player.position.z,
        newX: newX,
        newZ: newZ,
        radius: player.radius,
      );
      newX = resolved.x;
      newZ = resolved.y;
    }

    // 7. World boundary collision check
    newX = newX.clamp(worldBoundMinX + player.radius, worldBoundMaxX - player.radius);
    newZ = newZ.clamp(worldBoundMinZ + player.radius, worldBoundMaxZ - player.radius);

    player.setPosition(newX, newY, newZ);

    // 7. Update player rotation and procedural animation
    player.updateRotation(dt);
    player.updateAnimation(dt, currentSpeed, isGrounded);

    // 8. Dynamic camera zoom adjust
    camera.setSprintZoom(isSprintRequested && currentSpeed > runSpeed);
  }
}
