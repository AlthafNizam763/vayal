import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/enemy_ai.dart';
import '../player/player.dart';
import 'blend_spot.dart';
import 'disguise.dart';
import 'restricted_zone.dart';

/// Social Stealth & Disguise Controller.
/// Coordinates wardrobe selection, high-security trespassing perimeters,
/// crowd and workstation blending, and identity scrutiny meters.
class DisguiseManager {
  Disguise currentDisguise;
  final Set<DisguiseType> unlockedDisguises;
  final List<RestrictedZone> restrictedZones;
  final List<BlendSpot> blendSpots;

  // Runtime states
  bool isTrespassing = false;
  RestrictedZone? activeRestrictedZone;

  bool isBlending = false;
  BlendSpot? currentBlendSpot;

  double disguiseCompromise = 0.0; // 0.0 (pristine cover) to 1.0 (blown cover)
  bool isDisguiseBlown = false;

  // Callbacks
  void Function(Disguise disguise)? onDisguiseChanged;
  void Function(RestrictedZone zone)? onTrespassingStarted;
  void Function(RestrictedZone zone)? onTrespassingEnded;
  void Function(bool isBlending, BlendSpot? spot)? onBlendingChanged;
  void Function()? onDisguiseBlown;

  DisguiseManager({
    Disguise? initialDisguise,
    Set<DisguiseType>? initialUnlocked,
    List<RestrictedZone>? restrictedZones,
    List<BlendSpot>? blendSpots,
  })  : currentDisguise = initialDisguise ?? DisguiseDatabase.civilian,
        unlockedDisguises = initialUnlocked ?? {DisguiseType.civilianDefault},
        restrictedZones = restrictedZones ?? _defaultRestrictedZones(),
        blendSpots = blendSpots ?? _defaultBlendSpots();

  static List<RestrictedZone> _defaultRestrictedZones() {
    return [
      RestrictedZone(
        id: 'zone_warehouse_docks',
        name: 'Warehouse Cargo Basin',
        description: 'Restricted to Port Workers and Syndicate logistics crews.',
        center: three.Vector3(22.0, 0.0, -18.0),
        radius: 14.0,
        allowedDisguiseTypes: [
          DisguiseType.dockWorker,
          DisguiseType.syndicateEnforcer,
        ],
      ),
      RestrictedZone(
        id: 'zone_syndicate_hideout',
        name: 'Syndicate Alley Den',
        description: 'Enforcer checkpoint. Civilians shot on sight.',
        center: three.Vector3(-14.0, 0.0, 16.0),
        radius: 12.0,
        allowedDisguiseTypes: [DisguiseType.syndicateEnforcer],
      ),
      RestrictedZone(
        id: 'zone_police_station',
        name: 'Veyrapuram Police Outpost',
        description: 'Law enforcement compound. Restricted to authorized personnel.',
        center: three.Vector3(18.0, 0.0, 15.0),
        radius: 10.0,
        allowedDisguiseTypes: [DisguiseType.policeOfficer],
      ),
    ];
  }

  static List<BlendSpot> _defaultBlendSpots() {
    return [
      BlendSpot(
        id: 'blend_cargo_inspection',
        name: 'Cargo Manifest Desk',
        blendAction: 'Review Port Manifest',
        position: three.Vector3(20.0, 0.0, -14.0),
        radius: 2.2,
      ),
      BlendSpot(
        id: 'blend_tea_stall',
        name: 'Balan’s Chai Bench',
        blendAction: 'Sip Tea with Civilians',
        position: three.Vector3(-10.0, 0.0, 4.0),
        radius: 2.5,
      ),
      BlendSpot(
        id: 'blend_port_railing',
        name: 'Harbor Railing',
        blendAction: 'Gaze at Harbor Waves',
        position: three.Vector3(10.0, 0.0, 2.0),
        radius: 2.0,
      ),
    ];
  }

  /// Unlocks an acquired faction outfit in the wardrobe.
  void unlockDisguise(DisguiseType type) {
    unlockedDisguises.add(type);
  }

  /// Changes the active disguise, resets suspicion, and updates player 3D appearance.
  bool equipDisguise(DisguiseType type, Player player) {
    if (!unlockedDisguises.contains(type)) return false;

    currentDisguise = DisguiseDatabase.getByType(type);
    isDisguiseBlown = false;
    disguiseCompromise = 0.0;

    player.applyDisguiseVisuals(
      bodyColorHex: currentDisguise.bodyColorHex,
      accentColorHex: currentDisguise.accentColorHex,
    );

    onDisguiseChanged?.call(currentDisguise);
    return true;
  }

