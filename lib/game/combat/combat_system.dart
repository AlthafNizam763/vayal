import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'damage_system.dart';
import 'weapon.dart';
import 'weapon_database.dart';

/// Available combat actions.
enum CombatAction {
  idle,
  lightAttack,
  heavyAttack,
  weaponAttack,
  shooting,
  reloading,
  blocking,
  dodging,
  knockedDown,
}

/// Target entity in combat (dummy, thug, hostile NPC).
class CombatTarget implements Damageable {
  final String id;
  final String name;
  final three.Vector3 position;
  final double radius;

  @override
  double health;
  @override
  final double maxHealth;

  @override
  bool isKnockedDown = false;
  double _knockdownTimer = 0.0;

  @override
  bool isBlocking = false;

  /// Phase 37: Stagger reaction & hit flash
  bool isStaggered = false;
  double _staggerTimer = 0.0;
  double hitFlashTimer = 0.0;

  @override
  bool get isDead => health <= 0;

  void Function(DamageInfo info)? onDamageTaken;

  CombatTarget({
    required this.id,
    required this.name,
    required this.position,
    this.health = 100.0,
    this.maxHealth = 100.0,
    this.radius = 0.5,
  });

  @override
  void takeDamage(DamageInfo info) {
    if (isDead) return;

    double effectiveDamage = info.amount;
    if (isBlocking) {
      effectiveDamage *= 0.25; // 75% damage reduction when blocking
    }

    health = (health - effectiveDamage).clamp(0.0, maxHealth);

    // Hit flash and stagger reactions
    hitFlashTimer = 0.25;
    isStaggered = true;
    _staggerTimer = 0.45;

    if ((info.canKnockdown || effectiveDamage >= 32.0) && !isBlocking) {
      isKnockedDown = true;
      _knockdownTimer = 2.0; // 2 seconds knockdown recovery
    }

    onDamageTaken?.call(info);
  }

  void update(double dt) {
    if (hitFlashTimer > 0) {
      hitFlashTimer = math.max(0.0, hitFlashTimer - dt);
    }
    if (isStaggered) {
      _staggerTimer -= dt;
      if (_staggerTimer <= 0) {
        isStaggered = false;
      }
    }
    if (isKnockedDown) {
      _knockdownTimer -= dt;
      if (_knockdownTimer <= 0) {
        isKnockedDown = false;
      }
    }
  }
}

/// Core player combat controller handling melee strikes, heavy attacks,
/// weapon switching, ballistic firearms, aiming, reload mechanics,
/// blocking damage mitigation, dodge evasions, stamina endurance, and hit detection.
class CombatSystem {
  double playerHealth = 100.0;
  final double playerMaxHealth = 100.0;

  // Phase 37: Player Stamina & Endurance
  double playerStamina = 100.0;
  final double playerMaxStamina = 100.0;
  double staminaRegenRate = 22.0;
  double _staminaRegenDelayTimer = 0.0;
  bool isExhausted = false;
  bool isGuardBroken = false;
  double _guardBreakTimer = 0.0;

  // Action stamina costs
  static const double lightAttackStaminaCost = 12.0;
  static const double heavyAttackStaminaCost = 28.0;
  static const double weaponAttackStaminaCost = 16.0;
  static const double dodgeStaminaCost = 20.0;
  static const double blockHitStaminaCost = 15.0;

  CombatAction currentAction = CombatAction.idle;
  double actionTimer = 0.0;
  bool isInvulnerable = false;
  bool isPlayerKnockedDown = false;
  bool isAiming = false;

  // Phase 29: Weapon loadout slots and equipped weapon
  final List<Weapon> weaponSlots;
  int activeSlotIndex = 0;

  final List<CombatTarget> activeTargets = [];

  // Callbacks
  void Function(CombatTarget target, DamageInfo damage)? onHitLanded;
  void Function(DamageInfo damage)? onPlayerDamaged;
  void Function(Weapon weapon)? onWeaponFired;
  void Function(Weapon weapon)? onWeaponReloaded;
  void Function(Weapon weapon)? onWeaponSwitched;
  void Function()? onGuardBroken;

