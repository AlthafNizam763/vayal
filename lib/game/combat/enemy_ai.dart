import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'damage_system.dart';
import 'combat_system.dart';
import '../characters/humanoid_builder.dart';

/// Archetypes defining tactical behavior and combat role.
enum EnemyArchetype {
  thug, // Aggressive melee brawler, swarms player
  hitman, // Ranged firearm marksman, maintains distance
  enforcer, // Heavily armored brute, blocks and inflicts heavy knockdowns
  boss, // Syndicate boss with multi-phase mechanics and lethal arsenal
}

/// Dynamic behavioral state of the AI agent.
enum EnemyAIState {
  idle,
  patrol,
  suspicious,
  chase,
  windup,
  recovering,
  blocking,
  staggered,
  knockedDown,
  defeated,
}

/// Advanced 3D Enemy AI controller that extends [CombatTarget].
/// Handles 3D procedural mesh articulation, field-of-view detection,
/// pathing, tactical maneuvering (flanking, backpedaling), attack windups,
/// defensive blocking, and direct damage infliction onto the player.
class EnemyAI extends CombatTarget {
  final EnemyArchetype archetype;

  EnemyAIState state = EnemyAIState.idle;
  double stateTimer = 0.0;
  double attackCooldownTimer = 0.0;
  double blockDurationTimer = 0.0;

  // Movement & orientation
  double moveSpeed;
  double rotationY = 0.0;
  final List<three.Vector3> patrolWaypoints;
  int currentWaypointIndex = 0;

  // Combat parameters
  final double detectionRange;
  final double attackRange;
  final double minFleeRange;
  final double attackDamage;
  final double attackWindupDuration;
  final double attackCooldownDuration;
  final double blockChance;

  // 3D Procedural Mesh
  late final three.Group group;
  late final three.Mesh bodyMesh;
  late final three.Mesh headMesh;
  late final three.Mesh leftArm;
  late final three.Mesh rightArm;
  late final three.Mesh leftLeg;
  late final three.Mesh rightLeg;
  three.Mesh? weaponMesh;

  // Animation cycle
  double _animTime = 0.0;
  bool isAlerted = false;

  // Callbacks
  void Function(EnemyAI enemy)? onDefeated;
  void Function(EnemyAI enemy, String action)? onCombatAction;

  EnemyAI({
    required super.id,
    required super.name,
    required super.position,
    required this.archetype,
    super.health = 100.0,
    super.maxHealth = 100.0,
    this.moveSpeed = 2.8,
    this.detectionRange = 14.0,
    this.attackRange = 1.6,
    this.minFleeRange = 4.0,
    this.attackDamage = 15.0,
    this.attackWindupDuration = 0.45,
    this.attackCooldownDuration = 1.4,
    this.blockChance = 0.25,
    List<three.Vector3>? patrolWaypoints,
  })  : patrolWaypoints = patrolWaypoints ?? [],
        super(radius: 0.5) {
    _initArchetypeStats();
    _buildMesh();
  }

  /// Adjusts parameters based on the chosen archetype.
  void _initArchetypeStats() {
    switch (archetype) {
      case EnemyArchetype.thug:
        moveSpeed = 3.2;
        break;
      case EnemyArchetype.hitman:
        moveSpeed = 2.6;
        break;
      case EnemyArchetype.enforcer:
        moveSpeed = 1.9;
        break;
      case EnemyArchetype.boss:
        moveSpeed = 2.7;
        break;
    }
  }

