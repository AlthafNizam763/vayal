import 'dart:convert';

/// High-level summary metadata of a saved game slot for fast listing.
class SaveSlotMetadata {
  final int slotId; // 0: Autosave, -1: Checkpoint, 1..N: Manual slots
  final String label;
  final DateTime timestamp;
  final int playTimeSeconds;
  final int storyAct;
  final String actTitle;
  final String missionTitle;
  final String regionName;
  final int money;
  final int reputation;
  final bool isAutosave;
  final bool isCheckpoint;

  const SaveSlotMetadata({
    required this.slotId,
    required this.label,
    required this.timestamp,
    required this.playTimeSeconds,
    required this.storyAct,
    required this.actTitle,
    required this.missionTitle,
    required this.regionName,
    required this.money,
    required this.reputation,
    this.isAutosave = false,
    this.isCheckpoint = false,
  });

  Map<String, dynamic> toJson() => {
        'slotId': slotId,
        'label': label,
        'timestamp': timestamp.toIso8601String(),
        'playTimeSeconds': playTimeSeconds,
        'storyAct': storyAct,
        'actTitle': actTitle,
        'missionTitle': missionTitle,
        'regionName': regionName,
        'money': money,
        'reputation': reputation,
        'isAutosave': isAutosave,
        'isCheckpoint': isCheckpoint,
      };

  factory SaveSlotMetadata.fromJson(Map<String, dynamic> json) => SaveSlotMetadata(
        slotId: json['slotId'] as int? ?? 1,
        label: json['label'] as String? ?? 'Save Slot',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        playTimeSeconds: json['playTimeSeconds'] as int? ?? 0,
        storyAct: json['storyAct'] as int? ?? 1,
        actTitle: json['actTitle'] as String? ?? 'ACT I: HOME',
        missionTitle: json['missionTitle'] as String? ?? 'Homecoming',
        regionName: json['regionName'] as String? ?? 'Village Center',
        money: json['money'] as int? ?? 500,
        reputation: json['reputation'] as int? ?? 15,
        isAutosave: json['isAutosave'] as bool? ?? false,
        isCheckpoint: json['isCheckpoint'] as bool? ?? false,
      );