  CombatSystem({List<Weapon>? initialLoadout})
      : weaponSlots = initialLoadout ?? WeaponDatabase.defaultLoadout;

  Weapon get equippedWeapon => weaponSlots[activeSlotIndex];

  bool get isBlocking => currentAction == CombatAction.blocking;
  bool get isAttacking =>
      currentAction == CombatAction.lightAttack ||
      currentAction == CombatAction.heavyAttack ||
      currentAction == CombatAction.weaponAttack ||
      currentAction == CombatAction.shooting;
  bool get isReloading => currentAction == CombatAction.reloading;
  bool get canPerformAction =>
      currentAction == CombatAction.idle && !isPlayerKnockedDown && !isGuardBroken;

  /// Switches active weapon slot (0 to 3).
  bool equipSlot(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= weaponSlots.length) return false;
    if (activeSlotIndex == slotIndex) return true;

    // Interrupt reload if switching weapons
    if (currentAction == CombatAction.reloading) {
      currentAction = CombatAction.idle;
      actionTimer = 0.0;
    }

    activeSlotIndex = slotIndex;
    onWeaponSwitched?.call(equippedWeapon);
    return true;
  }

  /// Equips a new weapon into the current active slot.
  void equipWeapon(Weapon weapon) {
    weaponSlots[activeSlotIndex] = weapon;
    onWeaponSwitched?.call(weapon);
  }

  /// Toggles ADS aiming mode.
  void setAiming(bool aiming) {
    isAiming = aiming;
  }

  /// Initiates weapon reload for firearms.
  bool startReload() {
    if (!equippedWeapon.isFirearm || !equippedWeapon.needsReload) return false;
    if (isPlayerKnockedDown || isBlocking || isReloading) return false;

    currentAction = CombatAction.reloading;
    actionTimer = equippedWeapon.reloadDuration;
    return true;
  }

  /// Executes primary weapon attack (melee swing or firearm discharge).
  bool executeWeaponAttack({
    required three.Vector3 playerPosition,
    required double playerRotationY,
  }) {
    if (!canPerformAction) return false;

    final weapon = equippedWeapon;

    if (weapon.isFirearm) {
      // Firearm logic
      if (!weapon.canFire) {
        // Automatically attempt reload if magazine is empty
        startReload();
        return false;
      }

      currentAction = CombatAction.shooting;
      actionTimer = weapon.cooldown;
      weapon.fire();
      onWeaponFired?.call(weapon);

      _detectBallisticHits(
        attackerPos: playerPosition,
        facingAngleY: playerRotationY,
        range: weapon.range,
        damage: weapon.damage,
        accuracy: isAiming ? 0.96 : weapon.accuracy,
      );
      return true;
    } else {
      // Melee weapon logic
      if (playerStamina < weaponAttackStaminaCost || isExhausted) return false;
      playerStamina = (playerStamina - weaponAttackStaminaCost).clamp(0.0, playerMaxStamina);
      _staminaRegenDelayTimer = 1.0;
      if (playerStamina <= 0.0) isExhausted = true;

      currentAction = CombatAction.weaponAttack;
      actionTimer = weapon.cooldown;

      _detectMeleeHits(
        attackerPos: playerPosition,
        facingAngleY: playerRotationY,
        range: weapon.range,
        damage: weapon.damage,
        canKnockdown: weapon.canKnockdown,
      );
      return true;
    }
  }

  /// Executes quick light punch combo.
  bool executeLightAttack({
    required three.Vector3 playerPosition,
    required double playerRotationY,
  }) {
    if (!canPerformAction) return false;
    if (playerStamina < lightAttackStaminaCost || isExhausted) return false;

    playerStamina = (playerStamina - lightAttackStaminaCost).clamp(0.0, playerMaxStamina);
    _staminaRegenDelayTimer = 0.9;
    if (playerStamina <= 0.0) isExhausted = true;

    currentAction = CombatAction.lightAttack;
    actionTimer = 0.32; // Quick jab duration

    _detectMeleeHits(
      attackerPos: playerPosition,
      facingAngleY: playerRotationY,
      range: 1.9,
      damage: 18.0,
      canKnockdown: false,
    );
    return true;
  }

  /// Executes powerful heavy strike with knockdown force.
  bool executeHeavyAttack({
    required three.Vector3 playerPosition,
    required double playerRotationY,
  }) {
    if (!canPerformAction) return false;
    if (playerStamina < heavyAttackStaminaCost || isExhausted) return false;

    playerStamina = (playerStamina - heavyAttackStaminaCost).clamp(0.0, playerMaxStamina);
    _staminaRegenDelayTimer = 1.4;
    if (playerStamina <= 0.0) isExhausted = true;

    currentAction = CombatAction.heavyAttack;
    actionTimer = 0.65; // Heavy strike windup & impact duration

    _detectMeleeHits(
      attackerPos: playerPosition,
      facingAngleY: playerRotationY,
      range: 2.3,
      damage: 38.0,
      canKnockdown: true,
    );
    return true;
  }

  /// Toggles defensive guard stance.
  void setBlocking(bool blocking) {
    if (isPlayerKnockedDown || isGuardBroken) return;
    if (blocking) {
      if (currentAction == CombatAction.idle) {
        currentAction = CombatAction.blocking;
      }
    } else {
      if (currentAction == CombatAction.blocking) {
        currentAction = CombatAction.idle;
      }
    }
  }

  /// Executes quick evasive dodge dash with invulnerability frames.
  bool executeDodge() {
    if (!canPerformAction) return false;
    if (playerStamina < dodgeStaminaCost || isExhausted) return false;

    playerStamina = (playerStamina - dodgeStaminaCost).clamp(0.0, playerMaxStamina);
    _staminaRegenDelayTimer = 1.1;
    if (playerStamina <= 0.0) isExhausted = true;

    currentAction = CombatAction.dodging;
    actionTimer = 0.35;
    isInvulnerable = true;
    return true;
  }

  /// Restores player health by specified amount up to max health.
  void healPlayer(double amount) {
    if (amount <= 0 || playerHealth <= 0) return;
    playerHealth = (playerHealth + amount).clamp(0.0, playerMaxHealth);
  }

  /// Restores player stamina by specified amount up to max stamina.
  void restoreStamina(double amount) {
    if (amount <= 0) return;
    playerStamina = (playerStamina + amount).clamp(0.0, playerMaxStamina);
    if (isExhausted && playerStamina >= 25.0) {
      isExhausted = false;
    }
  }

  /// Inflicts damage on the player with guard-break calculations.
  void damagePlayer(DamageInfo info) {
    if (isInvulnerable || playerHealth <= 0) return;

    double actualDamage = info.amount;
    if (isBlocking) {
      actualDamage *= 0.25; // Block mitigates 75% of incoming damage
      // Blocking drains stamina
      playerStamina -= blockHitStaminaCost;
      _staminaRegenDelayTimer = 1.2;

      if (playerStamina <= 0.0) {
        // Guard Break!
        playerStamina = 0.0;
        isExhausted = true;
        isGuardBroken = true;
        _guardBreakTimer = 1.6;
        isPlayerKnockedDown = true;
        currentAction = CombatAction.knockedDown;
        actionTimer = 1.6;
        onGuardBroken?.call();
      }
    }

    playerHealth = (playerHealth - actualDamage).clamp(0.0, playerMaxHealth);

    if (info.canKnockdown && !isBlocking) {
      isPlayerKnockedDown = true;
      currentAction = CombatAction.knockedDown;
      actionTimer = 2.0;
    }

    onPlayerDamaged?.call(info);
  }

  /// Scans for targets in a forward melee reach cone.
  void _detectMeleeHits({
    required three.Vector3 attackerPos,
    required double facingAngleY,
    required double range,
    required double damage,
    required bool canKnockdown,
  }) {
    final forwardX = math.sin(facingAngleY);
    final forwardZ = math.cos(facingAngleY);

    for (final target in activeTargets) {
      if (target.isDead) continue;

      final toTargetX = target.position.x - attackerPos.x;
      final toTargetZ = target.position.z - attackerPos.z;
      final dist = math.sqrt(toTargetX * toTargetX + toTargetZ * toTargetZ);

      if (dist <= range + target.radius) {
        // Angle check: within ~100 degree frontal arc
        final dot = (toTargetX * forwardX + toTargetZ * forwardZ) / (dist > 0.01 ? dist : 1.0);
        if (dot > 0.15) {
          final dmgInfo = DamageInfo(
            amount: damage,
            type: DamageType.melee,
            attackerId: 'aadi',
            canKnockdown: canKnockdown,
          );
          target.takeDamage(dmgInfo);
          onHitLanded?.call(target, dmgInfo);
        }
      }
    }
  }

  /// Scans for targets along a long-range ballistic line with weapon spread.
  void _detectBallisticHits({
    required three.Vector3 attackerPos,
    required double facingAngleY,
    required double range,
    required double damage,
    required double accuracy,
  }) {
    final forwardX = math.sin(facingAngleY);
    final forwardZ = math.cos(facingAngleY);

    // Minimum alignment dot threshold based on accuracy (0.85 = ~30 deg cone, 0.96 = ~15 deg cone)
    final minDotThreshold = 0.65 + (accuracy * 0.3);

    CombatTarget? closestTarget;
    double closestDistance = range;

    for (final target in activeTargets) {
      if (target.isDead) continue;

      final toTargetX = target.position.x - attackerPos.x;
      final toTargetZ = target.position.z - attackerPos.z;
      final dist = math.sqrt(toTargetX * toTargetX + toTargetZ * toTargetZ);

      if (dist <= range) {
        final dot = (toTargetX * forwardX + toTargetZ * forwardZ) / (dist > 0.01 ? dist : 1.0);
        if (dot >= minDotThreshold && dist < closestDistance) {
          closestDistance = dist;
          closestTarget = target;
        }
      }
    }

    if (closestTarget != null) {
      final dmgInfo = DamageInfo(
        amount: damage,
        type: DamageType.gunshot,
        attackerId: 'aadi',
        canKnockdown: true,
      );
      closestTarget.takeDamage(dmgInfo);
      onHitLanded?.call(closestTarget, dmgInfo);
    }
  }

  void update(double dt) {
    // Update active targets
    for (final target in activeTargets) {
      target.update(dt);
    }

    // Phase 37: Guard break recovery
    if (_guardBreakTimer > 0) {
      _guardBreakTimer -= dt;
      if (_guardBreakTimer <= 0) {
        isGuardBroken = false;
      }
    }

    // Phase 37: Stamina regeneration logic
    if (_staminaRegenDelayTimer > 0) {
      _staminaRegenDelayTimer -= dt;
    } else if (!isBlocking && !isPlayerKnockedDown && !isGuardBroken) {
      if (playerStamina < playerMaxStamina) {
        playerStamina = (playerStamina + staminaRegenRate * dt).clamp(0.0, playerMaxStamina);
      }
      if (isExhausted && playerStamina >= 25.0) {
        isExhausted = false;
      }
    }

    if (actionTimer > 0) {
      actionTimer -= dt;
      if (actionTimer <= 0) {
        if (currentAction == CombatAction.reloading) {
          equippedWeapon.reload();
          onWeaponReloaded?.call(equippedWeapon);
        }
        if (currentAction == CombatAction.dodging) {
          isInvulnerable = false;
        }
        if (currentAction == CombatAction.knockedDown) {
          isPlayerKnockedDown = false;
        }
        currentAction = CombatAction.idle;
      }
    }
  }
}
