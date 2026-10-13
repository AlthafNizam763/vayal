import 'package:flutter/material.dart';
import '../audio/audio_event.dart';

/// Categories of weapons available in VAYAL.
enum WeaponType {
  unarmed,
  knife,
  blunt,
  machete,
  pistol,
  revolver,
}

/// Model representing an equipped or inventory weapon (melee or firearm).
class Weapon {
  final String id;
  final String name;
  final WeaponType type;
  final double damage;
  final double range; // In meters (melee reach or firearm effective range)
  final double cooldown; // Attack cooldown in seconds
  final bool canKnockdown;
  final bool isFirearm;
  final int magazineCapacity;
  int currentAmmo;
  int reserveAmmo;
  final int maxReserveAmmo;
  final double reloadDuration;
  final double accuracy; // 0.0 to 1.0 (spread reduction)
  final AudioEvent soundEvent;
  final IconData hudIcon;

  Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.damage,
    required this.range,
    required this.cooldown,
    this.canKnockdown = false,
    this.isFirearm = false,
    this.magazineCapacity = 0,
    this.currentAmmo = 0,
    this.reserveAmmo = 0,
    this.maxReserveAmmo = 0,
    this.reloadDuration = 1.5,
    this.accuracy = 0.85,
    required this.soundEvent,
    required this.hudIcon,
  });

  bool get canFire {
    if (!isFirearm) return true;
    return currentAmmo > 0;
  }

  bool get needsReload {
    if (!isFirearm) return false;
    return currentAmmo < magazineCapacity && reserveAmmo > 0;
  }

  /// Consumes one round from the magazine if a firearm.
  bool fire() {
    if (!isFirearm) return true;
    if (currentAmmo > 0) {
      currentAmmo--;
      return true;
    }
    return false;
  }

  /// Reloads the firearm from reserves up to magazine capacity.
  int reload() {
    if (!isFirearm || reserveAmmo <= 0) return 0;
    final needed = magazineCapacity - currentAmmo;
    if (needed <= 0) return 0;

    final amountToLoad = reserveAmmo >= needed ? needed : reserveAmmo;
    currentAmmo += amountToLoad;
    reserveAmmo -= amountToLoad;
    return amountToLoad;
  }

  /// Adds ammunition to reserve pool.
  void addAmmo(int count) {
    if (!isFirearm) return;
    reserveAmmo = (reserveAmmo + count).clamp(0, maxReserveAmmo);
  }

  Weapon copyWith({
    int? currentAmmo,
    int? reserveAmmo,
  }) {
    return Weapon(
      id: id,
      name: name,
      type: type,
      damage: damage,
      range: range,
      cooldown: cooldown,
      canKnockdown: canKnockdown,
      isFirearm: isFirearm,
      magazineCapacity: magazineCapacity,
      currentAmmo: currentAmmo ?? this.currentAmmo,
      reserveAmmo: reserveAmmo ?? this.reserveAmmo,
      maxReserveAmmo: maxReserveAmmo,
      reloadDuration: reloadDuration,
      accuracy: accuracy,
      soundEvent: soundEvent,
      hudIcon: hudIcon,
    );
  }
}