  /// Toggles intentional social blending at an environmental blend spot.
  bool toggleBlend() {
    if (currentBlendSpot == null) {
      isBlending = false;
      return false;
    }
    isBlending = !isBlending;
    onBlendingChanged?.call(isBlending, currentBlendSpot);
    return isBlending;
  }

  /// Tick update evaluating restricted perimeters, scrutiny, and social blending.
  void update({
    required double dt,
    required three.Vector3 playerPos,
    required double playerSpeed,
    required bool isArmed,
    required bool isCrouching,
    required List<EnemyAI> nearbyEnemies,
  }) {
    // 1. Evaluate Restricted Zones & Trespassing
    RestrictedZone? currentZone;
    for (final zone in restrictedZones) {
      if (zone.containsPosition(playerPos)) {
        currentZone = zone;
        break;
      }
    }

    if (currentZone != null) {
      activeRestrictedZone = currentZone;
      final authorized = currentZone.isAuthorized(currentDisguise) && !isDisguiseBlown;

      if (!authorized) {
        if (!isTrespassing) {
          isTrespassing = true;
          onTrespassingStarted?.call(currentZone);
        }
      } else {
        if (isTrespassing) {
          isTrespassing = false;
          onTrespassingEnded?.call(currentZone);
        }
      }
    } else {
      if (isTrespassing && activeRestrictedZone != null) {
        onTrespassingEnded?.call(activeRestrictedZone!);
      }
      isTrespassing = false;
      activeRestrictedZone = null;
    }

    // 2. Evaluate Blend Spots
    BlendSpot? nearbySpot;
    for (final spot in blendSpots) {
      if (spot.containsPosition(playerPos)) {
        nearbySpot = spot;
        break;
      }
    }

    currentBlendSpot = nearbySpot;
    if (currentBlendSpot != null && playerSpeed < 0.2) {
      // Auto-blend if stationary in spot
      if (!isBlending) {
        isBlending = true;
        onBlendingChanged?.call(true, currentBlendSpot);
      }
    } else if (playerSpeed >= 0.5 && isBlending) {
      // Moving breaks blending
      isBlending = false;
      onBlendingChanged?.call(false, null);
    }

    // 3. Evaluate Disguise Scrutiny & Compromise
    if (isBlending) {
      // Blending neutralizes suspicion smoothly
      disguiseCompromise = (disguiseCompromise - (0.4 * dt)).clamp(0.0, 1.0);
    } else {
      bool isBeingScrutinized = false;

      for (final enemy in nearbyEnemies) {
        if (enemy.isDead) continue;

        final dx = enemy.position.x - playerPos.x;
        final dz = enemy.position.z - playerPos.z;
        final dist = math.sqrt(dx * dx + dz * dz);

        if (dist <= 4.0) {
          // If trespassing in an unauthorized restricted zone, scrutiny accelerates
          if (isTrespassing) {
            isBeingScrutinized = true;
            disguiseCompromise = (disguiseCompromise + (0.8 * dt)).clamp(0.0, 1.0);
          } else {
            // Even if authorized, same-faction guards scrutinize unfamiliar faces if too close
            final isMatchingFaction = (enemy.archetype == EnemyArchetype.enforcer &&
                    currentDisguise.type == DisguiseType.syndicateEnforcer) ||
                (enemy.archetype == EnemyArchetype.thug &&
                    currentDisguise.type == DisguiseType.syndicateEnforcer);

            if (isMatchingFaction && dist <= 3.2) {
              isBeingScrutinized = true;
              double scrutinyRate = 0.3 * currentDisguise.suspicionMultiplier;

              // Conspicuous behavior raises scrutiny dramatically
              if (isArmed) scrutinyRate += 1.2;
              if (playerSpeed > 5.5) scrutinyRate += 0.7; // Sprinting
              if (isCrouching) scrutinyRate += 0.5; // Sneaking in plain sight

              disguiseCompromise = (disguiseCompromise + (scrutinyRate * dt)).clamp(0.0, 1.0);
            }
          }
        }
      }

      if (!isBeingScrutinized) {
        // Natural suspicion decay when clear of scrutiny
        disguiseCompromise = (disguiseCompromise - (0.25 * dt)).clamp(0.0, 1.0);
      }

      // Check compromise threshold
      if (disguiseCompromise >= 1.0 && !isDisguiseBlown) {
        isDisguiseBlown = true;
        onDisguiseBlown?.call();
        // Immediately alert nearby scrutinizing enemies
        for (final enemy in nearbyEnemies) {
          final dx = enemy.position.x - playerPos.x;
          final dz = enemy.position.z - playerPos.z;
          if (math.sqrt(dx * dx + dz * dz) <= 8.0) {
            enemy.isAlerted = true;
            enemy.state = EnemyAIState.chase;
          }
        }
      }
    }
  }
}