  String get formattedTime {
    final m = (playTimeSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (playTimeSeconds % 60).toString().padLeft(2, '0');
    final h = (playTimeSeconds ~/ 3600);
    return h > 0 ? '${h}h ${m}m' : '${m}m ${s}s';
  }

  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Comprehensive, offline-first game state snapshot.
class GameSaveData {
  final SaveSlotMetadata metadata;

  // Player state
  final double playerX;
  final double playerY;
  final double playerZ;
  final double playerRotationY;
  final double playerHealth;
  final double playerMaxHealth;

  // Region & Environment
  final String currentRegionId;
  final double timeOfDayHours;
  final String weatherCondition;

  // Story & Choices
  final int storyAct;
  final int policeTrust;
  final int criminalReputation;
  final int familyLoyalty;
  final Map<String, dynamic> persistentFlags;
  final List<String> choiceHistoryIds;

  // Missions
  final String? activeMissionId;
  final int currentObjectiveIndex;
  final List<String> completedMissionIds;

  // Economy & Inventory
  final int money;
  final int reputation;
  final List<Map<String, dynamic>> inventoryItems; // [{id: ..., count: ...}]
  final Map<String, int> characterRelationships;

  // Collectibles & Investigation
  final List<String> collectedCollectibleIds;
  final List<String> discoveredClueIds;
  final List<String> solvedLeadIds;

  // Vehicle state
  final bool isInsideVehicle;
  final double? vehicleX;
  final double? vehicleY;
  final double? vehicleZ;
  final double? vehicleHeading;
  final double? vehicleHealth;

  const GameSaveData({
    required this.metadata,
    required this.playerX,
    required this.playerY,
    required this.playerZ,
    required this.playerRotationY,
    required this.playerHealth,
    required this.playerMaxHealth,
    required this.currentRegionId,
    required this.timeOfDayHours,
    required this.weatherCondition,
    required this.storyAct,
    required this.policeTrust,
    required this.criminalReputation,
    required this.familyLoyalty,
    required this.persistentFlags,
    required this.choiceHistoryIds,
    this.activeMissionId,
    required this.currentObjectiveIndex,
    required this.completedMissionIds,
    required this.money,
    required this.reputation,
    required this.inventoryItems,
    required this.characterRelationships,
    this.collectedCollectibleIds = const [],
    this.discoveredClueIds = const [],
    this.solvedLeadIds = const [],
    this.isInsideVehicle = false,
    this.vehicleX,
    this.vehicleY,
    this.vehicleZ,
    this.vehicleHeading,
    this.vehicleHealth,
  });

  Map<String, dynamic> toJson() => {
        'metadata': metadata.toJson(),
        'player': {
          'x': playerX,
          'y': playerY,
          'z': playerZ,
          'rotationY': playerRotationY,
          'health': playerHealth,
          'maxHealth': playerMaxHealth,
        },
        'environment': {
          'currentRegionId': currentRegionId,
          'timeOfDayHours': timeOfDayHours,
          'weatherCondition': weatherCondition,
        },
        'story': {
          'act': storyAct,
          'policeTrust': policeTrust,
          'criminalReputation': criminalReputation,
          'familyLoyalty': familyLoyalty,
          'persistentFlags': persistentFlags,
          'choiceHistoryIds': choiceHistoryIds,
        },
        'missions': {
          'activeMissionId': activeMissionId,
          'currentObjectiveIndex': currentObjectiveIndex,
          'completedMissionIds': completedMissionIds,
        },
        'economy': {
          'money': money,
          'reputation': reputation,
          'inventoryItems': inventoryItems,
          'characterRelationships': characterRelationships,
        },
        'investigation': {
          'collectedCollectibleIds': collectedCollectibleIds,
          'discoveredClueIds': discoveredClueIds,
          'solvedLeadIds': solvedLeadIds,
        },
        'vehicle': {
          'isInsideVehicle': isInsideVehicle,
          'x': vehicleX,
          'y': vehicleY,
          'z': vehicleZ,
          'heading': vehicleHeading,
          'health': vehicleHealth,
        },
      };

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    final metaJson = json['metadata'] as Map<String, dynamic>? ?? {};
    final playerJson = json['player'] as Map<String, dynamic>? ?? {};
    final envJson = json['environment'] as Map<String, dynamic>? ?? {};
    final storyJson = json['story'] as Map<String, dynamic>? ?? {};
    final missionJson = json['missions'] as Map<String, dynamic>? ?? {};
    final ecoJson = json['economy'] as Map<String, dynamic>? ?? {};
    final invstJson = json['investigation'] as Map<String, dynamic>? ?? {};
    final vehJson = json['vehicle'] as Map<String, dynamic>? ?? {};

    return GameSaveData(
      metadata: SaveSlotMetadata.fromJson(metaJson),
      playerX: (playerJson['x'] as num?)?.toDouble() ?? 0.0,
      playerY: (playerJson['y'] as num?)?.toDouble() ?? 0.0,
      playerZ: (playerJson['z'] as num?)?.toDouble() ?? 0.0,
      playerRotationY: (playerJson['rotationY'] as num?)?.toDouble() ?? 0.0,
      playerHealth: (playerJson['health'] as num?)?.toDouble() ?? 100.0,
      playerMaxHealth: (playerJson['maxHealth'] as num?)?.toDouble() ?? 100.0,
      currentRegionId: envJson['currentRegionId'] as String? ?? 'village',
      timeOfDayHours: (envJson['timeOfDayHours'] as num?)?.toDouble() ?? 12.0,
      weatherCondition: envJson['weatherCondition'] as String? ?? 'clear',
      storyAct: storyJson['act'] as int? ?? 1,
      policeTrust: storyJson['policeTrust'] as int? ?? 15,
      criminalReputation: storyJson['criminalReputation'] as int? ?? 40,
      familyLoyalty: storyJson['familyLoyalty'] as int? ?? 50,
      persistentFlags: Map<String, dynamic>.from(storyJson['persistentFlags'] as Map? ?? {}),
      choiceHistoryIds: List<String>.from(storyJson['choiceHistoryIds'] as List? ?? []),
      activeMissionId: missionJson['activeMissionId'] as String?,
      currentObjectiveIndex: missionJson['currentObjectiveIndex'] as int? ?? 0,
      completedMissionIds: List<String>.from(missionJson['completedMissionIds'] as List? ?? []),
      money: ecoJson['money'] as int? ?? 500,
      reputation: ecoJson['reputation'] as int? ?? 15,
      inventoryItems: List<Map<String, dynamic>>.from(
        (ecoJson['inventoryItems'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      characterRelationships: Map<String, int>.from(
        (ecoJson['characterRelationships'] as Map? ?? {}).map((k, v) => MapEntry(k.toString(), v as int)),
      ),
      collectedCollectibleIds: List<String>.from(invstJson['collectedCollectibleIds'] as List? ?? []),
      discoveredClueIds: List<String>.from(invstJson['discoveredClueIds'] as List? ?? []),
      solvedLeadIds: List<String>.from(invstJson['solvedLeadIds'] as List? ?? []),
      isInsideVehicle: vehJson['isInsideVehicle'] as bool? ?? false,
      vehicleX: (vehJson['x'] as num?)?.toDouble(),
      vehicleY: (vehJson['y'] as num?)?.toDouble(),
      vehicleZ: (vehJson['z'] as num?)?.toDouble(),
      vehicleHeading: (vehJson['heading'] as num?)?.toDouble(),
      vehicleHealth: (vehJson['health'] as num?)?.toDouble(),
    );
  }

  String serialize() => jsonEncode(toJson());

  static GameSaveData deserialize(String rawJson) =>
      GameSaveData.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
}
