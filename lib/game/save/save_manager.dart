import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import '../missions/mission_manager.dart';
import '../player/player.dart';
import '../story/story_act.dart';
import '../story/story_act_manager.dart';
import '../story/story_choice.dart';
import '../story/story_choice_system.dart';
import '../systems/game_state.dart';
import '../vehicles/vehicle_controller.dart';
import '../world/world_chunk_manager.dart';
import '../world/world_region.dart';
import '../../data/inventory/item_data.dart';
import '../collectibles/collectible_manager.dart';
import '../investigation/investigation_manager.dart';
import 'save_data.dart';
import 'save_storage.dart';

/// Central offline Save/Load manager managing manual slots (1..3),
/// autosave (0), and checkpoint (-1) persistence.
class SaveManager extends ChangeNotifier {
  final SaveStorageDriver driver;
  int playTimeSeconds = 0;

  SaveManager({SaveStorageDriver? customDriver})
      : driver = customDriver ?? FileSaveStorageDriver();

  /// Updates playtime counter (called during game loop or heartbeat).
  void tickPlayTime(double deltaSeconds) {
    playTimeSeconds += deltaSeconds.toInt();
  }

  /// Extracts full game snapshot from active game subsystems.
  GameSaveData createSaveSnapshot({
    required int slotId,
    required String label,
    required Player player,
    required GameState gameState,
    required WorldChunkManager chunkManager,
    required StoryChoiceSystem choiceSystem,
    required StoryActManager actManager,
    required MissionManager missionManager,
    VehicleController? vehicleController,
    CollectibleManager? collectibleManager,
    InvestigationManager? investigationManager,
    bool isAutosave = false,
    bool isCheckpoint = false,
  }) {
    final region = chunkManager.activeRegion;
    final regionMeta = RegionData.registry[region]!;
    final actData = StoryActData.allActs[actManager.currentAct]!;

    final activeMission = missionManager.activeMission;
    final activeObjective = activeMission?.currentObjective;

    final metadata = SaveSlotMetadata(
      slotId: slotId,
      label: label,
      timestamp: DateTime.now(),
      playTimeSeconds: playTimeSeconds,
      storyAct: actManager.currentAct.index + 1,
      actTitle: '${actData.romanTitle}: ${actData.title}',
      missionTitle: activeMission?.title ?? 'Exploration',
      regionName: regionMeta.title,
      money: gameState.money,
      reputation: gameState.reputation,
      isAutosave: isAutosave,
      isCheckpoint: isCheckpoint,
    );

    // Extract inventory
    final invList = gameState.inventory.slots
        .map((s) => {'id': s.item.id, 'count': s.quantity})
        .toList();

    // Extract vehicle
    final isInsideVeh = vehicleController?.isDriving ?? false;
    final activeVeh = vehicleController?.activeVehicle;

    return GameSaveData(
      metadata: metadata,
      playerX: player.position.x,
      playerY: player.position.y,
      playerZ: player.position.z,
      playerRotationY: player.rotationY,
      playerHealth: player.health,
      playerMaxHealth: player.maxHealth,
      currentRegionId: region.name,
      timeOfDayHours: 12.0,
      weatherCondition: 'monsoon_mist',
      storyAct: actManager.currentAct.index + 1,
      policeTrust: choiceSystem.policeTrust,
      criminalReputation: choiceSystem.criminalReputation,
      familyLoyalty: choiceSystem.familyLoyalty,
      persistentFlags: Map<String, dynamic>.from(gameState.persistentFlags),
      choiceHistoryIds: choiceSystem.history.map((c) => c.id.name).toList(),
      activeMissionId: activeMission?.id,
      currentObjectiveIndex: activeMission != null && activeObjective != null
          ? activeMission.objectives.indexOf(activeObjective)
          : 0,
      completedMissionIds: List<String>.from(missionManager.completedMissions),
      money: gameState.money,
      reputation: gameState.reputation,
      inventoryItems: invList,
      characterRelationships: Map<String, int>.from(gameState.characterRelationships),
      collectedCollectibleIds: collectibleManager?.getCollectedIds() ?? const [],
      discoveredClueIds: investigationManager?.clues.where((c) => c.isDiscovered).map((c) => c.id).toList() ?? const [],
      solvedLeadIds: investigationManager?.leads.where((l) => l.isSolved).map((l) => l.id).toList() ?? const [],
      isInsideVehicle: isInsideVeh,
      vehicleX: activeVeh?.position.x,
      vehicleY: activeVeh?.position.y,
      vehicleZ: activeVeh?.position.z,
      vehicleHeading: activeVeh?.rotationY,
      vehicleHealth: activeVeh?.health,
    );
  }

