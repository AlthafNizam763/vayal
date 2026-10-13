/// Faction disguise classifications.
enum DisguiseType {
  civilianDefault,
  dockWorker,
  syndicateEnforcer,
  policeOfficer,
}

/// Represents an acquired uniform granting access to restricted faction territories
/// and modifying visual appearance and social stealth scrutiny.
class Disguise {
  final String id;
  final String name;
  final DisguiseType type;
  final String description;
  final int bodyColorHex;
  final int accentColorHex;
  final List<String> authorizedZoneIds;
  final double suspicionMultiplier;

  const Disguise({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.bodyColorHex,
    required this.accentColorHex,
    required this.authorizedZoneIds,
    this.suspicionMultiplier = 1.0,
  });

  /// Checks if this disguise grants legitimate clearance inside the specified zone.
  bool isAuthorizedFor(String zoneId) => authorizedZoneIds.contains(zoneId);
}

/// Master catalog of all obtainable disguises in Veyrapuram.
class DisguiseDatabase {
  static const civilian = Disguise(
    id: 'disguise_civilian',
    name: 'Aadi (Civilian)',
    type: DisguiseType.civilianDefault,
    description: "Aadi's signature dark jacket and casual trousers.",
    bodyColorHex: 0x19212c,
    accentColorHex: 0xbf4d28,
    authorizedZoneIds: ['zone_streets', 'zone_village', 'zone_slums'],
  );

  static const dockWorker = Disguise(
    id: 'disguise_dock_worker',
    name: 'Port Dock Worker',
    type: DisguiseType.dockWorker,
    description: 'Utility blue overalls and hardhat clearance tag for cargo docks.',
    bodyColorHex: 0x1d4e89,
    accentColorHex: 0xf7b32b,
    authorizedZoneIds: [
      'zone_streets',
      'zone_village',
      'zone_slums',
      'zone_port_berth',
      'zone_warehouse_docks',
    ],
  );

  static const syndicateEnforcer = Disguise(
    id: 'disguise_syndicate',
    name: 'Syndicate Enforcer',
    type: DisguiseType.syndicateEnforcer,
    description: 'Crimson leather vest and brass insignia worn by Karan’s syndicate thugs.',
    bodyColorHex: 0x6e2121,
    accentColorHex: 0x221111,
    authorizedZoneIds: [
      'zone_streets',
      'zone_village',
      'zone_slums',
      'zone_syndicate_hideout',
      'zone_warehouse_docks',
    ],
  );

  static const policeOfficer = Disguise(
    id: 'disguise_police',
    name: 'Police Officer (Khaki)',
    type: DisguiseType.policeOfficer,
    description: 'Kerala Police Khaki service uniform with official badge.',
    bodyColorHex: 0x967c52,
    accentColorHex: 0x1f2421,
    authorizedZoneIds: [
      'zone_streets',
      'zone_village',
      'zone_slums',
      'zone_police_station',
      'zone_checkpoints',
      'zone_port_berth',
    ],
    suspicionMultiplier: 1.4,
  );

  static List<Disguise> get allDisguises => [
        civilian,
        dockWorker,
        syndicateEnforcer,
        policeOfficer,
      ];

  static Disguise getByType(DisguiseType type) {
    switch (type) {
      case DisguiseType.civilianDefault:
        return civilian;
      case DisguiseType.dockWorker:
        return dockWorker;
      case DisguiseType.syndicateEnforcer:
        return syndicateEnforcer;
      case DisguiseType.policeOfficer:
        return policeOfficer;
    }
  }
}