  /// Constructs distinctive procedural 3D humanoid with archetype-specific
  /// palette, build and hairstyle.
  void _buildMesh() {
    group = three.Group();

    // Archetype color coding
    int bodyColorHex = 0x3a4b3d; // Thug: olive drab
    int accentColorHex = 0x1f2721;
    int hairColorHex = 0x17120c;
    int skinColorHex = 0xa8856b;
    double shoulderHalfWidth = 0.30;
    double bulk = 1.0;
    HumanoidHairStyle hairStyle = HumanoidHairStyle.bearded;

    if (archetype == EnemyArchetype.hitman) {
      bodyColorHex = 0x1e242d; // Dark charcoal trench coat
      accentColorHex = 0x5a2d2d; // Crimson tie
      shoulderHalfWidth = 0.28;
      hairStyle = HumanoidHairStyle.short; // Clean professional cut
    } else if (archetype == EnemyArchetype.enforcer) {
      bodyColorHex = 0x6e2121; // Bouncer crimson vest
      accentColorHex = 0x221111;
      shoulderHalfWidth = 0.36;
      bulk = 1.35; // Heavyset build
    } else if (archetype == EnemyArchetype.boss) {
      bodyColorHex = 0x4a0a16; // Syndicate Boss royal maroon
      accentColorHex = 0xd4af37; // Gold embroidered trim
      shoulderHalfWidth = 0.33;
      bulk = 1.25;
    }

    final rig = buildHumanoid(
      group,
      HumanoidPalette(
        torsoHex: bodyColorHex,
        pantsHex: accentColorHex,
        sleeveHex: bodyColorHex,
        skinHex: skinColorHex,
        hairHex: hairColorHex,
        accentHex: accentColorHex,
        hairStyle: hairStyle,
      ),
      torsoY: 1.15,
      headY: 1.76,
      shoulderY: 1.41,
      hipY: 0.78,
      shoulderHalfWidth: shoulderHalfWidth,
      hipHalfWidth: 0.175 * (0.8 + bulk * 0.2),
      bulk: bulk,
    );

    bodyMesh = rig.bodyMesh;
    headMesh = rig.headMesh;
    leftArm = rig.leftArm;
    rightArm = rig.rightArm;
    leftLeg = rig.leftLeg;
    rightLeg = rig.rightLeg;

    // Weapon representation
    if (archetype == EnemyArchetype.hitman || archetype == EnemyArchetype.boss) {
      final gunMat = three.MeshStandardMaterial();
      gunMat.color = three.Color.fromHex32(0x111111);
      gunMat.roughness = 0.3;
      gunMat.metalness = 0.4;
      weaponMesh = three.Mesh(three.BoxGeometry(0.1, 0.12, 0.35), gunMat);
      weaponMesh!.position.setValues(0.01, -0.62, 0.2);
      rightArm.add(weaponMesh!);
    } else if (archetype == EnemyArchetype.enforcer) {
      final rodMat = three.MeshStandardMaterial();
      rodMat.color = three.Color.fromHex32(0x777777);
      rodMat.metalness = 0.8;
      rodMat.roughness = 0.3;
      weaponMesh = three.Mesh(three.CylinderGeometry(0.04, 0.04, 0.8, 8), rodMat);
      weaponMesh!.position.setValues(0.01, -0.62, 0.15);
      rightArm.add(weaponMesh!);
    }

    _syncMesh();
  }

  @override
  void takeDamage(DamageInfo info) {
    if (isDead) return;

    super.takeDamage(info);
    isAlerted = true;

    // React to attack: transition to chase or block
    if (isDead) {
      state = EnemyAIState.defeated;
      _onDefeatedAnimation();
      onDefeated?.call(this);
      return;
    }

    if (isKnockedDown) {
      state = EnemyAIState.knockedDown;
      return;
    }

    // Heavy damage or gunshot can cause brief stagger
    if (info.amount >= 25.0 || info.type == DamageType.gunshot) {
      state = EnemyAIState.staggered;
      stateTimer = 0.4;
      return;
    }

    // Defensive counter-block possibility
    if (state != EnemyAIState.windup && math.Random().nextDouble() < blockChance) {
      state = EnemyAIState.blocking;
      isBlocking = true;
      blockDurationTimer = 1.0;
      return;
    }

    if (state != EnemyAIState.chase && state != EnemyAIState.windup) {
      state = EnemyAIState.chase;
    }
  }

