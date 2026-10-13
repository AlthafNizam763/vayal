import 'package:three_js/three_js.dart' as three;
import 'combat_system.dart';
import 'enemy_ai.dart';

/// Manages multi-phase Syndicate Boss encounters (e.g., Captain Velu or Karan).
/// Handles phase transitions, aggressive AI buffs, mid-fight dialogue cues,
/// reinforcement squad spawning, and victory resolution.
class BossEncounter {
  final EnemyAI boss;
  final String title;
  final String subtitle;

  int currentPhase = 1;
  bool hasTriggeredPhase2 = false;
  bool isDefeated = false;

  final List<EnemyAI> reinforcements = [];

  // Callbacks
  void Function(int phase, String dialoguePrompt)? onPhaseChanged;
  void Function(String bossTitle)? onBossDefeated;
  void Function(EnemyAI spawnedEnemy)? onReinforcementSpawned;

  BossEncounter({
    required this.boss,
    this.title = 'CAPTAIN VELU',
    this.subtitle = 'Syndicate Kingpin of Veyrapuram',
  });

  /// Factory constructor to initialize Captain Velu with boss-tier stats.
  factory BossEncounter.createCaptainVelu({
    required three.Vector3 spawnPosition,
  }) {
    final bossAI = EnemyAI(
      id: 'boss_velu',
      name: 'Captain Velu',
      position: spawnPosition,
      archetype: EnemyArchetype.boss,
      health: 300.0,
      maxHealth: 300.0,
      moveSpeed: 2.8,
      attackRange: 2.0, // Phase 1: Heavy melee
      attackDamage: 28.0,
      attackWindupDuration: 0.4,
      attackCooldownDuration: 1.2,
      blockChance: 0.35,
    );

    return BossEncounter(
      boss: bossAI,
      title: 'CAPTAIN VELU',
      subtitle: 'Syndicate Kingpin of Veyrapuram',
    );
  }

  /// Updates boss AI logic and evaluates phase transition triggers.
  void update({
    required double dt,
    required three.Vector3 playerPos,
    required CombatSystem combatSystem,
    required three.Scene scene,
  }) {
    if (isDefeated) return;

    // Boss state tick
    boss.updateAI(
      dt: dt,
      playerPos: playerPos,
      combatSystem: combatSystem,
    );

    // Phase 2 transition check at 50% health threshold
    if (!hasTriggeredPhase2 && boss.health <= (boss.maxHealth * 0.5)) {
      _triggerPhaseTwo(playerPos, combatSystem, scene);
    }

    // Check defeat
    if (boss.isDead && !isDefeated) {
      isDefeated = true;
      onBossDefeated?.call(title);
    }

    // Update active reinforcement squad
    for (int i = reinforcements.length - 1; i >= 0; i--) {
      final rf = reinforcements[i];
      rf.updateAI(
        dt: dt,
        playerPos: playerPos,
        combatSystem: combatSystem,
      );
    }
  }

  /// Executes Phase 2 cinematic escalation:
  /// Equips ranged firearm, buffs attack rate/speed, and summons backup thugs.
  void _triggerPhaseTwo(
    three.Vector3 playerPos,
    CombatSystem combatSystem,
    three.Scene scene,
  ) {
    hasTriggeredPhase2 = true;
    currentPhase = 2;

    // Buff Boss: faster movement, lethal firearm range, quicker strikes
    boss.moveSpeed = 3.3;

    // Spawn 2 tactical backup enforcers to flank player
    final thug1 = EnemyAI(
      id: 'velu_backup_1',
      name: 'Syndicate Thug',
      position: three.Vector3(
        boss.position.x + 3.0,
        0.0,
        boss.position.z - 3.0,
      ),
      archetype: EnemyArchetype.thug,
      health: 75.0,
      maxHealth: 75.0,
    );
    thug1.isAlerted = true;

    final hitman1 = EnemyAI(
      id: 'velu_backup_2',
      name: 'Syndicate Hitman',
      position: three.Vector3(
        boss.position.x - 3.5,
        0.0,
        boss.position.z + 3.0,
      ),
      archetype: EnemyArchetype.hitman,
      health: 65.0,
      maxHealth: 65.0,
      attackRange: 12.0,
      attackDamage: 18.0,
    );
    hitman1.isAlerted = true;

    reinforcements.addAll([thug1, hitman1]);

    // Register with 3D scene and combat system
    scene.add(thug1.group);
    scene.add(hitman1.group);
    combatSystem.activeTargets.addAll([thug1, hitman1]);

    onReinforcementSpawned?.call(thug1);
    onReinforcementSpawned?.call(hitman1);

    onPhaseChanged?.call(
      2,
      "Captain Velu: 'You think you can dismantle the Syndicate, Aadi? You die here in Veyrapuram!'",
    );
  }
}