  /// Saves a game snapshot into a specific slot.
  Future<bool> saveGame(int slotId, GameSaveData data) async {
    try {
      await driver.writeSave(slotId, data.serialize());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Save error: $e');
      return false;
    }
  }

  /// Loads full save data from a specific slot.
  Future<GameSaveData?> loadGame(int slotId) async {
    try {
      final raw = await driver.readSave(slotId);
      if (raw == null || raw.isEmpty) return null;
      return GameSaveData.deserialize(raw);
    } catch (e) {
      debugPrint('Load error: $e');
      return null;
    }
  }

  /// Lists metadata for all available saves across slots.
  Future<List<SaveSlotMetadata>> listSaveSlots() async {
    final List<SaveSlotMetadata> result = [];
    final slotIds = await driver.listSlots();
    for (final id in slotIds) {
      final raw = await driver.readSave(id);
      if (raw != null && raw.isNotEmpty) {
        try {
          final data = GameSaveData.deserialize(raw);
          result.add(data.metadata);
        } catch (_) {
          // Ignored
        }
      }
    }
    return result;
  }

  /// Deletes a save slot.
  Future<bool> deleteSave(int slotId) async {
    try {
      await driver.deleteSave(slotId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Restores loaded save state into active game subsystems.
  void applySaveDataToGame({
    required GameSaveData data,
    required Player player,
    required GameState gameState,
    required WorldChunkManager chunkManager,
    required StoryChoiceSystem choiceSystem,
    required StoryActManager actManager,
    required MissionManager missionManager,
    VehicleController? vehicleController,
    CollectibleManager? collectibleManager,
    InvestigationManager? investigationManager,
  }) {
    // 1. Restore Player
    player.position.setValues(data.playerX, data.playerY, data.playerZ);
    player.rotationY = data.playerRotationY;
    player.health = data.playerHealth;
    player.maxHealth = data.playerMaxHealth;
    player.group.position.setFrom(player.position);
    player.group.rotation.y = player.rotationY;

    // 2. Restore Economy & Progression
    gameState.money = data.money;
    gameState.reputation = data.reputation;
    gameState.storyAct = data.storyAct;

    // Restore Inventory slots
    gameState.inventory.clear();
    for (final itemEntry in data.inventoryItems) {
      final itemId = itemEntry['id'] as String?;
      final count = (itemEntry['count'] as num?)?.toInt() ?? 1;
      if (itemId != null && ItemData.allItems.containsKey(itemId)) {
        gameState.inventory.addItem(ItemData.allItems[itemId]!, quantity: count);
      }
    }

    // Clear and restore flags
    gameState.persistentFlags.clear();
    gameState.persistentFlags.addAll(data.persistentFlags);
    gameState.storyFlagManager.restoreFromJson(data.persistentFlags);

    // Restore relationships
    gameState.characterRelationships.clear();
    gameState.characterRelationships.addAll(data.characterRelationships);

    // 3. Restore Story Choices & Alignments
    choiceSystem.policeTrust = data.policeTrust;
    choiceSystem.criminalReputation = data.criminalReputation;
    choiceSystem.familyLoyalty = data.familyLoyalty;
    choiceSystem.history.clear();
    for (final cidName in data.choiceHistoryIds) {
      try {
        final cid = ChoiceId.values.firstWhere((e) => e.name == cidName);
        choiceSystem.history.add(StoryChoiceRecord(
          id: cid,
          title: cid.name,
          description: 'Restored from save',
          actNumber: data.storyAct,
          flags: {},
        ));
      } catch (_) {
        // Ignored
      }
    }

    // 4. Restore Story Act
    final targetActIndex = (data.storyAct - 1).clamp(0, StoryAct.values.length - 1);
    actManager.setAct(
      StoryAct.values[targetActIndex],
      gameState: gameState,
      missionManager: missionManager,
    );

    // 5. Restore Region & Culling
    chunkManager.update(three.Vector3(data.playerX, data.playerY, data.playerZ));

    // 6. Restore Missions
    missionManager.completedMissions.clear();
    missionManager.completedMissions.addAll(data.completedMissionIds);
    if (data.activeMissionId != null) {
      missionManager.startMission(data.activeMissionId!);
    }

    // 7. Restore Collectibles & Investigation
    if (collectibleManager != null) {
      collectibleManager.restoreCollectedIds(data.collectedCollectibleIds);
    }
    if (investigationManager != null) {
      investigationManager.restoreFromJson({
        'discoveredClueIds': data.discoveredClueIds,
        'solvedLeadIds': data.solvedLeadIds,
      });
    }

    playTimeSeconds = data.metadata.playTimeSeconds;
    notifyListeners();
  }
}