  /// Core AI tick executed each frame.
  void updateAI({
    required double dt,
    required three.Vector3 playerPos,
    required CombatSystem combatSystem,
  }) {
    super.update(dt);

    if (isDead) {
      state = EnemyAIState.defeated;
      _syncMesh();
      return;
    }

    // Cooldown decay
    if (attackCooldownTimer > 0) {
      attackCooldownTimer -= dt;
    }

    // Target tracking distance and vector
    final dx = playerPos.x - position.x;
    final dz = playerPos.z - position.z;
    final distToPlayer = math.sqrt(dx * dx + dz * dz);

    // State machine evaluation
    switch (state) {
      case EnemyAIState.idle:
      case EnemyAIState.patrol:
        _updatePatrolOrIdle(dt, distToPlayer);
        if (state == EnemyAIState.chase) {
          _updateCombatChase(dt, distToPlayer, dx, dz, combatSystem);
        }
        break;

      case EnemyAIState.suspicious:
        _updateSuspicious(dt, distToPlayer, dx, dz);
        break;

      case EnemyAIState.chase:
        _updateCombatChase(dt, distToPlayer, dx, dz, combatSystem);
        break;

      case EnemyAIState.windup:
        _updateAttackWindup(dt, distToPlayer, dx, dz, combatSystem);
        break;

      case EnemyAIState.recovering:
        _updateAttackRecovery(dt, distToPlayer, dx, dz);
        break;

      case EnemyAIState.blocking:
        _updateBlocking(dt, distToPlayer, dx, dz);
        break;

      case EnemyAIState.staggered:
        stateTimer -= dt;
        if (stateTimer <= 0) {
          state = EnemyAIState.chase;
        }
        break;

      case EnemyAIState.knockedDown:
        if (!isKnockedDown) {
          state = EnemyAIState.chase;
        }
        break;

      case EnemyAIState.defeated:
        break;
    }

    _animateLimbs(dt);
    _syncMesh();
  }

  void _updatePatrolOrIdle(double dt, double distToPlayer) {
    // Player detection cone/distance
    if (isAlerted || distToPlayer <= detectionRange) {
      state = EnemyAIState.chase;
      isAlerted = true;
      return;
    }

    if (patrolWaypoints.isNotEmpty) {
      final wp = patrolWaypoints[currentWaypointIndex];
      final toWpX = wp.x - position.x;
      final toWpZ = wp.z - position.z;
      final distWp = math.sqrt(toWpX * toWpX + toWpZ * toWpZ);

      if (distWp < 0.8) {
        currentWaypointIndex = (currentWaypointIndex + 1) % patrolWaypoints.length;
      } else {
        rotationY = math.atan2(toWpX, toWpZ);
        final step = (moveSpeed * 0.5) * dt;
        position.x += (toWpX / distWp) * step;
        position.z += (toWpZ / distWp) * step;
        _animTime += dt * 5.0;
      }
    }
  }

  void _updateSuspicious(double dt, double distToPlayer, double dx, double dz) {
    rotationY = math.atan2(dx, dz);
    stateTimer -= dt;
    if (distToPlayer <= detectionRange || isAlerted) {
      state = EnemyAIState.chase;
    } else if (stateTimer <= 0) {
      state = EnemyAIState.patrol;
    }
  }

  void _updateCombatChase(
    double dt,
    double distToPlayer,
    double dx,
    double dz,
    CombatSystem combatSystem,
  ) {
    // Always face player when engaged
    rotationY = math.atan2(dx, dz);

    if (archetype == EnemyArchetype.hitman) {
      // Hitman tactical repositioning: maintain sweet spot between minFleeRange and attackRange
      if (distToPlayer < minFleeRange) {
        // Back away / retreat
        final fleeX = -dx / distToPlayer;
        final fleeZ = -dz / distToPlayer;
        position.x += fleeX * moveSpeed * dt;
        position.z += fleeZ * moveSpeed * dt;
        _animTime += dt * 6.0;
      } else if (distToPlayer > attackRange) {
        // Move closer
        final step = moveSpeed * dt;
        position.x += (dx / distToPlayer) * step;
        position.z += (dz / distToPlayer) * step;
        _animTime += dt * 6.0;
      } else {
        // In shooting pocket
        if (attackCooldownTimer <= 0) {
          state = EnemyAIState.windup;
          stateTimer = attackWindupDuration;
          onCombatAction?.call(this, 'aiming');
        }
      }
    } else {
      // Melee (Thug, Enforcer, Boss) closes distance directly
      if (distToPlayer > attackRange) {
        final step = moveSpeed * dt;
        position.x += (dx / distToPlayer) * step;
        position.z += (dz / distToPlayer) * step;
        _animTime += dt * 7.0;
      } else {
        // Within striking reach
        if (attackCooldownTimer <= 0) {
          state = EnemyAIState.windup;
          stateTimer = attackWindupDuration;
          onCombatAction?.call(this, 'winding_up');
        }
      }
    }
  }

