/// Lock difficulty tiers dictating precision tolerance and tension resistance.
enum LockDifficulty {
  easy, // Sweet spot tolerance: ±22°
  medium, // Sweet spot tolerance: ±14°
  hard, // Sweet spot tolerance: ±8°
  master, // Sweet spot tolerance: ±4.5°
}

/// Metadata and mechanical configuration for a lockable target in Veyrapuram.
class LockData {
  final String id;
  final String name;
  final LockDifficulty difficulty;
  final double sweetSpotAngle; // 0° to 180°
  final double sweetSpotTolerance; // Allowed deviation in degrees
  final int rewardMoney;
  final String rewardDescription;
  bool isUnlocked;

  LockData({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.sweetSpotAngle,
    required this.sweetSpotTolerance,
    this.rewardMoney = 0,
    this.rewardDescription = '',
    this.isUnlocked = false,
  });

  /// Factory constructors for narrative world targets
  factory LockData.aadiBackdoor() => LockData(
        id: 'lock_aadi_backdoor',
        name: "Aadi's House Backdoor",
        difficulty: LockDifficulty.easy,
        sweetSpotAngle: 48.0,
        sweetSpotTolerance: 22.0,
        rewardMoney: 100,
        rewardDescription: 'Found family emergency savings hidden in the pantry jar.',
      );

  factory LockData.warehouseContraband() => LockData(
        id: 'lock_warehouse_chest',
        name: 'Warehouse Contraband Casket',
        difficulty: LockDifficulty.medium,
        sweetSpotAngle: 122.0,
        sweetSpotTolerance: 14.0,
        rewardMoney: 450,
        rewardDescription: 'Uncut gemstones and smuggled gold bars confiscated from Berth 4.',
      );

  factory LockData.syndicateSafe() => LockData(
        id: 'lock_syndicate_safe',
        name: 'Syndicate Kingpin Iron Safe',
        difficulty: LockDifficulty.hard,
        sweetSpotAngle: 76.0,
        sweetSpotTolerance: 8.0,
        rewardMoney: 1200,
        rewardDescription: 'Black ledger recording payoffs to port customs and police commissioners.',
      );

  factory LockData.customsArmory() => LockData(
        id: 'lock_customs_armory',
        name: 'Port Customs Heavy Armory Locker',
        difficulty: LockDifficulty.master,
        sweetSpotAngle: 154.0,
        sweetSpotTolerance: 4.5,
        rewardMoney: 2000,
        rewardDescription: 'High-grade ballistic ammunition and tactical revolver cylinders.',
      );
}
