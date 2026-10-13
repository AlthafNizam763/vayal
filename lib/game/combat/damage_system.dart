import 'package:three_js/three_js.dart' as three;

/// Categories of damage inflicted during combat and collisions.
enum DamageType {
  melee,
  blunt,
  gunshot,
  vehicleImpact,
}

/// Information packet describing an attack or impact.
class DamageInfo {
  final double amount;
  final DamageType type;
  final three.Vector3? impactPoint;
  final String? attackerId;
  final bool canKnockdown;

  const DamageInfo({
    required this.amount,
    this.type = DamageType.melee,
    this.impactPoint,
    this.attackerId,
    this.canKnockdown = false,
  });
}

/// Interface for any entity (Player, NPC, Vehicle) that can take damage.
abstract class Damageable {
  double get health;
  double get maxHealth;
  bool get isDead;
  bool get isBlocking => false;
  bool get isKnockedDown => false;

  void takeDamage(DamageInfo info);
}
