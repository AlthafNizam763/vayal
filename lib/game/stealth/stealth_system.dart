import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/enemy_ai.dart';
import 'hiding_spot.dart';

/// Discrete stealth posture of the player.
enum StealthState {
  hidden, // Inside an environmental hiding spot (almost invisible)
  sneaking, // Crouched with suppressed footsteps and reduced silhouette
  exposed, // Upright posture, full visibility and sound profile
  compromised, // Engaged in combat or fully detected by hostiles
}

/// Core Stealth & Infiltration engine managing acoustic footstep propagation,
/// field-of-view cone detection, environmental concealment volumes,
/// hostile suspicion accumulation meters, and silent takedown opportunities.
class StealthSystem {
  bool isCrouched = false;
  bool isConcealed = false;
  HidingSpot? currentHidingSpot;

  // Sound propagation radius in meters
  double currentNoiseRadius = 0.0;

  // Registered environmental concealment spots
  final List<HidingSpot> hidingSpots;

  // Enemy ID -> awareness ratio (0.0 unaware to 1.0 fully alerted)
  final Map<String, double> enemyAwareness = {};

  // Callbacks
  void Function(EnemyAI enemy)? onStealthTakedown;
  void Function(EnemyAI enemy)? onEnemySpottedPlayer;
  void Function(bool isConcealed)? onConcealmentChanged;

  StealthSystem({List<HidingSpot>? hidingSpots})
      : hidingSpots = hidingSpots ?? _defaultHidingSpots();

  static List<HidingSpot> _defaultHidingSpots() {
    return [
      HidingSpot(
        id: 'bushes_safehouse',
        name: 'Dense Bushes near Safehouse',
        type: HidingSpotType.bushes,
        position: three.Vector3(-18.0, 0, -5.0),
        radius: 2.2,
      ),
      HidingSpot(
        id: 'dumpster_alley',
        name: 'Alleyway Dumpster',
        type: HidingSpotType.dumpster,
        position: three.Vector3(-10.0, 0, 18.0),
        radius: 2.0,
      ),
      HidingSpot(
        id: 'crates_warehouse',
        name: 'Cargo Crates Shadow',
        type: HidingSpotType.crates,
        position: three.Vector3(20.0, 0, -16.0),
        radius: 2.5,
      ),
      HidingSpot(
        id: 'dark_alcove_dock',
        name: 'Dark Alcove',
        type: HidingSpotType.darkAlcove,
        position: three.Vector3(12.0, 0, 8.0),
        radius: 2.2,
      ),
    ];
  }

  StealthState get currentStealthState {
    if (isConcealed) return StealthState.hidden;
    if (isCrouched) return StealthState.sneaking;
    return StealthState.exposed;
  }

  void setCrouched(bool crouched) {
    isCrouched = crouched;
  }

  void toggleCrouch() {
    isCrouched = !isCrouched;
  }

  /// Calculates dynamic sound propagation radius based on player movement and actions.
  void updateNoise({
    required double playerSpeed,
    required bool isShooting,
    required bool isMeleeAttacking,
  }) {
    if (isShooting) {
      currentNoiseRadius = 24.0; // Gunshots echo across 24m
    } else if (isMeleeAttacking) {
      currentNoiseRadius = 5.0; // Melee scuffle noise
    } else if (playerSpeed > 6.5) {
      currentNoiseRadius = 8.5; // Sprinting footsteps
    } else if (playerSpeed > 1.8) {
      currentNoiseRadius = isCrouched ? 1.4 : 4.2; // Sneak vs standard walk
    } else {
      currentNoiseRadius = 0.0; // Stationary
    }
  }