  void _updateAttackWindup(
    double dt,
    double distToPlayer,
    double dx,
    double dz,
    CombatSystem combatSystem,
  ) {
    rotationY = math.atan2(dx, dz);
    stateTimer -= dt;

    // Windup arm raised telegraph
    rightArm.rotation.x = -1.2;

    if (stateTimer <= 0) {
      _executeAttack(distToPlayer, combatSystem);
      state = EnemyAIState.recovering;
      stateTimer = 0.3; // brief recovery pause
      attackCooldownTimer = attackCooldownDuration;
    }
  }

  void _executeAttack(double distToPlayer, CombatSystem combatSystem) {
    final bool isRanged = archetype == EnemyArchetype.hitman ||
        (archetype == EnemyArchetype.boss && attackRange > 4.0);

    // Range check before landing hit
    if (isRanged) {
      // Ballistic shot: line of sight check
      if (distToPlayer <= attackRange + 2.0) {
        combatSystem.damagePlayer(DamageInfo(
          amount: attackDamage,
          type: DamageType.gunshot,
          attackerId: id,
          canKnockdown: archetype == EnemyArchetype.boss,
        ));
        onCombatAction?.call(this, 'fired_gun');
      }
    } else {
      // Melee strike: reach check
      if (distToPlayer <= attackRange + 0.6) {
        final canKnock = archetype == EnemyArchetype.enforcer ||
            archetype == EnemyArchetype.boss;
        combatSystem.damagePlayer(DamageInfo(
          amount: attackDamage,
          type: DamageType.melee,
          attackerId: id,
          canKnockdown: canKnock,
        ));
        onCombatAction?.call(this, 'melee_strike');
      }
    }
  }

  void _updateAttackRecovery(double dt, double distToPlayer, double dx, double dz) {
    rotationY = math.atan2(dx, dz);
    stateTimer -= dt;
    if (stateTimer <= 0) {
      state = EnemyAIState.chase;
    }
  }

  void _updateBlocking(double dt, double distToPlayer, double dx, double dz) {
    rotationY = math.atan2(dx, dz);
    blockDurationTimer -= dt;

    // Raise both arms in front for blocking guard
    leftArm.rotation.x = -1.4;
    rightArm.rotation.x = -1.4;

    if (blockDurationTimer <= 0) {
      isBlocking = false;
      state = EnemyAIState.chase;
    }
  }

  void _animateLimbs(double dt) {
    if (state == EnemyAIState.knockedDown || state == EnemyAIState.defeated) {
      return;
    }

    if (state == EnemyAIState.chase && _animTime > 0) {
      final swing = math.sin(_animTime) * 0.7;
      leftLeg.rotation.x = swing;
      rightLeg.rotation.x = -swing;
      if (state != EnemyAIState.windup && state != EnemyAIState.blocking) {
        leftArm.rotation.x = -swing * 0.6;
        rightArm.rotation.x = swing * 0.6;
      }
    } else if (state == EnemyAIState.idle || state == EnemyAIState.recovering) {
      leftLeg.rotation.x *= 0.8;
      rightLeg.rotation.x *= 0.8;
      if (state != EnemyAIState.windup && state != EnemyAIState.blocking) {
        leftArm.rotation.x *= 0.8;
        rightArm.rotation.x *= 0.8;
      }
    }
  }

  void _onDefeatedAnimation() {
    // Drop to floor flat
    group.rotation.x = math.pi * 0.5;
    group.position.y = 0.2;
  }

  void _syncMesh() {
    if (state != EnemyAIState.defeated) {
      group.position.setFrom(position);
      group.rotation.y = rotationY;
    }
  }
}
