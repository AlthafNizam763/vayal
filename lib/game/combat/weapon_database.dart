import 'package:flutter/material.dart';
import '../audio/audio_event.dart';
import 'weapon.dart';

/// Predefined weapons database featuring authentic Kerala crime-thriller arsenal.
class WeaponDatabase {
  // 1. Unarmed - Bare Knuckles
  static Weapon get bareKnuckles => Weapon(
    id: 'weapon_unarmed',
    name: 'Bare Knuckles',
    type: WeaponType.unarmed,
    damage: 18.0,
    range: 1.9,
    cooldown: 0.32,
    canKnockdown: false,
    soundEvent: AudioEvent.combatPunchLight,
    hudIcon: Icons.sports_mma_rounded,
  );

  // 2. Utility Knife
  static Weapon get utilityKnife => Weapon(
    id: 'weapon_knife',
    name: 'Folding Utility Knife',
    type: WeaponType.knife,
    damage: 28.0,
    range: 1.8,
    cooldown: 0.24,
    canKnockdown: false,
    soundEvent: AudioEvent.combatPunchLight,
    hudIcon: Icons.colorize_rounded,
  );

  // 3. Heavy Iron Rod / Crowbar
  static Weapon get ironRod => Weapon(
    id: 'weapon_iron_rod',
    name: 'Heavy Iron Rod',
    type: WeaponType.blunt,
    damage: 44.0,
    range: 2.4,
    cooldown: 0.55,
    canKnockdown: true,
    soundEvent: AudioEvent.combatBluntSwing,
    hudIcon: Icons.hardware_rounded,
  );

  // 4. Country Machete (Vettukathi)
  static Weapon get vettukathi => Weapon(
    id: 'weapon_vettukathi',
    name: 'Country Machete (Vettukathi)',
    type: WeaponType.machete,
    damage: 55.0,
    range: 2.5,
    cooldown: 0.48,
    canKnockdown: true,
    soundEvent: AudioEvent.combatMacheteSlash,
    hudIcon: Icons.content_cut_rounded,
  );

  // 5. Country Pistol (Desi Katta) - Crude single-shot firearm
  static Weapon get countryPistol => Weapon(
    id: 'weapon_country_pistol',
    name: 'Country Pistol (Desi Katta)',
    type: WeaponType.pistol,
    damage: 65.0,
    range: 35.0,
    cooldown: 0.75,
    canKnockdown: true,
    isFirearm: true,
    magazineCapacity: 1,
    currentAmmo: 1,
    reserveAmmo: 12,
    maxReserveAmmo: 30,
    reloadDuration: 1.8,
    accuracy: 0.72,
    soundEvent: AudioEvent.combatGunshot,
    hudIcon: Icons.gps_fixed_rounded,
  );

  // 6. Service Revolver (.38 Special)
  static Weapon get revolver => Weapon(
    id: 'weapon_revolver',
    name: 'Webley .38 Revolver',
    type: WeaponType.revolver,
    damage: 48.0,
    range: 45.0,
    cooldown: 0.38,
    canKnockdown: true,
    isFirearm: true,
    magazineCapacity: 6,
    currentAmmo: 6,
    reserveAmmo: 24,
    maxReserveAmmo: 60,
    reloadDuration: 2.2,
    accuracy: 0.88,
    soundEvent: AudioEvent.combatGunshot,
    hudIcon: Icons.adjust_rounded,
  );

  static List<Weapon> get defaultLoadout => [
    bareKnuckles,
    vettukathi,
    ironRod,
    revolver,
  ];
}