  /// Evaluates hiding spots, vision cones, acoustic hearing, and alert accumulation.
  void update({
    required double dt,
    required three.Vector3 playerPos,
    required double playerSpeed,
    required List<EnemyAI> activeEnemies,
    bool isShooting = false,
    bool isMeleeAttacking = false,
  }) {
    // 1. Check concealment in hiding spots
    final previousConcealed = isConcealed;
    isConcealed = false;
    currentHidingSpot = null;

    for (final spot in hidingSpots) {
      if (spot.containsPosition(playerPos)) {
        isConcealed = true;
        currentHidingSpot = spot;
        break;
      }
    }

    if (previousConcealed != isConcealed) {
      onConcealmentChanged?.call(isConcealed);
    }

    // 2. Compute acoustic noise radius
    updateNoise(
      playerSpeed: playerSpeed,
      isShooting: isShooting,
      isMeleeAttacking: isMeleeAttacking,
    );

    // 3. Process each hostile's awareness
    for (final enemy in activeEnemies) {
      if (enemy.isDead) {
        enemyAwareness.remove(enemy.id);
        continue;
      }

      final dx = playerPos.x - enemy.position.x;
      final dz = playerPos.z - enemy.position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      double currentAware = enemyAwareness[enemy.id] ?? 0.0;

      // Check hearing
      bool heardNoise = dist <= currentNoiseRadius && currentNoiseRadius > 0.5;

      // Check vision cone
      bool inVision = false;
      double effectiveVisionRange = isCrouched ? 6.5 : enemy.detectionRange;
      if (isConcealed) {
        effectiveVisionRange = 1.0; // Almost invisible in designated concealment
      }

      if (dist <= effectiveVisionRange) {
        // Forward vector of enemy
        final enemyForwardX = math.sin(enemy.rotationY);
        final enemyForwardZ = math.cos(enemy.rotationY);

        // Normalized vector from enemy towards player
        final toPlayerX = dx / (dist > 0.001 ? dist : 1.0);
        final toPlayerZ = dz / (dist > 0.001 ? dist : 1.0);

        final dot = toPlayerX * enemyForwardX + toPlayerZ * enemyForwardZ;
        // ~75 degree frontal vision cone
        if (dot > 0.65) {
          inVision = true;
        }
      }

      if (enemy.state == EnemyAIState.chase || enemy.state == EnemyAIState.windup) {
        // Already engaged in combat
        currentAware = 1.0;
      } else if (inVision) {
        // Accumulate awareness: accelerates as player nears center
        final speedFactor = (1.0 - (dist / effectiveVisionRange)).clamp(0.2, 1.0);
        currentAware = (currentAware + (1.2 * speedFactor * dt)).clamp(0.0, 1.0);

        if (currentAware >= 1.0) {
          enemy.isAlerted = true;
          enemy.state = EnemyAIState.chase;
          onEnemySpottedPlayer?.call(enemy);
        } else if (currentAware >= 0.35 && enemy.state == EnemyAIState.idle) {
          enemy.state = EnemyAIState.suspicious;
        }
      } else if (heardNoise) {
        // Heard loud footsteps or gun discharge
        currentAware = (currentAware + (2.0 * dt)).clamp(0.0, 1.0);
        enemy.state = EnemyAIState.suspicious;
        enemy.rotationY = math.atan2(dx, dz); // Pivot towards sound
        if (currentAware >= 1.0) {
          enemy.isAlerted = true;
          enemy.state = EnemyAIState.chase;
          onEnemySpottedPlayer?.call(enemy);
        }
      } else {
        // Decay awareness smoothly when breaking line-of-sight
        currentAware = (currentAware - (0.4 * dt)).clamp(0.0, 1.0);
        if (currentAware <= 0.05 && enemy.state == EnemyAIState.suspicious) {
          enemy.state = EnemyAIState.patrol;
        }
      }

      enemyAwareness[enemy.id] = currentAware;
    }
  }

  /// Determines if the player is positioned behind an unsuspecting hostile
  /// within silent takedown reach (<= 2.0m).
  EnemyAI? findTakedownCandidate({
    required three.Vector3 playerPos,
    required List<EnemyAI> activeEnemies,
    double maxDistance = 2.0,
  }) {
    for (final enemy in activeEnemies) {
      if (enemy.isDead) continue;
      // Cannot takedown an enemy who is already in active combat chase or attacking
      if (enemy.state == EnemyAIState.chase || enemy.state == EnemyAIState.windup) {
        continue;
      }

      final dx = enemy.position.x - playerPos.x;
      final dz = enemy.position.z - playerPos.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist <= maxDistance) {
        // Angle check: player must be BEHIND enemy
        final enemyForwardX = math.sin(enemy.rotationY);
        final enemyForwardZ = math.cos(enemy.rotationY);

        // Vector from enemy to player
        final toPlayerX = -dx / (dist > 0.001 ? dist : 1.0);
        final toPlayerZ = -dz / (dist > 0.001 ? dist : 1.0);

        // Dot product with forward vector: if player is behind, dot is negative
        final dot = toPlayerX * enemyForwardX + toPlayerZ * enemyForwardZ;
        if (dot < -0.2) {
          return enemy;
        }
      }
    }
    return null;
  }

  /// Executes silent stealth elimination on an unsuspecting enemy without alerting others.
  bool executeTakedown(EnemyAI target) {
    if (target.isDead) return false;

    // Silent takedown: instant incapacitation
    target.health = 0.0;
    target.state = EnemyAIState.defeated;
    target.group.rotation.x = math.pi * 0.5;
    target.group.position.y = 0.15;

    enemyAwareness.remove(target.id);
    onStealthTakedown?.call(target);
    return true;
  }

  /// Peak awareness value among all nearby hostiles (0.0 to 1.0).
  double get highestAwareness {
    if (enemyAwareness.isEmpty) return 0.0;
    return enemyAwareness.values.fold(0.0, (max, val) => val > max ? val : max);
  }
}
