import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:vayal/data/inventory/item_data.dart';
import 'package:vayal/data/missions/mission_data.dart';
import 'package:vayal/game/combat/combat_system.dart';
import 'package:vayal/game/combat/damage_system.dart';
import 'package:vayal/game/combat/weapon.dart';
import 'package:vayal/game/combat/weapon_database.dart';
import 'package:vayal/game/inventory/inventory.dart';
import 'package:vayal/game/inventory/item.dart';
import 'package:vayal/game/missions/mission_manager.dart';
import 'package:vayal/game/npc/npc.dart';
import 'package:vayal/game/player/player.dart';
import 'package:vayal/game/player/player_camera.dart';
import 'package:vayal/game/player/player_controller.dart';
import 'package:vayal/game/story/story_act.dart';
import 'package:vayal/game/story/story_act_manager.dart';
import 'package:vayal/game/story/story_choice.dart';
import 'package:vayal/game/story/story_choice_system.dart';
import 'package:vayal/game/systems/game_state.dart';
import 'package:vayal/game/systems/interaction_system.dart';
import 'package:vayal/game/systems/wanted_system.dart';
import 'package:vayal/game/vehicles/vehicle.dart';
import 'package:vayal/game/vehicles/vehicle_controller.dart';
import 'package:vayal/game/world/world_chunk_manager.dart';
import 'package:vayal/game/world/world_manager.dart';
import 'package:vayal/game/world/world_region.dart';
import 'package:vayal/game/audio/audio_event.dart';
import 'package:vayal/game/audio/audio_manager.dart';
import 'package:vayal/game/save/save_data.dart';
import 'package:vayal/game/save/save_manager.dart';
import 'package:vayal/game/save/save_storage.dart';
import 'package:vayal/game/story/ending_manager.dart';
import 'package:vayal/game/cinematics/cinematic_database.dart';
import 'package:vayal/game/cinematics/cinematic_manager.dart';
import 'package:vayal/game/cinematics/cinematic_track.dart';
import 'package:vayal/game/performance/performance_manager.dart';
import 'package:vayal/game/world/world_object.dart';
import 'package:vayal/game/time/game_time_manager.dart';
import 'package:vayal/game/time/time_of_day_period.dart';
import 'package:vayal/game/weather/weather_manager.dart';
import 'package:vayal/game/weather/weather_state.dart';
import 'package:vayal/game/world/world_life_manager.dart';
import 'package:vayal/game/world/map_poi.dart';
import 'package:vayal/game/phone/phone_call.dart';
import 'package:vayal/game/phone/phone_manager.dart';
import 'package:vayal/game/quests/side_quest.dart';
import 'package:vayal/game/quests/side_quest_database.dart';
import 'package:vayal/game/quests/side_quest_manager.dart';
import 'package:vayal/game/combat/enemy_ai.dart';
import 'package:vayal/game/combat/boss_encounter.dart';
import 'package:vayal/ui/hud/boss_hud.dart';
import 'package:vayal/game/stealth/hiding_spot.dart';
import 'package:vayal/game/stealth/stealth_system.dart';
import 'package:vayal/ui/hud/stealth_hud.dart';
import 'package:vayal/game/disguise/disguise.dart';
import 'package:vayal/game/disguise/disguise_manager.dart';
import 'package:vayal/ui/hud/disguise_hud.dart';
import 'package:vayal/game/infiltration/lock_data.dart';
import 'package:vayal/game/infiltration/lockpicking_session.dart';
import 'package:vayal/ui/infiltration/lockpicking_dialog.dart';
import 'package:vayal/game/vehicles/vehicle_radio.dart';
import 'package:vayal/game/vehicles/police_pursuit_manager.dart';
import 'package:vayal/game/vehicles/vehicle_world_manager.dart';
import 'package:vayal/game/ai/police_ai.dart';
import 'package:vayal/ui/hud/vehicle_hud.dart';
import 'package:vayal/ui/inventory/inventory_sheet.dart';
import 'package:vayal/ui/menu/settings_dialog.dart';
import 'package:vayal/game/collectibles/collectible.dart';
import 'package:vayal/game/collectibles/collectible_database.dart';
import 'package:vayal/game/collectibles/collectible_manager.dart';
import 'package:vayal/game/investigation/clue.dart';
import 'package:vayal/game/investigation/investigation_lead.dart';
import 'package:vayal/game/investigation/investigation_database.dart';
import 'package:vayal/game/investigation/investigation_manager.dart';
import 'package:vayal/ui/investigation/investigation_board_dialog.dart';

class TestInteractable implements Interactable {
  @override
  final String id;
  @override
  final String name;
  @override
  final InteractableType type;
  @override
  final three.Vector3 position;
  @override
  final double interactionRadius;
  @override
  final String prompt;

  bool wasExecuted = false;

  TestInteractable({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.interactionRadius = 3.0,
    required this.prompt,
  });

  @override
  bool canInteract(InteractionContext context) => true;

  @override
  InteractionResult onInteract(InteractionContext context) {
    wasExecuted = true;
    return InteractionResult.success('Interacted with $name');
  }
}

void main() {
  group('VAYAL Phase 8, 9, 10 Architecture Tests', () {
    test('InteractionSystem finds closest target and executes interactions', () {
      final system = InteractionSystem();
      final door = TestInteractable(
        id: 'door_1',
        name: 'Front Door',
        type: InteractableType.door,
        position: three.Vector3(0, 0, 0),
        prompt: 'Enter Door',
      );
      final shop = TestInteractable(
        id: 'shop_1',
        name: 'Tea Stall',
        type: InteractableType.shop,
        position: three.Vector3(20, 0, 0),
        prompt: 'Buy Tea',
      );

      system.register(door);
      system.register(shop);

      final contextNearDoor = InteractionContext(
        playerPosition: three.Vector3(1.5, 0, 0),
        storyFlags: {},
        playerMoney: 100,
      );

      final closest = system.findClosestInteractable(contextNearDoor);
      expect(closest, isNotNull);
      expect(closest!.id, 'door_1');

      final result = system.executeInteraction(closest, contextNearDoor);
      expect(result.success, isTrue);
      expect(door.wasExecuted, isTrue);
    });

    test('Inventory stores, stacks, filters, and removes items accurately', () {
      final inventory = Inventory(capacity: 4);

      // Add stackable tea (maxStack = 5)
      expect(inventory.addItem(ItemData.gingerChai, quantity: 3), isTrue);
      expect(inventory.getItemQuantity(ItemData.gingerChai.id), 3);
      expect(inventory.slotCount, 1);

      // Add 4 more tea units (should fill first slot to 5, and create second slot with 2)
      expect(inventory.addItem(ItemData.gingerChai, quantity: 4), isTrue);
      expect(inventory.getItemQuantity(ItemData.gingerChai.id), 7);
      expect(inventory.slotCount, 2);

      // Add non-stackable document
      expect(inventory.addItem(ItemData.oldPhotograph), isTrue);
      expect(inventory.slotCount, 3);

      // Filter by category
      final docs = inventory.getSlotsByCategory(ItemCategory.document);
      expect(docs.length, 1);
      expect(docs.first.item.id, ItemData.oldPhotograph.id);

      final consumables = inventory.getSlotsByCategory(ItemCategory.consumable);
      expect(consumables.length, 2);

      // Remove quantity
      expect(inventory.removeItem(ItemData.gingerChai.id, quantity: 6), isTrue);
      expect(inventory.getItemQuantity(ItemData.gingerChai.id), 1);
    });

    test('GameState manages player money, reputation, starter gear, and progression', () {
      final state = GameState(money: 500, reputation: 20);

      // Check starter belongings
      expect(state.inventory.hasItem(ItemData.fathersWatch.id), isTrue);
      expect(state.inventory.hasItem(ItemData.houseKey.id), isTrue);

      // Money transactions
      expect(state.spendMoney(100), isTrue);
      expect(state.money, 400);

      expect(state.spendMoney(1000), isFalse); // Insufficient funds
      expect(state.money, 400);

      state.earnMoney(300);
      expect(state.money, 700);

      // Reputation progression (clamped 0 to 100)
      state.addReputation(15);
      expect(state.reputation, 35);

      state.addReputation(200);
      expect(state.reputation, 100);

      state.addReputation(-150);
      expect(state.reputation, 0);

      // Story act tracking
      expect(state.storyAct, 1);
    });

    test('Missions, World, and Player systems integrate seamlessly with GameState', () {
      final missionManager = MissionManager();
      final player = Player();
      final camera = PlayerCamera(aspectRatio: 16 / 9);
      final worldManager = WorldManager();
      final playerController = PlayerController(
        player: player,
        camera: camera,
        worldManager: worldManager,
      );

      expect(missionManager.activeMission?.id, 'mission_01_homecoming');
      playerController.setMovementInput(const Offset(0, 0.5));
      playerController.update(0.1);
      expect(playerController.state, MovementState.walking);
    });
  });

  group('VAYAL Phase 11: Combat System Tests', () {
    test('Melee strikes detect forward targets within reach cone and inflict damage', () {
      final combat = CombatSystem();
      final thug = CombatTarget(
        id: 'thug_1',
        name: 'Thug',
        position: three.Vector3(0.0, 0.0, 1.2), // In front of player facing Z
        health: 100.0,
      );
      combat.activeTargets.add(thug);

      // Attack facing positive Z (rotationY = 0)
      final hit = combat.executeLightAttack(
        playerPosition: three.Vector3(0, 0, 0),
        playerRotationY: 0.0,
      );

      expect(hit, isTrue);
      expect(combat.currentAction, CombatAction.lightAttack);
      expect(thug.health, lessThan(100.0));
      expect(thug.health, 82.0); // 100 - 18
    });

    test('Heavy strike inflicts knockdown on target and deals heavier damage', () {
      final combat = CombatSystem();
      final thug = CombatTarget(
        id: 'thug_2',
        name: 'Thug Heavy',
        position: three.Vector3(0.0, 0.0, 1.4),
        health: 100.0,
      );
      combat.activeTargets.add(thug);

      final hit = combat.executeHeavyAttack(
        playerPosition: three.Vector3(0, 0, 0),
        playerRotationY: 0.0,
      );

      expect(hit, isTrue);
      expect(thug.health, 62.0); // 100 - 38
      expect(thug.isKnockedDown, isTrue);

      // Knockdown recovers after 2 seconds
      thug.update(2.1);
      expect(thug.isKnockedDown, isFalse);
    });

    test('Defensive blocking mitigates 75% of incoming attack damage', () {
      final combat = CombatSystem();
      combat.setBlocking(true);
      expect(combat.isBlocking, isTrue);

      // Strike player with 40 damage
      combat.damagePlayer(const DamageInfo(amount: 40.0, type: DamageType.melee));
      // Only 25% (10 damage) should pierce guard
      expect(combat.playerHealth, 90.0);

      // Lower guard
      combat.setBlocking(false);
      combat.damagePlayer(const DamageInfo(amount: 40.0, type: DamageType.melee));
      // Full 40 damage taken
      expect(combat.playerHealth, 50.0);
    });

    test('Dodging grants temporary invulnerability frames', () {
      final combat = CombatSystem();
      expect(combat.executeDodge(), isTrue);
      expect(combat.isInvulnerable, isTrue);

      // Damage taken during dodge is fully negated
      combat.damagePlayer(const DamageInfo(amount: 50.0));
      expect(combat.playerHealth, 100.0);

      // After dodge duration expires, invulnerability ends
      combat.update(0.4);
      expect(combat.isInvulnerable, isFalse);
    });
  });

  group('VAYAL Phase 12: Vehicle Dynamics Tests', () {
    test('Vehicle accelerates, steers, and decelerates with Ackermann kinematics', () {
      final vehicle = Vehicle(
        id: 'test_sedan',
        initialPosition: three.Vector3(0, 0, 0),
      );
      final controller = VehicleController();
      final player = Player();
      final camera = PlayerCamera(aspectRatio: 16 / 9);

      controller.enterVehicle(vehicle, player);
      expect(controller.isDriving, isTrue);
      expect(vehicle.isOccupied, isTrue);
      expect(player.group.visible, isFalse);

      // Accelerate forward
      controller.update(
        dt: 0.2,
        throttleInput: 1.0,
        steerInput: 0.5,
        handbrake: false,
        npcs: [],
        camera: camera,
      );

      expect(vehicle.speed, greaterThan(0.0));
      expect(vehicle.position.z, greaterThan(0.0));

      // Exit vehicle drops player beside car
      controller.exitVehicle(player);
      expect(controller.isDriving, isFalse);
      expect(vehicle.isOccupied, isFalse);
      expect(player.group.visible, isTrue);
    });

    test('Vehicle sustains collision damage and impacts pedestrians at speed', () {
      final vehicle = Vehicle(
        id: 'crash_car',
        initialPosition: three.Vector3(0, 0, 0),
      );
      final controller = VehicleController();
      final camera = PlayerCamera(aspectRatio: 16 / 9);
      final pedestrian = NPC(
        id: 'ped_1',
        name: 'Pedestrian',
        type: NpcType.civilian,
        initialPosition: three.Vector3(0, 0, 1.0),
      );

      vehicle.speed = 10.0; // Moving fast
      controller.activeVehicle = vehicle;
      vehicle.isOccupied = true;

      bool hitTriggered = false;
      controller.onPedestrianHit = (npc, speed) {
        hitTriggered = true;
        expect(npc.id, 'ped_1');
        expect(speed, greaterThanOrEqualTo(10.0));
      };

      controller.update(
        dt: 0.05,
        throttleInput: 1.0,
        steerInput: 0.0,
        handbrake: false,
        npcs: [pedestrian],
        camera: camera,
      );

      expect(hitTriggered, isTrue);

      // Vehicle damage test
      vehicle.takeDamage(const DamageInfo(amount: 45.0, type: DamageType.vehicleImpact));
      expect(vehicle.health, 55.0);
      expect(vehicle.isWrecked, isFalse);

      vehicle.takeDamage(const DamageInfo(amount: 60.0, type: DamageType.vehicleImpact));
      expect(vehicle.health, 0.0);
      expect(vehicle.isWrecked, isTrue);
    });
  });

  group('VAYAL Phase 13: Police & Wanted System Tests', () {
    test('WantedSystem remains dormant until crime reported, then tracks 1-5 stars', () {
      final wanted = WantedSystem();
      expect(wanted.wantedLevel, 0);
      expect(wanted.isEnabled, isFalse);
      expect(wanted.status, PursuitStatus.inactive);

      // Assault civilian -> 1 Star
      wanted.reportCrime(CrimeType.assaultCivilian);
      expect(wanted.wantedLevel, 1);
      expect(wanted.isEnabled, isTrue);
      expect(wanted.status, PursuitStatus.pursuit);

      // Vehicular hit-and-run -> +2 Stars = 3 Stars
      wanted.reportCrime(CrimeType.vehicleHitAndRun);
      expect(wanted.wantedLevel, 3);

      // Maximum cap is 5 stars
      wanted.reportCrime(CrimeType.assaultOfficer); // +2
      wanted.reportCrime(CrimeType.weaponDischarge); // +2
      expect(wanted.wantedLevel, 5);
    });

    test('Evasion cooldown decays wanted stars when player breaks police sight', () {
      final wanted = WantedSystem();
      wanted.setWantedLevel(2);

      final playerPos = three.Vector3(0, 0, 0);
      final policeFarAway = [three.Vector3(100, 0, 100)]; // Far beyond sight range (20m)

      // Initial update detects player out of sight -> switches to evading
      wanted.update(dt: 1.0, playerPosition: playerPos, policePositions: policeFarAway);
      expect(wanted.status, PursuitStatus.evading);
      expect(wanted.isEvading, isTrue);

      // Decay entire 12s cooldown -> drops to 1 star
      wanted.update(dt: 12.0, playerPosition: playerPos, policePositions: policeFarAway);
      expect(wanted.wantedLevel, 1);

      // Decay next 12s -> wanted level cleared!
      bool evadedCallback = false;
      wanted.onPursuitEvaded = () => evadedCallback = true;

      wanted.update(dt: 12.0, playerPosition: playerPos, policePositions: policeFarAway);
      expect(wanted.wantedLevel, 0);
      expect(wanted.status, PursuitStatus.inactive);
      expect(evadedCallback, isTrue);
    });
  });

  group('VAYAL Phase 14: Story Choice System Tests', () {
    test('Records choices, updates persistent flags in GameState, and modifies alignments', () {
      final choiceSystem = StoryChoiceSystem(policeTrust: 20, criminalReputation: 35, familyLoyalty: 50);
      final gameState = GameState();

      final record = StoryChoiceRecord(
        id: ChoiceId.confidedInMeera,
        title: 'Confide in Amma',
        description: 'Told Meera the truth about the gang threats',
        actNumber: 1,
        flags: {'confided_in_meera': true, 'kept_secrets': false},
        familyLoyaltyDelta: 20,
        criminalRepDelta: -10,
        policeTrustDelta: 5,
      );

      choiceSystem.recordChoice(record, gameState);

      expect(choiceSystem.hasChoice(ChoiceId.confidedInMeera), isTrue);
      expect(choiceSystem.familyLoyalty, 70);
      expect(choiceSystem.criminalReputation, 25);
      expect(choiceSystem.policeTrust, 25);

      // Verify sync with GameState
      expect(gameState.getFlag('confided_in_meera'), isTrue);
      expect(gameState.getIntFlag('family_loyalty'), 70);
    });

    test('Predicts narrative endings based on player moral and faction alignments', () {
      final choiceSystem = StoryChoiceSystem();

      // High family loyalty, low criminal rep -> Ending A: Walk Away
      choiceSystem.familyLoyalty = 80;
      choiceSystem.criminalReputation = 20;
      choiceSystem.policeTrust = 30;
      expect(choiceSystem.calculatePredictedEnding(), PredictedEnding.walkAway);

      // High criminal rep -> Ending B: Revenge
      choiceSystem.criminalReputation = 75;
      choiceSystem.familyLoyalty = 30;
      expect(choiceSystem.calculatePredictedEnding(), PredictedEnding.revenge);

      // High police trust and moderate family loyalty -> Ending C: Expose Everything
      choiceSystem.policeTrust = 70;
      choiceSystem.criminalReputation = 30;
      choiceSystem.familyLoyalty = 50;
      expect(choiceSystem.calculatePredictedEnding(), PredictedEnding.exposeEverything);
    });
  });

  group('VAYAL Phase 15: Open World Expansion & Chunk Streaming Tests', () {
    test('Registry defines coordinates and metadata for all 8 geographic regions', () {
      expect(RegionData.registry.length, 8);
      expect(RegionData.registry[WorldRegion.village]!.title, 'VILLAGE SECTOR');
      expect(RegionData.registry[WorldRegion.oldTown]!.title, 'OLD TOWN BAZAAR');
      expect(RegionData.registry[WorldRegion.industrial]!.title, 'INDUSTRIAL DISTRICT');
      expect(RegionData.registry[WorldRegion.harbour]!.title, contains('PORT VEYRAPURAM'));
      expect(RegionData.registry[WorldRegion.highway]!.center.z, -140.0);
    });

    test('WorldChunkManager detects region transitions and culls distant 3D groups', () {
      final chunkManager = WorldChunkManager();

      final villageGroup = three.Group();
      final harbourGroup = three.Group();
      chunkManager.registerRegionGroup(WorldRegion.village, villageGroup);
      chunkManager.registerRegionGroup(WorldRegion.harbour, harbourGroup);

      // Player in village center (0, 0, 0)
      final reg1 = chunkManager.update(three.Vector3(0, 0, 0));
      expect(reg1, WorldRegion.village);
      expect(chunkManager.activeRegion, WorldRegion.village);

      // Village group is nearby -> visible!
      expect(villageGroup.visible, isTrue);
      // Harbour group is at z: -210m (> renderDistance 115m) -> culled!
      expect(harbourGroup.visible, isFalse);

      // Player travels to harbour (0, 0, -210)
      bool regionEventFired = false;
      chunkManager.onRegionChanged = (oldReg, newReg) {
        regionEventFired = true;
        expect(oldReg, WorldRegion.village);
        expect(newReg, WorldRegion.harbour);
      };

      final reg2 = chunkManager.update(three.Vector3(0, 0, -210));
      expect(reg2, WorldRegion.harbour);
      expect(regionEventFired, isTrue);

      // Now Harbour is visible, and Village is culled!
      expect(harbourGroup.visible, isTrue);
      expect(villageGroup.visible, isFalse);
    });
  });

  group('VAYAL Phase 16: Story Acts Progression Tests', () {
    test('StoryActData defines all 5 narrative acts from Home to Vayal', () {
      expect(StoryActData.allActs.length, 5);
      expect(StoryActData.allActs[StoryAct.act1Home]!.romanTitle, 'ACT I');
      expect(StoryActData.allActs[StoryAct.act1Home]!.title, 'HOME');
      expect(StoryActData.allActs[StoryAct.act2Ghosts]!.title, 'GHOSTS');
      expect(StoryActData.allActs[StoryAct.act3Blood]!.title, 'BLOOD');
      expect(StoryActData.allActs[StoryAct.act4TheTruth]!.title, 'THE TRUTH');
      expect(StoryActData.allActs[StoryAct.act5Vayal]!.title, 'VAYAL');
    });

    test('StoryActManager transitions sequentially and synchronizes with GameState', () {
      final actManager = StoryActManager();
      final gameState = GameState();
      final missionManager = MissionManager();

      expect(actManager.currentAct, StoryAct.act1Home);
      expect(gameState.storyAct, 1);

      // Advance sequentially to Act II: GHOSTS
      expect(actManager.advanceSequentialAct(gameState: gameState, missionManager: missionManager), isTrue);
      expect(actManager.currentAct, StoryAct.act2Ghosts);
      expect(gameState.storyAct, 2);
      expect(actManager.isActCompleted(StoryAct.act1Home), isTrue);

      // Advance to Act III: BLOOD
      expect(actManager.advanceSequentialAct(gameState: gameState, missionManager: missionManager), isTrue);
      expect(actManager.currentAct, StoryAct.act3Blood);
      expect(gameState.storyAct, 3);
    });

    test('MissionData contains missions mapped across all narrative acts', () {
      final allMissions = MissionData.getAllMissions();
      expect(allMissions.containsKey('mission_01_homecoming'), isTrue);
      expect(allMissions.containsKey('mission_02_new_start'), isTrue);
      expect(allMissions.containsKey('mission_03_diya_distance'), isTrue);
      expect(allMissions.containsKey('mission_04_letter_from_nowhere'), isTrue);
      expect(allMissions.containsKey('mission_05_balan_warning'), isTrue);
      expect(allMissions.containsKey('mission_06_old_town_recon'), isTrue);
      expect(allMissions.length, greaterThanOrEqualTo(6));
    });
  });

  group('VAYAL Phase 17: Multiple Story Endings System Tests', () {
    test('EndingDatabase defines all 3 major game resolutions with character fates', () {
      final endingA = EndingDatabase.getEndingData(EndingType.walkAway);
      expect(endingA.code, 'ENDING A');
      expect(endingA.title, 'WALK AWAY');
      expect(endingA.epilogueSlides.length, 4);
      expect(endingA.charactersFate.containsKey('Meera'), isTrue);

      final endingB = EndingDatabase.getEndingData(EndingType.revenge);
      expect(endingB.code, 'ENDING B');
      expect(endingB.title, 'REVENGE');
      expect(endingB.epilogueSlides.length, 4);
      expect(endingB.charactersFate.containsKey('Devraj'), isTrue);

      final endingC = EndingDatabase.getEndingData(EndingType.exposeEverything);
      expect(endingC.code, 'ENDING C');
      expect(endingC.title, 'EXPOSE EVERYTHING');
      expect(endingC.epilogueSlides.length, 4);
      expect(endingC.charactersFate.containsKey('Raghav'), isTrue);
    });

    test('EndingManager evaluates, triggers, advances slides, and sets GameState completion', () {
      final endingManager = EndingManager();
      final gameState = GameState();

      expect(endingManager.isEndingActive, isFalse);

      // Trigger Ending A: Walk Away
      endingManager.triggerEnding(EndingType.walkAway, gameState);
      expect(endingManager.isEndingActive, isTrue);
      expect(endingManager.activeEnding?.type, EndingType.walkAway);
      expect(gameState.getFlag('story_completed'), isTrue);
      expect(gameState.getFlagValue('final_ending_type'), 'walkAway');

      // Slide stepping
      expect(endingManager.currentSlideIndex, 0);
      expect(endingManager.advanceSlide(), isTrue);
      expect(endingManager.currentSlideIndex, 1);
      endingManager.previousSlide();
      expect(endingManager.currentSlideIndex, 0);

      // Conclude ending
      endingManager.concludeEnding();
      expect(endingManager.isEndingActive, isFalse);
    });
  });

  group('VAYAL Phase 18: Offline Save & Load System Tests', () {
    test('GameSaveData serializes and deserializes full state accurately', () {
      final metadata = SaveSlotMetadata(
        slotId: 1,
        label: 'Test Save Slot 1',
        timestamp: DateTime(2026, 10, 10, 12, 0),
        playTimeSeconds: 3600,
        storyAct: 3,
        actTitle: 'ACT III: BLOOD',
        missionTitle: 'Cold Trail at Berth 4',
        regionName: 'Industrial District',
        money: 1250,
        reputation: 45,
      );

      final saveData = GameSaveData(
        metadata: metadata,
        playerX: 15.5,
        playerY: 0.0,
        playerZ: -42.0,
        playerRotationY: 1.57,
        playerHealth: 85.0,
        playerMaxHealth: 100.0,
        currentRegionId: 'industrial',
        timeOfDayHours: 14.5,
        weatherCondition: 'monsoon_mist',
        storyAct: 3,
        policeTrust: 35,
        criminalReputation: 60,
        familyLoyalty: 40,
        persistentFlags: {'met_informant': true, 'berth4_infiltrated': true},
        choiceHistoryIds: ['sparedInformant'],
        activeMissionId: 'mission_04_cold_trail_berth4',
        currentObjectiveIndex: 1,
        completedMissionIds: ['mission_01_homecoming', 'mission_02_new_start', 'mission_03_shadows_on_porch'],
        money: 1250,
        reputation: 45,
        inventoryItems: [
          {'id': 'fathers_watch', 'count': 1},
          {'id': 'house_key', 'count': 1},
        ],
        characterRelationships: {'meera': 70, 'rahu': 40},
        isInsideVehicle: false,
      );

      final jsonStr = saveData.serialize();
      final restored = GameSaveData.deserialize(jsonStr);

      expect(restored.playerX, 15.5);
      expect(restored.playerZ, -42.0);
      expect(restored.storyAct, 3);
      expect(restored.money, 1250);
      expect(restored.persistentFlags['met_informant'], isTrue);
      expect(restored.metadata.actTitle, 'ACT III: BLOOD');
      expect(restored.completedMissionIds.length, 3);
    });

    test('SaveManager saves, lists, loads, and applies snapshot via in-memory driver', () async {
      final memoryDriver = MemorySaveStorageDriver();
      final saveManager = SaveManager(customDriver: memoryDriver);

      final player = Player();
      player.setPosition(10.0, 0.0, -25.0);
      player.health = 90.0;

      final gameState = GameState();
      gameState.money = 800;
      gameState.setFlag('test_flag', true);

      final chunkManager = WorldChunkManager();
      final choiceSystem = StoryChoiceSystem();
      final actManager = StoryActManager();
      final missionManager = MissionManager();

      // Create and save snapshot into Slot 2
      final snapshot = saveManager.createSaveSnapshot(
        slotId: 2,
        label: 'My Slot 2 Save',
        player: player,
        gameState: gameState,
        chunkManager: chunkManager,
        choiceSystem: choiceSystem,
        actManager: actManager,
        missionManager: missionManager,
      );

      final saveSuccess = await saveManager.saveGame(2, snapshot);
      expect(saveSuccess, isTrue);

      // Verify listSlots
      final slots = await saveManager.listSaveSlots();
      expect(slots.length, 1);
      expect(slots.first.slotId, 2);
      expect(slots.first.label, 'My Slot 2 Save');

      // Load and apply into a fresh game state
      final loadedData = await saveManager.loadGame(2);
      expect(loadedData, isNotNull);

      final newPlayer = Player();
      final newGameState = GameState();
      saveManager.applySaveDataToGame(
        data: loadedData!,
        player: newPlayer,
        gameState: newGameState,
        chunkManager: chunkManager,
        choiceSystem: choiceSystem,
        actManager: actManager,
        missionManager: missionManager,
      );

      expect(newPlayer.position.x, 10.0);
      expect(newPlayer.position.z, -25.0);
      expect(newGameState.money, 800);
      expect(newGameState.getFlag('test_flag'), isTrue);
    });
  });

  group('VAYAL Phase 19: Audio System & Spatial Attenuation Tests', () {
    test('AudioManager adjusts volume buses and toggles mute state', () {
      final audio = AudioManager();

      audio.masterVolume = 0.8;
      audio.musicVolume = 0.5;
      audio.sfxVolume = 0.9;
      audio.ambientVolume = 0.4;

      expect(audio.masterVolume, 0.8);
      expect(audio.musicVolume, 0.5);
      expect(audio.sfxVolume, 0.9);
      expect(audio.ambientVolume, 0.4);
      expect(audio.isMuted, isFalse);

      audio.toggleMute();
      expect(audio.isMuted, isTrue);
      audio.toggleMute();
      expect(audio.isMuted, isFalse);
    });

    test('AudioManager plays BGM, Ambience, and dispatches UI / SFX events with telemetry', () {
      final audio = AudioManager();

      audio.playMusic(AudioEvent.themeHome);
      expect(audio.currentMusic, AudioEvent.themeHome);

      audio.playAmbient(AudioEvent.ambientVillageRain);
      expect(audio.currentAmbient, AudioEvent.ambientVillageRain);

      // Play SFX
      audio.playSfx(AudioEvent.uiClick);
      audio.playCombatSfx(AudioEvent.combatPunchHeavy);

      expect(audio.playbackHistory.isNotEmpty, isTrue);
      final lastPlay = audio.playbackHistory.last;
      expect(lastPlay.event, AudioEvent.combatPunchHeavy);
    });

    test('Spatial audio attenuates gain based on 3D distance from listener', () {
      final audio = AudioManager();
      audio.updateListenerPosition(three.Vector3(0, 0, 0));

      final cue = AudioRegistry.getCue(AudioEvent.combatPunchLight);
      // Close distance (< minDistance 4m)
      final closeGain = audio.calculateSpatialGain(cue, three.Vector3(2.0, 0, 0));
      expect(closeGain, 1.0);

      // Mid distance (e.g. 15m)
      final midGain = audio.calculateSpatialGain(cue, three.Vector3(15.0, 0, 0));
      expect(midGain > 0.0 && midGain < 1.0, isTrue);

      // Distant (> maxDistance 30m)
      final farGain = audio.calculateSpatialGain(cue, three.Vector3(45.0, 0, 0));
      expect(farGain, 0.0);
    });
  });

  group('VAYAL Phase 20 Scripted Cinematics Tests', () {
    test('CinematicSequence interpolates keyframes and evaluates camera transform', () {
      final keyframes = [
        CinematicKeyframe(
          time: 0.0,
          cameraPosition: three.Vector3(0, 5, 10),
          targetPosition: three.Vector3(0, 0, 0),
          fov: 50.0,
          subtitleSpeaker: 'Narrator',
          subtitleText: 'The journey begins.',
        ),
        CinematicKeyframe(
          time: 4.0,
          cameraPosition: three.Vector3(0, 10, 20),
          targetPosition: three.Vector3(0, 2, 0),
          fov: 60.0,
        ),
      ];

      final seq = CinematicSequence(
        id: 'test_cinematic',
        title: 'Test Cinematic',
        duration: 4.0,
        keyframes: keyframes,
      );

      // t = 0.0
      final initial = seq.evaluate(0.0);
      expect(initial.cameraPosition.x, 0.0);
      expect(initial.cameraPosition.y, 5.0);
      expect(initial.cameraPosition.z, 10.0);
      expect(initial.fov, 50.0);
      expect(initial.speaker, 'Narrator');
      expect(initial.subtitle, 'The journey begins.');

      // Midpoint t = 2.0
      final mid = seq.evaluate(2.0);
      expect(mid.cameraPosition.y > 5.0 && mid.cameraPosition.y < 10.0, isTrue);
      expect(mid.fov > 50.0 && mid.fov < 60.0, isTrue);

      // End t = 4.0
      final end = seq.evaluate(4.0);
      expect(end.cameraPosition.y, 10.0);
      expect(end.cameraPosition.z, 20.0);
      expect(end.fov, 60.0);
    });

    test('CinematicManager manages playback lifecycle, letterbox factor, and skip', () {
      final manager = CinematicManager();
      final seq = CinematicDatabase.introArrival;

      bool completed = false;
      manager.onSequenceComplete = (s) {
        completed = true;
      };

      expect(manager.isPlaying, isFalse);
      expect(manager.letterboxFactor, 0.0);

      manager.playSequence(seq);
      expect(manager.isPlaying, isTrue);
      expect(manager.currentSequence?.id, seq.id);

      // Camera mock
      final camera = PlayerCamera(aspectRatio: 16 / 9);
      manager.update(0.5, camera);
      expect(manager.currentTime, 0.5);
      expect(manager.letterboxFactor > 0.0, isTrue);

      // Skip cutscene
      manager.skip();
      expect(manager.isPlaying, isFalse);
      expect(completed, isTrue);
    });

    test('CinematicDatabase contains all 5 required narrative cutscenes', () {
      expect(CinematicDatabase.introArrival.id, 'intro_arrival');
      expect(CinematicDatabase.porchReveal.id, 'porch_reveal');
      expect(CinematicDatabase.photographReveal.id, 'photograph_reveal');
      expect(CinematicDatabase.berth4Establishing.id, 'berth4_establishing');
      expect(CinematicDatabase.rahuConfrontationIntro.id, 'rahu_confrontation_intro');
      expect(CinematicDatabase.registry.length, greaterThanOrEqualTo(5));
    });
  });

  group('VAYAL Phase 21 UI Systems & Data Registry Tests', () {
    test('RegionData registry contains all 8 districts with metadata', () {
      expect(RegionData.registry.length, 8);
      for (final region in WorldRegion.values) {
        final data = RegionData.registry[region];
        expect(data, isNotNull);
        expect(data!.title.isNotEmpty, isTrue);
        expect(data.subtitle.isNotEmpty, isTrue);
        expect(data.radius > 0, isTrue);
      }
    });

    test('GraphicsPreset enum has 4 distinct tiers with proper labeling', () {
      expect(GraphicsPreset.values.length, 4);
      expect(GraphicsPreset.low.name, 'low');
      expect(GraphicsPreset.medium.name, 'medium');
      expect(GraphicsPreset.high.name, 'high');
      expect(GraphicsPreset.ultra.name, 'ultra');
    });
  });

  group('VAYAL Phase 22 Performance & Mobile Optimization Tests', () {
    test('PerformanceManager presets dynamically scale render distance and NPC radius', () {
      final pm = PerformanceManager();
      expect(pm.currentPreset, GraphicsPreset.high);
      expect(pm.renderDistance, 125.0);
      expect(pm.npcActiveRadius, 48.0);

      pm.setPreset(GraphicsPreset.low);
      expect(pm.renderDistance, 65.0);
      expect(pm.npcActiveRadius, 18.0);

      pm.setPreset(GraphicsPreset.ultra);
      expect(pm.renderDistance, 180.0);
      expect(pm.npcActiveRadius, 65.0);
    });

    test('Spatial grid hashes bounding boxes into 20m cells and queries candidates efficiently', () {
      final pm = PerformanceManager();
      final mesh1 = three.Group();
      final mesh2 = three.Group();

      final objNear = WorldObject(
        id: 'house_near',
        name: 'Nearby House',
        mesh: mesh1,
        bounds: WorldBounds(minX: -5, maxX: 5, minZ: -5, maxZ: 5),
      );

      final objDistant = WorldObject(
        id: 'warehouse_far',
        name: 'Far Warehouse',
        mesh: mesh2,
        bounds: WorldBounds(minX: 200, maxX: 230, minZ: 200, maxZ: 230),
      );

      pm.buildSpatialGrid([objNear, objDistant]);

      // Query player position at (0, 0, 0)
      final candidates = pm.queryNearbyObjects(three.Vector3(0, 0, 0));
      expect(candidates.any((o) => o.id == 'house_near'), isTrue);
      expect(candidates.any((o) => o.id == 'warehouse_far'), isFalse);
    });

    test('NPC simulation budgeting filters distant NPCs outside active radius', () {
      final pm = PerformanceManager(defaultPreset: GraphicsPreset.low); // active radius = 18m
      final npc1 = NPC(
        id: 'npc_near',
        name: 'Close Villager',
        type: NpcType.civilian,
      );
      npc1.position.setValues(5, 0, 5);

      final npc2 = NPC(
        id: 'npc_far',
        name: 'Distant Villager',
        type: NpcType.civilian,
      );
      npc2.position.setValues(50, 0, 50);

      final playerPos = three.Vector3(0, 0, 0);
      final activeNpcs = pm.filterActiveNpcs([npc1, npc2], playerPos);
      expect(activeNpcs.length, 1);
      expect(activeNpcs.first.id, 'npc_near');
    });

    test('Rolling frame metrics compute FPS and frame time accurately', () {
      final pm = PerformanceManager();
      // Record 30 frames at 16.6ms (60 FPS)
      for (int i = 0; i < 30; i++) {
        pm.recordFrame(0.01666);
      }

      final metrics = pm.getMetrics(
        visibleChunks: 9,
        totalChunks: 16,
        activeNpcs: 4,
        totalNpcs: 10,
      );

      expect(metrics.currentFps.round(), 60);
      expect((metrics.frameTimeMs - 16.6).abs() < 1.0, isTrue);
      expect(metrics.visibleChunksCount, 9);
      expect(metrics.totalChunksCount, 16);
      expect(metrics.activeNpcsSimulated, 4);
      expect(metrics.totalNpcsCount, 10);
    });
  });

  group('VAYAL Phase 24 Day/Night System Tests', () {
    test('GameTimeManager maps 24-hour clock to accurate TimePeriods', () {
      expect(GameTimeManager.calculatePeriod(6.0), TimePeriod.sunrise);
      expect(GameTimeManager.calculatePeriod(10.5), TimePeriod.morning);
      expect(GameTimeManager.calculatePeriod(14.0), TimePeriod.afternoon);
      expect(GameTimeManager.calculatePeriod(18.5), TimePeriod.sunset);
      expect(GameTimeManager.calculatePeriod(22.0), TimePeriod.night);
      expect(GameTimeManager.calculatePeriod(2.0), TimePeriod.night);
    });

    test('GameTimeManager advances time gradually and formats clock strings', () {
      final timeManager = GameTimeManager(initialTime: 6.5); // 06:30 AM
      expect(timeManager.hour, 6);
      expect(timeManager.minute, 30);
      expect(timeManager.formattedClock, '6:30 AM');
      expect(timeManager.formattedTime24, '06:30');
      expect(timeManager.currentPeriod, TimePeriod.sunrise);
      expect(timeManager.isDay, isTrue);
      expect(timeManager.isNight, isFalse);

      TimePeriod? capturedOld;
      TimePeriod? capturedNew;
      timeManager.onPeriodChanged = (oldP, newP) {
        capturedOld = oldP;
        capturedNew = newP;
      };

      // Jump to 20.0 (08:00 PM) -> Night
      timeManager.setTime(20.0);
      expect(timeManager.hour, 20);
      expect(timeManager.currentPeriod, TimePeriod.night);
      expect(timeManager.isNight, isTrue);
      expect(capturedOld, TimePeriod.sunrise);
      expect(capturedNew, TimePeriod.night);
      expect(timeManager.formattedClock, '8:00 PM');
    });

    test('Atmospheric lighting modulates sun and ambient parameters across cycle', () {
      final scene = three.Scene();
      final sun = three.DirectionalLight();
      final ambient = three.AmbientLight();

      final timeManager = GameTimeManager(initialTime: 12.0); // Noon
      timeManager.update(dt: 0.0, scene: scene, sun: sun, ambient: ambient);

      expect(sun.intensity >= 1.0, isTrue);
      expect(scene.background, isNotNull);

      // Night lighting
      timeManager.setTime(23.0);
      timeManager.update(dt: 0.0, scene: scene, sun: sun, ambient: ambient);
      expect(sun.intensity < 0.5, isTrue);
      expect(ambient.intensity < 0.5, isTrue);
    });
  });

  group('VAYAL Phase 25 Weather System Tests', () {
    test('WeatherState defines 5 distinct states with proper fog, wetness, and audio', () {
      expect(WeatherState.values.length, 5);
      expect(WeatherState.clear.roadWetness, 0.0);
      expect(WeatherState.heavyRain.roadWetness, 1.0);
      expect(WeatherState.fog.fogDensity > WeatherState.clear.fogDensity, isTrue);
      expect(WeatherState.rain.isRaining, isTrue);
      expect(WeatherState.cloudy.isRaining, isFalse);
    });

    test('WeatherManager transitions between states and updates scene fog and rain mesh', () {
      final weatherManager = WeatherManager(initialWeather: WeatherState.clear);
      final scene = three.Scene();
      weatherManager.initializeScene(scene);

      expect(weatherManager.currentWeather, WeatherState.clear);
      expect(weatherManager.isRaining, isFalse);

      WeatherState? reportedOld;
      WeatherState? reportedNew;
      weatherManager.onWeatherChanged = (oldW, newW) {
        reportedOld = oldW;
        reportedNew = newW;
      };

      weatherManager.setWeather(WeatherState.rain, duration: 1.0);
      expect(weatherManager.targetWeather, WeatherState.rain);
      expect(reportedOld, WeatherState.clear);
      expect(reportedNew, WeatherState.rain);

      // Advance transition to completion
      weatherManager.update(dt: 1.5, scene: scene, playerPosition: three.Vector3(0, 0, 0));
      expect(weatherManager.currentWeather, WeatherState.rain);
      expect(weatherManager.isRaining, isTrue);
      expect(scene.fog, isNotNull);
    });
  });

  group('VAYAL Phase 23 World Life System Tests', () {
    test('ShopSchedule evaluates opening and closing operating hours accurately', () {
      final schedule = ShopSchedule(
        id: 'tea_stall',
        name: 'Chai Stall',
        openHour: 6.0,
        closeHour: 22.0,
      );

      expect(schedule.isOpen(5.5), isFalse); // 5:30 AM (closed)
      expect(schedule.isOpen(6.0), isTrue);  // 6:00 AM (opened)
      expect(schedule.isOpen(14.0), isTrue); // 2:00 PM (opened)
      expect(schedule.isOpen(22.5), isFalse); // 10:30 PM (closed)
    });

    test('WorldLifeManager tracks default shop schedules', () {
      final lifeManager = WorldLifeManager();
      expect(lifeManager.isShopOpen('tea_stall_counter', 10.0), isTrue);
      expect(lifeManager.isShopOpen('tea_stall_counter', 2.0), isFalse);

      final prompt = lifeManager.getShopPrompt('tea_stall_counter', 'Buy Tea', 2.0);
      expect(prompt.contains('[CLOSED]'), isTrue);
    });

    test('TrafficVehicle navigates waypoints, brakes for player, and updates wheels', () {
      final waypoints = [
        three.Vector3(0, 0, 0),
        three.Vector3(0, 0, 20),
      ];

      final vehicle = TrafficVehicle(
        id: 'test_car',
        modelName: 'Maruti 800',
        waypoints: waypoints,
      );

      expect(vehicle.group.children.isNotEmpty, isTrue);
      expect(vehicle.wheels.length, 4);

      // Distant player: vehicle accelerates towards waypoint
      vehicle.update(1.0, three.Vector3(100, 0, 100));
      expect(vehicle.speed > 0.0, isTrue);
      expect(vehicle.group.position.z > 0.0, isTrue);

      // Close player ahead: vehicle brakes
      vehicle.update(1.0, three.Vector3(0, 0, vehicle.group.position.z + 2.0));
      expect(vehicle.speed < vehicle.maxSpeed, isTrue);
    });

    test('WorldLifeManager initializes traffic vehicles and modulates active count by period density', () {
      final lifeManager = WorldLifeManager();
      final scene = three.Scene();
      lifeManager.initialize(scene);

      expect(lifeManager.trafficVehicles.length, 2);
      expect(lifeManager.ambientPedestrians.length, 2);

      final timeManager = GameTimeManager(initialTime: 18.0); // Sunset (rush hour density 1.0)
      lifeManager.update(
        dt: 0.1,
        timeManager: timeManager,
        playerPosition: three.Vector3(0, 0, 0),
      );

      // Both vehicles active during peak dusk
      expect(lifeManager.trafficVehicles.every((v) => v.group.visible), isTrue);
    });
  });

  group('VAYAL Phase 26: Tactical Map & POI Registry Tests', () {
    test('MapPoi registry defines Safehouse, Shops, NPCs, and Landmarks with coordinates', () {
      final pois = MapPoi.defaultPois;
      expect(pois.isNotEmpty, isTrue);

      final safehouse = pois.firstWhere((p) => p.category == PoiCategory.safehouse);
      expect(safehouse.id, 'poi_safehouse');
      expect(safehouse.title, contains('Menon'));
      expect(safehouse.position.x, closeTo(-16.0, 0.1));

      final shops = pois.where((p) => p.category == PoiCategory.shop).toList();
      expect(shops.length, greaterThanOrEqualTo(3));
      expect(shops.any((s) => s.id == 'poi_shop_chai'), isTrue);
      expect(shops.any((s) => s.id == 'poi_shop_garage'), isTrue);

      final npcs = pois.where((p) => p.category == PoiCategory.npc).toList();
      expect(npcs.length, greaterThanOrEqualTo(4));
      expect(npcs.any((n) => n.id == 'poi_npc_meera'), isTrue);
      expect(npcs.any((n) => n.id == 'poi_npc_diya'), isTrue);
      expect(npcs.any((n) => n.id == 'poi_npc_kumaran'), isTrue);
      expect(npcs.any((n) => n.id == 'poi_npc_mohan'), isTrue);

      final landmarks = pois.where((p) => p.category == PoiCategory.landmark).toList();
      expect(landmarks.any((l) => l.id == 'poi_landmark_vayal'), isTrue);
      expect(landmarks.any((l) => l.id == 'poi_landmark_port'), isTrue);
    });

    test('Custom waypoint beacon calculates accurate distance from player position', () {
      final playerPos = three.Vector3(0, 0, 0);
      final customWaypoint = three.Vector3(30, 0, 40);

      final distance = customWaypoint.distanceTo(playerPos);
      expect(distance, closeTo(50.0, 0.01)); // 3-4-5 right triangle
    });
  });

  group('VAYAL Phase 27: Smartphone & Communication System Tests', () {
    test('PhoneManager seeds starter contacts, SMS threads, and unread counts', () {
      final phone = PhoneManager();

      expect(phone.contacts.length, greaterThanOrEqualTo(5));
      expect(phone.contacts.any((c) => c.name == 'Meera'), isTrue);
      expect(phone.contacts.any((c) => c.name == 'Diya'), isTrue);
      expect(phone.contacts.any((c) => c.name == 'Kumaran'), isTrue);
      expect(phone.contacts.any((c) => c.name == 'Mohan'), isTrue);

      expect(phone.hasUnreadMessages, isTrue);
      expect(phone.unreadMessageCount, greaterThan(0));

      final meeraThread = phone.getMessagesForContact('contact_meera');
      expect(meeraThread.isNotEmpty, isTrue);

      phone.markThreadRead('contact_diya');
      final diyaThread = phone.getMessagesForContact('contact_diya');
      expect(diyaThread.every((m) => m.isRead), isTrue);
    });

    test('PhoneManager allows player to send messages and push notifications', () {
      final phone = PhoneManager();
      final initialCount = phone.getMessagesForContact('contact_rahu').length;

      phone.sendPlayerMessage('contact_rahu', 'Understood. Keeping watch at the junction.');
      final updatedThread = phone.getMessagesForContact('contact_rahu');

      expect(updatedThread.length, initialCount + 1);
      expect(updatedThread.last.isFromPlayer, isTrue);
      expect(updatedThread.last.content, contains('watch at the junction'));

      phone.pushNotification('WEATHER ALERT', 'Heavy monsoon rain reported at Harbour');
      expect(phone.notifications.first.title, 'WEATHER ALERT');
      expect(phone.notifications.first.category, 'MISSION');
    });

    test('Incoming Call lifecycle: trigger, answer, advance dialogue, and story triggers', () {
      final phone = PhoneManager();
      String? triggeredStoryId;
      phone.onStoryTriggerFired = (id) => triggeredStoryId = id;

      final testCall = PhoneCall(
        id: 'call_kumaran_intro',
        contactId: 'contact_kumaran',
        callerName: 'Kumaran',
        callerRole: 'Old Mechanic',
        dialogueLines: [
          'Vinod! Some coastal thugs broke into my garage last night.',
          'They stole my 1978 Premier Padmini. Can you help me get it back?',
        ],
        questTriggerId: 'sq_mechanic_premier',
      );

      phone.triggerIncomingCall(testCall);
      expect(phone.activeIncomingCall, isNotNull);
      expect(phone.activeIncomingCall!.callerName, 'Kumaran');

      phone.answerIncomingCall();
      expect(phone.activeIncomingCall, isNull);
      expect(phone.activeOngoingCall, isNotNull);
      expect(triggeredStoryId, 'sq_mechanic_premier');
      expect(phone.activeOngoingCall!.currentLine, contains('garage last night'));

      final hasMore = phone.advanceOngoingCall();
      expect(hasMore, isTrue);
      expect(phone.activeOngoingCall!.currentLine, contains('1978 Premier Padmini'));

      final hasConcluded = phone.advanceOngoingCall();
      expect(hasConcluded, isFalse);
      expect(phone.activeOngoingCall, isNull);
      expect(phone.callHistory.last.status, CallStatus.completed);
    });

    test('Declining incoming call records as declined in call history', () {
      final phone = PhoneManager();
      final call = PhoneCall(
        id: 'call_test',
        contactId: 'contact_meera',
        callerName: 'Meera',
        callerRole: 'Wife',
        dialogueLines: ['Hey Vinod!'],
      );

      phone.triggerIncomingCall(call);
      phone.declineIncomingCall();

      expect(phone.activeIncomingCall, isNull);
      expect(phone.callHistory.last.status, CallStatus.declined);
    });
  });

  group('VAYAL Phase 28: Character Side Story & Quest System Tests', () {
    test('SideQuestDatabase defines all 3 required character side stories', () {
      final quests = SideQuestDatabase.allQuests;
      expect(quests.length, greaterThanOrEqualTo(3));

      final diyaQuest = quests.firstWhere((q) => q.id == 'sq_diya_dilemma');
      expect(diyaQuest.characterName, contains('Diya'));
      expect(diyaQuest.title, "Sister's Dilemma");
      expect(diyaQuest.steps.length, 3);
      expect(diyaQuest.cashReward, 500);
      expect(diyaQuest.reputationReward, 15);

      final mechanicQuest = quests.firstWhere((q) => q.id == 'sq_mechanic_premier');
      expect(mechanicQuest.characterName, contains('Kumaran'));
      expect(mechanicQuest.title, 'The Stolen Premier');
      expect(mechanicQuest.steps.length, 3);
      expect(mechanicQuest.cashReward, 750);

      final harbourQuest = quests.firstWhere((q) => q.id == 'sq_harbour_cargo');
      expect(harbourQuest.characterName, contains('Mohan'));
      expect(harbourQuest.title, 'Midnight Cargo');
      expect(harbourQuest.steps.length, 3);
      expect(harbourQuest.cashReward, 1000);
    });

    test('SideQuestManager tracks active quest, advances steps, and completes without blocking acts', () {
      final manager = SideQuestManager();
      final gameState = GameState(money: 500, reputation: 10, storyAct: 1);

      expect(manager.activeQuest, isNull);
      expect(manager.availableQuests.length, greaterThanOrEqualTo(3));

      // Start Diya's side quest
      final started = manager.startQuest('sq_diya_dilemma');
      expect(started, isTrue);
      expect(manager.activeQuest?.id, 'sq_diya_dilemma');
      expect(manager.activeQuest?.currentStepIndex, 0);

      // Step 1: Meet Diya at (-12, 0, -6)
      // Player is far away: objective not met
      var step = manager.checkLocationObjectives(
        three.Vector3(50, 0, 50),
        gameState: gameState,
      );
      expect(step, isNull);
      expect(manager.activeQuest?.currentStepIndex, 0);

      // Player reaches Diya's orchard location
      step = manager.checkLocationObjectives(
        three.Vector3(-12.0, 0.0, -6.0),
        gameState: gameState,
      );
      expect(step, isNotNull);
      expect(step!.id, 'diya_step_1');
      expect(manager.activeQuest?.currentStepIndex, 1);

      // Step 2: Confront thugs at crossroads (12, 0, 7.5)
      step = manager.checkLocationObjectives(
        three.Vector3(12.0, 0.0, 7.5),
        gameState: gameState,
      );
      expect(step, isNotNull);
      expect(step!.id, 'diya_step_2');
      expect(manager.activeQuest?.currentStepIndex, 2);

      // Step 3: Return to Diya at orchard (-12, 0, -6)
      step = manager.checkLocationObjectives(
        three.Vector3(-12.0, 0.0, -6.0),
        gameState: gameState,
      );
      expect(step, isNotNull);
      expect(step!.id, 'diya_step_3');

      // Quest completes: cash and reputation awarded, main story act unchanged
      final completedQuest = manager.getQuest('sq_diya_dilemma');
      expect(completedQuest?.status, SideQuestStatus.completed);
      expect(gameState.money, 500 + 500); // Starter 500 + 500 reward
      expect(gameState.reputation, 10 + 15); // Starter 10 + 15 reward
      expect(gameState.storyAct, 1); // Main story act remains intact!
    });
  });

  group('VAYAL Phase 29: Weapon & Firearms / Combat Expansion Tests', () {
    test('WeaponDatabase defines Kerala thriller arsenal with melee and firearms', () {
      final knuckles = WeaponDatabase.bareKnuckles;
      expect(knuckles.type, WeaponType.unarmed);
      expect(knuckles.isFirearm, isFalse);
      expect(knuckles.damage, 18.0);

      final vettukathi = WeaponDatabase.vettukathi;
      expect(vettukathi.type, WeaponType.machete);
      expect(vettukathi.canKnockdown, isTrue);
      expect(vettukathi.damage, 55.0);
      expect(vettukathi.range, 2.5);

      final ironRod = WeaponDatabase.ironRod;
      expect(ironRod.type, WeaponType.blunt);
      expect(ironRod.canKnockdown, isTrue);
      expect(ironRod.damage, 44.0);

      final revolver = WeaponDatabase.revolver;
      expect(revolver.type, WeaponType.revolver);
      expect(revolver.isFirearm, isTrue);
      expect(revolver.magazineCapacity, 6);
      expect(revolver.currentAmmo, 6);
      expect(revolver.reserveAmmo, 24);
      expect(revolver.range, 45.0);
    });

    test('CombatSystem equips loadout slots and switches active weapon', () {
      final combat = CombatSystem();
      expect(combat.equippedWeapon.id, 'weapon_unarmed');

      // Switch to slot 1: Vettukathi
      expect(combat.equipSlot(1), isTrue);
      expect(combat.activeSlotIndex, 1);
      expect(combat.equippedWeapon.id, 'weapon_vettukathi');

      // Switch to slot 3: Revolver
      expect(combat.equipSlot(3), isTrue);
      expect(combat.activeSlotIndex, 3);
      expect(combat.equippedWeapon.isFirearm, isTrue);

      // Invalid slot
      expect(combat.equipSlot(99), isFalse);
    });

    test('Melee weapon attack damages target and triggers knockdown', () {
      final combat = CombatSystem();
      combat.equipSlot(1); // Vettukathi

      final target = CombatTarget(
        id: 'thug_1',
        name: 'Syndicate Lookout',
        position: three.Vector3(0, 0, 1.8), // Directly 1.8m ahead
        health: 100.0,
      );
      combat.activeTargets.add(target);

      final attacked = combat.executeWeaponAttack(
        playerPosition: three.Vector3(0, 0, 0),
        playerRotationY: 0.0,
      );

      expect(attacked, isTrue);
      expect(target.health, 100.0 - 55.0);
      expect(target.isKnockedDown, isTrue);
    });

    test('Firearm attack consumes ammo, hits target at distance, and reloads from reserve', () {
      final combat = CombatSystem();
      combat.equipSlot(3); // Revolver

      final target = CombatTarget(
        id: 'thug_distant',
        name: 'Distant Sniper',
        position: three.Vector3(0, 0, 25.0), // 25 meters ahead
        health: 100.0,
      );
      combat.activeTargets.add(target);

      expect(combat.equippedWeapon.currentAmmo, 6);
      expect(combat.equippedWeapon.reserveAmmo, 24);

      // Fire 1 round
      final fired = combat.executeWeaponAttack(
        playerPosition: three.Vector3(0, 0, 0),
        playerRotationY: 0.0,
      );

      expect(fired, isTrue);
      expect(combat.equippedWeapon.currentAmmo, 5);
      expect(target.health, 100.0 - 48.0); // 48 revolver damage

      // Deplete magazine
      while (combat.equippedWeapon.currentAmmo > 0) {
        combat.equippedWeapon.fire();
      }
      expect(combat.equippedWeapon.currentAmmo, 0);
      expect(combat.equippedWeapon.needsReload, isTrue);

      // Reload
      final reloadStarted = combat.startReload();
      expect(reloadStarted, isTrue);
      expect(combat.isReloading, isTrue);

      // Tick reload duration
      combat.update(combat.equippedWeapon.reloadDuration + 0.1);
      expect(combat.isReloading, isFalse);
      expect(combat.equippedWeapon.currentAmmo, 6);
      expect(combat.equippedWeapon.reserveAmmo, 24 - 6);
    });

    test('ADS aiming mode activates and tightens weapon focus', () {
      final combat = CombatSystem();
      expect(combat.isAiming, isFalse);

      combat.setAiming(true);
      expect(combat.isAiming, isTrue);

      combat.setAiming(false);
      expect(combat.isAiming, isFalse);
    });
  });

  group('VAYAL Phase 30: Advanced Enemy & Boss AI System Tests', () {
    test('EnemyAI initializes archetypes with appropriate combat statistics and procedural meshes', () {
      final thug = EnemyAI(
        id: 'test_thug',
        name: 'Street Thug',
        position: three.Vector3(0, 0, 0),
        archetype: EnemyArchetype.thug,
      );
      expect(thug.archetype, EnemyArchetype.thug);
      expect(thug.moveSpeed, 3.2);
      expect(thug.group.children.isNotEmpty, isTrue);

      final hitman = EnemyAI(
        id: 'test_hitman',
        name: 'Marksman',
        position: three.Vector3(0, 0, 0),
        archetype: EnemyArchetype.hitman,
        attackRange: 12.0,
      );
      expect(hitman.archetype, EnemyArchetype.hitman);
      expect(hitman.moveSpeed, 2.6);
      expect(hitman.attackRange, 12.0);

      final enforcer = EnemyAI(
        id: 'test_enforcer',
        name: 'Heavy Enforcer',
        position: three.Vector3(0, 0, 0),
        archetype: EnemyArchetype.enforcer,
      );
      expect(enforcer.archetype, EnemyArchetype.enforcer);
      expect(enforcer.moveSpeed, 1.9);
      expect(enforcer.blockChance, 0.25);
    });

    test('EnemyAI detects player in vision cone and advances in chase state', () {
      final combat = CombatSystem();
      final enemy = EnemyAI(
        id: 'patrol_thug',
        name: 'Patrol Thug',
        position: three.Vector3(0, 0, 10.0), // 10m away (within 14m range)
        archetype: EnemyArchetype.thug,
      );
      expect(enemy.state, EnemyAIState.idle);

      // AI tick
      enemy.updateAI(
        dt: 0.1,
        playerPos: three.Vector3(0, 0, 0),
        combatSystem: combat,
      );

      expect(enemy.state, EnemyAIState.chase);
      expect(enemy.isAlerted, isTrue);
      // Moved closer towards player (Z position decreased from 10.0)
      expect(enemy.position.z, lessThan(10.0));
    });

    test('EnemyAI winds up and executes melee attack damaging player', () {
      final combat = CombatSystem();
      expect(combat.playerHealth, 100.0);

      final enemy = EnemyAI(
        id: 'close_thug',
        name: 'Close Thug',
        position: three.Vector3(0, 0, 1.2), // In melee range
        archetype: EnemyArchetype.thug,
        attackDamage: 20.0,
        attackWindupDuration: 0.2,
      );
      enemy.state = EnemyAIState.chase;

      // First tick enters windup
      enemy.updateAI(
        dt: 0.05,
        playerPos: three.Vector3(0, 0, 0),
        combatSystem: combat,
      );
      expect(enemy.state, EnemyAIState.windup);

      // Advance through windup duration
      enemy.updateAI(
        dt: 0.25,
        playerPos: three.Vector3(0, 0, 0),
        combatSystem: combat,
      );

      // Player took damage
      expect(combat.playerHealth, 100.0 - 20.0);
      expect(enemy.state, EnemyAIState.recovering);
    });

    test('BossEncounter manages Captain Velu multi-phase transition and reinforcements', () {
      final combat = CombatSystem();
      final scene = three.Scene();
      final bossEncounter = BossEncounter.createCaptainVelu(
        spawnPosition: three.Vector3(0, 0, 10.0),
      );
      combat.activeTargets.add(bossEncounter.boss);
      scene.add(bossEncounter.boss.group);

      expect(bossEncounter.currentPhase, 1);
      expect(bossEncounter.hasTriggeredPhase2, isFalse);
      expect(bossEncounter.boss.health, 300.0);

      int phaseChangeReceived = 0;
      String phasePromptReceived = '';
      bossEncounter.onPhaseChanged = (phase, prompt) {
        phaseChangeReceived = phase;
        phasePromptReceived = prompt;
      };

      // Damage boss down to 120 HP (< 50% of 300)
      bossEncounter.boss.takeDamage(const DamageInfo(amount: 180.0));
      expect(bossEncounter.boss.health, 120.0);

      // Update boss encounter to evaluate phase transition
      bossEncounter.update(
        dt: 0.1,
        playerPos: three.Vector3(0, 0, 0),
        combatSystem: combat,
        scene: scene,
      );

      expect(bossEncounter.currentPhase, 2);
      expect(bossEncounter.hasTriggeredPhase2, isTrue);
      expect(phaseChangeReceived, 2);
      expect(phasePromptReceived, contains('Captain Velu'));
      expect(bossEncounter.reinforcements.length, 2);
      expect(combat.activeTargets.length, 3); // Boss + 2 reinforcements

      // Defeat boss
      bool bossDefeatedCalled = false;
      bossEncounter.onBossDefeated = (title) {
        bossDefeatedCalled = true;
      };

      bossEncounter.boss.takeDamage(const DamageInfo(amount: 150.0));
      expect(bossEncounter.boss.isDead, isTrue);

      bossEncounter.update(
        dt: 0.1,
        playerPos: three.Vector3(0, 0, 0),
        combatSystem: combat,
        scene: scene,
      );

      expect(bossEncounter.isDefeated, isTrue);
      expect(bossDefeatedCalled, isTrue);
    });

    testWidgets('BossHudOverlay displays boss title, subtitle, health ratio, and enrage badge', (tester) async {
      final bossAI = EnemyAI(
        id: 'test_boss',
        name: 'Captain Velu',
        position: three.Vector3(0, 0, 0),
        archetype: EnemyArchetype.boss,
        health: 200.0,
        maxHealth: 300.0,
      );
      final encounter = BossEncounter(
        boss: bossAI,
        title: 'CAPTAIN VELU',
        subtitle: 'Syndicate Kingpin of Veyrapuram',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                BossHudOverlay(encounter: encounter),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CAPTAIN VELU'), findsOneWidget);
      expect(find.text('Syndicate Kingpin of Veyrapuram'), findsOneWidget);
      expect(find.text('PHASE 1'), findsOneWidget);
      expect(find.text('200 / 300 HP'), findsOneWidget);
    });
  });

  group('VAYAL Phase 31: Stealth & Infiltration System Tests', () {
    test('StealthSystem tracks crouching, noise radius scaling, and hiding spot concealment', () {
      final stealth = StealthSystem();
      expect(stealth.currentStealthState, StealthState.exposed);
      expect(stealth.isCrouched, isFalse);
      expect(stealth.isConcealed, isFalse);

      // Crouch toggle
      stealth.toggleCrouch();
      expect(stealth.isCrouched, isTrue);
      expect(stealth.currentStealthState, StealthState.sneaking);

      // Noise radius calculation
      stealth.updateNoise(playerSpeed: 0.0, isShooting: false, isMeleeAttacking: false);
      expect(stealth.currentNoiseRadius, 0.0);

      stealth.updateNoise(playerSpeed: 1.9, isShooting: false, isMeleeAttacking: false);
      expect(stealth.currentNoiseRadius, 1.4); // Sneaking footsteps

      stealth.setCrouched(false);
      stealth.updateNoise(playerSpeed: 7.0, isShooting: false, isMeleeAttacking: false);
      expect(stealth.currentNoiseRadius, 8.5); // Sprint footsteps

      stealth.updateNoise(playerSpeed: 0.0, isShooting: true, isMeleeAttacking: false);
      expect(stealth.currentNoiseRadius, 24.0); // Gunshot sound radius

      // Concealment inside environmental hiding spot
      final bushesPos = three.Vector3(-18.0, 0, -5.0); // bushes_safehouse
      stealth.update(
        dt: 0.1,
        playerPos: bushesPos,
        playerSpeed: 0.0,
        activeEnemies: [],
      );
      expect(stealth.isConcealed, isTrue);
      expect(stealth.currentHidingSpot?.type, HidingSpotType.bushes);
      expect(stealth.currentStealthState, StealthState.hidden);

      // Step out of hiding spot
      stealth.update(
        dt: 0.1,
        playerPos: three.Vector3(0, 0, 0),
        playerSpeed: 0.0,
        activeEnemies: [],
      );
      expect(stealth.isConcealed, isFalse);
    });

    test('StealthSystem evaluates enemy vision cones and suspicion accumulation', () {
      final stealth = StealthSystem();
      final enemy = EnemyAI(
        id: 'guard_1',
        name: 'Warehouse Guard',
        position: three.Vector3(0, 0, 8.0),
        archetype: EnemyArchetype.thug,
      );
      // Enemy is facing toward player (Z is negative toward (0,0,0) -> facing Y = pi)
      enemy.rotationY = 3.14159;

      expect(stealth.enemyAwareness[enemy.id] ?? 0.0, 0.0);

      // Update with player in line of sight
      stealth.update(
        dt: 0.5,
        playerPos: three.Vector3(0, 0, 0),
        playerSpeed: 0.0,
        activeEnemies: [enemy],
      );

      expect(stealth.highestAwareness, greaterThan(0.0));
      expect(enemy.state, isNot(EnemyAIState.defeated));
    });

    test('StealthSystem detects takedown candidate only when approached from behind', () {
      final stealth = StealthSystem();
      final enemy = EnemyAI(
        id: 'patrol_back',
        name: 'Patrol Guard',
        position: three.Vector3(0, 0, 5.0),
        archetype: EnemyArchetype.thug,
      );
      // Guard facing towards positive Z (away from 0,0,0)
      enemy.rotationY = 0.0;

      // Player approaches from behind at (0, 0, 4.0)
      final candidate = stealth.findTakedownCandidate(
        playerPos: three.Vector3(0, 0, 4.0),
        activeEnemies: [enemy],
      );
      expect(candidate, isNotNull);
      expect(candidate?.id, 'patrol_back');

      // Player in front of guard at (0, 0, 6.0)
      final frontCandidate = stealth.findTakedownCandidate(
        playerPos: three.Vector3(0, 0, 6.0),
        activeEnemies: [enemy],
      );
      expect(frontCandidate, isNull);
    });

    test('StealthSystem executes silent takedown defeating hostile instantly', () {
      final stealth = StealthSystem();
      final enemy = EnemyAI(
        id: 'target_silent',
        name: 'Lone Sentry',
        position: three.Vector3(0, 0, 5.0),
        archetype: EnemyArchetype.thug,
        health: 80.0,
      );

      bool takedownFired = false;
      stealth.onStealthTakedown = (e) {
        takedownFired = true;
      };

      final executed = stealth.executeTakedown(enemy);
      expect(executed, isTrue);
      expect(enemy.health, 0.0);
      expect(enemy.state, EnemyAIState.defeated);
      expect(takedownFired, isTrue);
    });

    testWidgets('StealthHudOverlay displays posture badge, threat meter, and takedown prompt', (tester) async {
      final stealth = StealthSystem();
      stealth.setCrouched(true);

      final enemy = EnemyAI(
        id: 'dummy_takedown',
        name: 'Syndicate Guard',
        position: three.Vector3(0, 0, 2.0),
        archetype: EnemyArchetype.thug,
      );

      bool takedownTapped = false;
      bool crouchToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                StealthHudOverlay(
                  stealthSystem: stealth,
                  takedownCandidate: enemy,
                  onExecuteTakedown: () => takedownTapped = true,
                  onToggleCrouch: () => crouchToggled = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CROUCHING [C]'), findsOneWidget);
      expect(find.textContaining('STEALTH TAKEDOWN: SYNDICATE GUARD'), findsOneWidget);

      await tester.tap(find.textContaining('STEALTH TAKEDOWN'));
      expect(takedownTapped, isTrue);

      await tester.tap(find.text('CROUCHING [C]'));
      expect(crouchToggled, isTrue);
    });
  });

  group('VAYAL Phase 32: Disguise & Social Stealth System Tests', () {
    test('DisguiseDatabase catalogs faction disguises and authorized sectors', () {
      final civilian = DisguiseDatabase.civilian;
      expect(civilian.type, DisguiseType.civilianDefault);
      expect(civilian.isAuthorizedFor('zone_streets'), isTrue);
      expect(civilian.isAuthorizedFor('zone_warehouse_docks'), isFalse);

      final dockWorker = DisguiseDatabase.dockWorker;
      expect(dockWorker.type, DisguiseType.dockWorker);
      expect(dockWorker.isAuthorizedFor('zone_warehouse_docks'), isTrue);

      final syndicate = DisguiseDatabase.syndicateEnforcer;
      expect(syndicate.type, DisguiseType.syndicateEnforcer);
      expect(syndicate.isAuthorizedFor('zone_syndicate_hideout'), isTrue);

      final police = DisguiseDatabase.policeOfficer;
      expect(police.type, DisguiseType.policeOfficer);
      expect(police.isAuthorizedFor('zone_police_station'), isTrue);
    });

    test('DisguiseManager equips uniforms and updates player 3D appearance', () {
      final player = Player();
      final manager = DisguiseManager();
      manager.unlockDisguise(DisguiseType.dockWorker);

      expect(manager.currentDisguise.type, DisguiseType.civilianDefault);

      // Equip Dock Worker
      final success = manager.equipDisguise(DisguiseType.dockWorker, player);
      expect(success, isTrue);
      expect(manager.currentDisguise.type, DisguiseType.dockWorker);

      // Body mesh color is updated
      final bodyMat = player.bodyMesh.material as three.MeshStandardMaterial;
      expect(bodyMat.color.getHex(), DisguiseDatabase.dockWorker.bodyColorHex);
    });

    test('DisguiseManager detects trespassing in restricted perimeters without proper uniform', () {
      final manager = DisguiseManager();
      final warehousePos = three.Vector3(22.0, 0.0, -18.0); // Inside zone_warehouse_docks

      bool trespassingStarted = false;
      bool trespassingEnded = false;
      manager.onTrespassingStarted = (z) => trespassingStarted = true;
      manager.onTrespassingEnded = (z) => trespassingEnded = true;

      // In civilian attire: unauthorized
      manager.update(
        dt: 0.1,
        playerPos: warehousePos,
        playerSpeed: 0.0,
        isArmed: false,
        isCrouching: false,
        nearbyEnemies: [],
      );
      expect(manager.isTrespassing, isTrue);
      expect(manager.activeRestrictedZone?.id, 'zone_warehouse_docks');
      expect(trespassingStarted, isTrue);

      // Equip Dock Worker disguise: authorized
      final player = Player();
      manager.unlockDisguise(DisguiseType.dockWorker);
      manager.equipDisguise(DisguiseType.dockWorker, player);

      manager.update(
        dt: 0.1,
        playerPos: warehousePos,
        playerSpeed: 0.0,
        isArmed: false,
        isCrouching: false,
        nearbyEnemies: [],
      );
      expect(manager.isTrespassing, isFalse);
      expect(trespassingEnded, isTrue);
    });

    test('Social blending neutralizes suspicion while stationary at blend spot', () {
      final manager = DisguiseManager();
      final blendPos = three.Vector3(20.0, 0.0, -14.0); // blend_cargo_inspection
      manager.disguiseCompromise = 0.5;

      // Stationary in blend spot
      manager.update(
        dt: 0.2,
        playerPos: blendPos,
        playerSpeed: 0.0,
        isArmed: false,
        isCrouching: false,
        nearbyEnemies: [],
      );
      expect(manager.isBlending, isTrue);
      expect(manager.currentBlendSpot?.id, 'blend_cargo_inspection');
      expect(manager.disguiseCompromise, lessThan(0.5)); // Suspicion decayed

      // Moving away breaks blending
      manager.update(
        dt: 0.1,
        playerPos: three.Vector3(0, 0, 0),
        playerSpeed: 2.0,
        isArmed: false,
        isCrouching: false,
        nearbyEnemies: [],
      );
      expect(manager.isBlending, isFalse);
    });

    test('Scrutiny increases under suspicious behavior and blows disguise at threshold', () {
      final manager = DisguiseManager();
      final player = Player();
      manager.unlockDisguise(DisguiseType.syndicateEnforcer);
      manager.equipDisguise(DisguiseType.syndicateEnforcer, player);

      final syndicateGuard = EnemyAI(
        id: 'close_syndicate',
        name: 'Syndicate Lookout',
        position: three.Vector3(2.0, 0, 0), // 2m away
        archetype: EnemyArchetype.enforcer,
      );

      bool coverBlownFired = false;
      manager.onDisguiseBlown = () => coverBlownFired = true;

      // Armed with weapon right next to guard
      manager.update(
        dt: 1.0,
        playerPos: three.Vector3(0, 0, 0),
        playerSpeed: 0.0,
        isArmed: true, // Conspicuous!
        isCrouching: false,
        nearbyEnemies: [syndicateGuard],
      );

      expect(manager.disguiseCompromise, greaterThan(0.5));

      // Advance until compromise >= 1.0
      manager.update(
        dt: 1.0,
        playerPos: three.Vector3(0, 0, 0),
        playerSpeed: 0.0,
        isArmed: true,
        isCrouching: false,
        nearbyEnemies: [syndicateGuard],
      );

      expect(manager.isDisguiseBlown, isTrue);
      expect(coverBlownFired, isTrue);
      expect(syndicateGuard.isAlerted, isTrue);
    });

    testWidgets('DisguiseHudOverlay displays disguise badge, trespassing warning, and blending feedback', (tester) async {
      final manager = DisguiseManager();
      manager.isTrespassing = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                DisguiseHudOverlay(
                  disguiseManager: manager,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('AADI (CIVILIAN)'), findsOneWidget);
      expect(find.textContaining('RESTRICTED ZONE'), findsOneWidget);
    });
  });

  group('VAYAL Phase 33: Lockpicking & Infiltration Mini-Game Tests', () {
    test('LockData factory presets configure accurate difficulty tolerances and rewards', () {
      final backdoor = LockData.aadiBackdoor();
      expect(backdoor.difficulty, LockDifficulty.easy);
      expect(backdoor.sweetSpotTolerance, 22.0);
      expect(backdoor.rewardMoney, 100);

      final casket = LockData.warehouseContraband();
      expect(casket.difficulty, LockDifficulty.medium);
      expect(casket.sweetSpotTolerance, 14.0);
      expect(casket.rewardMoney, 450);

      final safe = LockData.syndicateSafe();
      expect(safe.difficulty, LockDifficulty.hard);
      expect(safe.sweetSpotTolerance, 8.0);
      expect(safe.rewardMoney, 1200);

      final armory = LockData.customsArmory();
      expect(armory.difficulty, LockDifficulty.master);
      expect(armory.sweetSpotTolerance, 4.5);
      expect(armory.rewardMoney, 2000);
    });

    test('LockpickingSession limits cylinder turning angle based on sweet spot deviation', () {
      final lock = LockData(
        id: 'test_lock',
        name: 'Test Lock',
        difficulty: LockDifficulty.medium,
        sweetSpotAngle: 90.0,
        sweetSpotTolerance: 10.0,
      );
      final session = LockpickingSession(lock: lock);

      // Pick at 90° (exact sweet spot)
      session.setPickAngle(90.0);
      expect(session.maxAllowedTurnAngle, 90.0);

      // Pick at 10° (far from sweet spot)
      session.setPickAngle(10.0);
      expect(session.maxAllowedTurnAngle, lessThan(55.0));
    });

    test('LockpickingSession unlocks cylinder when turned within sweet spot', () {
      final lock = LockData(
        id: 'test_lock_2',
        name: 'Test Lock 2',
        difficulty: LockDifficulty.easy,
        sweetSpotAngle: 60.0,
        sweetSpotTolerance: 15.0,
      );
      final session = LockpickingSession(lock: lock);

      bool lockOpenedFired = false;
      session.onLockOpened = () => lockOpenedFired = true;

      // Position pick within tolerance (65° vs 60° target)
      session.setPickAngle(65.0);
      session.startTurning();

      // Tick update until cylinder reaches 90°
      session.update(1.2);

      expect(session.isUnlocked, isTrue);
      expect(lock.isUnlocked, isTrue);
      expect(lockOpenedFired, isTrue);
      expect(session.cylinderAngle, 90.0);
    });

    test('LockpickingSession strains pick and breaks upon 100% stress under resistance', () {
      final lock = LockData(
        id: 'test_lock_3',
        name: 'Test Lock 3',
        difficulty: LockDifficulty.hard,
        sweetSpotAngle: 120.0,
        sweetSpotTolerance: 5.0,
      );
      final session = LockpickingSession(lock: lock, picksRemaining: 3);

      bool pickBrokeFired = false;
      session.onPickBroke = () => pickBrokeFired = true;

      // Position pick far from sweet spot (0° vs 120°)
      session.setPickAngle(0.0);
      session.startTurning();

      // Tick update until stress exceeds 100%
      session.update(1.8);

      expect(session.picksRemaining, 2);
      expect(session.isPickBroken, isTrue);
      expect(pickBrokeFired, isTrue);
      expect(session.isUnlocked, isFalse);
    });

    testWidgets('LockpickingDialog widget renders lock mechanism, difficulty badge, and slider', (tester) async {
      final lock = LockData.warehouseContraband();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LockpickingDialog(
              lock: lock,
              initialPicks: 4,
            ),
          ),
        ),
      );

      expect(find.text(lock.name.toUpperCase()), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('PICKS: 4'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.textContaining('TURN WRENCH'), findsOneWidget);
    });
  });

  group('VAYAL Phase 34: Advanced Vehicle Mechanics & Pursuits Tests', () {
    test('Vehicle tracks tire blowouts and reduces effectiveMaxForwardSpeed', () {
      final vehicle = Vehicle(
        id: 'test_sedan',
        name: 'Ambassador Sedan',
      );

      expect(vehicle.hasBlownTire, isFalse);
      expect(vehicle.effectiveMaxForwardSpeed, vehicle.maxForwardSpeed);

      // Puncture front left tire
      vehicle.punctureTire(TirePosition.frontLeft);
      expect(vehicle.isTireBlown(TirePosition.frontLeft), isTrue);
      expect(vehicle.effectiveMaxForwardSpeed, lessThan(vehicle.maxForwardSpeed));

      // Puncture remaining tires
      vehicle.punctureAllTires();
      expect(vehicle.blownTireCount, 4);
      expect(vehicle.effectiveMaxForwardSpeed, vehicle.maxForwardSpeed * 0.25);

      // Repair tires
      vehicle.repairTires();
      expect(vehicle.hasBlownTire, isFalse);
      expect(vehicle.effectiveMaxForwardSpeed, vehicle.maxForwardSpeed);
    });

    test('Vehicle flags smoking engine and fire when health is critically depleted', () {
      final vehicle = Vehicle(
        id: 'test_car',
        name: 'Premier Padmini',
        maxHealth: 100.0,
      );

      expect(vehicle.isEngineSmoking, isFalse);
      expect(vehicle.isEngineOnFire, isFalse);

      // Inflict damage down to 35 HP (35%) -> smoking engine
      vehicle.takeDamage(DamageInfo(
        amount: 65.0,
        type: DamageType.gunshot,
        attackerId: 'gunman',
      ));
      expect(vehicle.health, 35.0);
      expect(vehicle.isEngineSmoking, isTrue);
      expect(vehicle.isEngineOnFire, isFalse);

      // Inflict damage down to 10 HP (10%) -> engine on fire
      vehicle.takeDamage(DamageInfo(
        amount: 25.0,
        type: DamageType.gunshot,
        attackerId: 'gunman',
      ));
      expect(vehicle.health, 10.0);
      expect(vehicle.isEngineOnFire, isTrue);
    });

    test('VehicleRadio cycles through Kerala stations and can jump to specific station', () {
      final radio = VehicleRadio();

      expect(radio.currentStation.id, 'radio_veyrapuram');
      expect(radio.currentStation.name, '92.7 Veyrapuram FM');

      // Cycle to station 2
      radio.nextStation();
      expect(radio.currentStation.id, 'radio_malabar');

      // Cycle to station 3
      radio.nextStation();
      expect(radio.currentStation.id, 'radio_harbour');

      // Cycle to station 4 (Off)
      radio.nextStation();
      expect(radio.currentStation.id, 'radio_off');

      // Wraps back to station 1
      radio.nextStation();
      expect(radio.currentStation.id, 'radio_veyrapuram');

      // Direct set
      radio.setStation('radio_malabar');
      expect(radio.currentStation.id, 'radio_malabar');
    });

    test('PolicePursuitManager detects roadblock spike strip and triggers tire puncture', () {
      final pursuit = PolicePursuitManager();
      final playerVehicle = Vehicle(
        id: 'player_sedan',
        name: 'Contessa',
      );
      final wanted = WantedSystem();
      final scene = three.Scene();

      // Wanted level 3 activates roadblocks
      wanted.setWantedLevel(3);
      playerVehicle.isOccupied = true;
      playerVehicle.speed = 12.0; // High speed

      // Position car at roadblock bridge (0.0, 0.0, 28.0)
      playerVehicle.position.setValues(0.0, 0.0, 28.0);

      bool spikeHitCallback = false;
      pursuit.onSpikeStripImpact = () => spikeHitCallback = true;

      pursuit.update(
        dt: 0.1,
        playerVehicle: playerVehicle,
        wantedSystem: wanted,
        scene: scene,
      );

      expect(spikeHitCallback, isTrue);
      expect(playerVehicle.tiresBlown.length, 4);
    });

    testWidgets('VehicleHud widget renders speedometer, tire indicators, and radio station banner', (tester) async {
      final vehicle = Vehicle(
        id: 'hud_car',
        name: 'Padmini',
      );
      vehicle.speed = 15.0; // ~54 km/h
      vehicle.punctureTire(TirePosition.frontLeft);

      final radio = VehicleRadio();
      final pursuit = PolicePursuitManager();
      pursuit.isPitImminent = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleHud(
              vehicle: vehicle,
              radio: radio,
              pursuitManager: pursuit,
            ),
          ),
        ),
      );

      // Speedometer & Gear
      expect(find.text('54'), findsOneWidget);
      expect(find.text('KM/H'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      // PIT alert banner
      expect(find.textContaining('PIT MANEUVER IMMINENT'), findsOneWidget);

      // Radio banner
      expect(find.text('92.7 Veyrapuram FM'), findsOneWidget);

      // Tire indicators
      expect(find.textContaining('FL'), findsOneWidget);
      expect(find.textContaining('FR'), findsOneWidget);
    });
  });

  group('VAYAL Phase 35: Police AI System Tests', () {
    test('PoliceOfficerAI initializes with rank, badge, and starts in patrol state', () {
      final officer = PoliceOfficerAI(
        id: 'officer_raghav',
        name: 'Officer Raghav',
        badgeNumber: 'KL-07-4412',
        rank: PoliceRank.subInspector,
        position: three.Vector3(10.0, 0.0, 5.0),
      );

      expect(officer.badgeNumber, 'KL-07-4412');
      expect(officer.rank, PoliceRank.subInspector);
      expect(officer.state, PoliceState.patrol);
      expect(officer.health, 130.0);
    });

    test('PoliceOfficerAI detects player in vision cone when wanted and transitions to chase', () {
      final officer = PoliceOfficerAI(
        id: 'officer_test',
        name: 'Constable Test',
        badgeNumber: 'KL-07-1111',
        position: three.Vector3(0.0, 0.0, 0.0),
        homeRotationY: 0.0, // Facing along +Z
      );
      final wanted = WantedSystem();
      wanted.setWantedLevel(2);
      final combat = CombatSystem();

      // Player in front (+Z)
      final playerPos = three.Vector3(0.0, 0.0, 10.0);
      expect(officer.canSeeTarget(playerPos), isTrue);

      officer.updateAI(
        dt: 0.1,
        playerPos: playerPos,
        wantedSystem: wanted,
        combatSystem: combat,
      );

      expect(officer.state, PoliceState.chase);
      expect(officer.lastKnownPlayerPosition, isNotNull);
    });

    test('PoliceOfficerAI transitions to search when losing line of sight and returns to patrol', () {
      final officer = PoliceOfficerAI(
        id: 'officer_test_2',
        name: 'Constable Test 2',
        badgeNumber: 'KL-07-2222',
        position: three.Vector3(0.0, 0.0, 0.0),
      );
      officer.state = PoliceState.chase;
      officer.lastKnownPlayerPosition = three.Vector3(0.0, 0.0, 10.0);

      final wanted = WantedSystem();
      wanted.setWantedLevel(2);
      final combat = CombatSystem();

      // Player out of sight behind officer (-Z)
      final playerPosBehind = three.Vector3(0.0, 0.0, -10.0);

      officer.updateAI(
        dt: 0.1,
        playerPos: playerPosBehind,
        wantedSystem: wanted,
        combatSystem: combat,
      );

      expect(officer.state, PoliceState.search);
      expect(officer.searchTimer, greaterThan(0.0));

      // Clearing wanted level causes officer to return to patrol
      wanted.clearWantedLevel();
      officer.updateAI(
        dt: 0.1,
        playerPos: playerPosBehind,
        wantedSystem: wanted,
        combatSystem: combat,
      );

      expect(officer.state, PoliceState.returnToPatrol);
    });

    test('PoliceOfficerAI responds to reported crime incident', () {
      final officer = PoliceOfficerAI(
        id: 'officer_test_3',
        name: 'Constable Test 3',
        badgeNumber: 'KL-07-3333',
        position: three.Vector3(0.0, 0.0, 0.0),
      );

      expect(officer.state, PoliceState.patrol);

      officer.notifyIncident(three.Vector3(15.0, 0.0, 20.0), CrimeType.weaponDischarge);
      expect(officer.state, PoliceState.respondToIncident);
      expect(officer.incidentLocation, isNotNull);
      expect(officer.currentShout, isNotNull);
    });

    test('PoliceManager dispatches incidents and tracks officer positions', () {
      final manager = PoliceManager();
      expect(manager.officers.length, 3);

      final wanted = WantedSystem();
      manager.hookWantedSystem(wanted);

      // Report crime -> triggers incident response
      wanted.reportCrime(CrimeType.assaultCivilian);
      expect(manager.officers.first.state, PoliceState.respondToIncident);
    });
  });

  group('VAYAL Phase 36: Vehicle World System Tests', () {
    test('Vehicle supports distinct vehicle archetypes with tailored physical attributes', () {
      final bike = Vehicle.bike(
        id: 'test_bullet',
        name: 'Royal Enfield Bullet 350',
      );
      expect(bike.vehicleType, VehicleType.bike);
      expect(bike.maxForwardSpeed, 25.0);
      expect(bike.width, 0.9);
      expect(bike.interactionRadius, 2.6);

      final truck = Vehicle.truck(
        id: 'test_tata',
        name: 'Tata 1210SE Heavy Timber Lorry',
      );
      expect(truck.vehicleType, VehicleType.truck);
      expect(truck.maxForwardSpeed, 15.0);
      expect(truck.maxHealth, 220.0);
      expect(truck.width, 2.5);

      final van = Vehicle.van(
        id: 'test_omni',
        name: 'Maruti Omni Cargo Van',
      );
      expect(van.vehicleType, VehicleType.van);
      expect(van.width, 1.8);

      final police = Vehicle.police(
        id: 'test_cruiser',
        name: 'Kerala Police Cruiser',
      );
      expect(police.vehicleType, VehicleType.policeVehicle);
    });

    test('Vehicle tracks ownership and marks stolen when mounting non-owned vehicle', () {
      final ownedCar = Vehicle.car(
        id: 'aadi_car',
        name: 'Premier Padmini',
        isOwnedByPlayer: true,
      );
      expect(ownedCar.isOwnedByPlayer, isTrue);
      expect(ownedCar.prompt, contains('DRIVE'));

      final parkedBike = Vehicle.bike(
        id: 'chai_bike',
        name: 'Bullet 350',
        isOwnedByPlayer: false,
      );
      expect(parkedBike.isOwnedByPlayer, isFalse);
      expect(parkedBike.prompt, contains('STEAL'));

      final ctx = InteractionContext(
        playerPosition: three.Vector3(0, 0, 0),
        storyFlags: const {},
        playerMoney: 500,
      );
      parkedBike.onInteract(ctx);
      expect(parkedBike.isOccupied, isTrue);
      expect(parkedBike.isStolen, isTrue);
    });

    test('VehicleController adjusts camera distance and height based on vehicle type', () {
      final controller = VehicleController();
      final player = Player();

      final bike = Vehicle.bike();
      controller.enterVehicle(bike, player);
      expect(controller.cameraDistance, 5.8);
      expect(controller.cameraHeight, 2.3);

      final truck = Vehicle.truck();
      controller.enterVehicle(truck, player);
      expect(controller.cameraDistance, 11.5);
      expect(controller.cameraHeight, 4.5);

      final car = Vehicle.car();
      controller.enterVehicle(car, player);
      expect(controller.cameraDistance, 8.0);
      expect(controller.cameraHeight, 3.2);
    });

    test('VehicleWorldManager initializes open-world fleet, finds nearest, and saves snapshots', () {
      final manager = VehicleWorldManager();
      expect(manager.vehicles.length, 5);

      // Find nearest vehicle
      final nearPadmini = manager.findNearbyVehicle(three.Vector3(1.8, 0.0, -8.0));
      expect(nearPadmini, isNotNull);
      expect(nearPadmini!.id, 'premier_sedan');

      // Snapshots serialization & restoration
      final snapshots = manager.saveSnapshots();
      expect(snapshots.length, 5);
      expect(snapshots.first['id'], 'premier_sedan');

      // Mutate and restore
      manager.vehicles.first.punctureAllTires();
      expect(manager.vehicles.first.blownTireCount, 4);

      // Restore clean state from snapshot
      snapshots.first['tiresBlown'] = [false, false, false, false];
      manager.restoreSnapshots(snapshots);
      expect(manager.vehicles.first.blownTireCount, 0);
    });
  });

  // =========================================================================
  // PHASE 37: COMBAT EXPANSION & STAMINA MECHANICS TESTS
  // =========================================================================
  group('VAYAL Phase 37: Combat Expansion & Stamina Mechanics Tests', () {
    test('CombatSystem tracks playerStamina, deducts stamina on light, heavy, weapon attack and dodge', () {
      final combat = CombatSystem();
      expect(combat.playerStamina, 100.0);
      expect(combat.playerMaxStamina, 100.0);
      expect(combat.isExhausted, isFalse);

      final dummyPos = three.Vector3(0, 0, 0);

      // 1. Light attack deducts 12 stamina
      final lightOk = combat.executeLightAttack(playerPosition: dummyPos, playerRotationY: 0.0);
      expect(lightOk, isTrue);
      expect(combat.playerStamina, 88.0);
      combat.actionTimer = 0.0;
      combat.currentAction = CombatAction.idle;

      // 2. Dodge roll deducts 20 stamina
      final dodgeOk = combat.executeDodge();
      expect(dodgeOk, isTrue);
      expect(combat.playerStamina, 68.0);
      combat.actionTimer = 0.0;
      combat.isInvulnerable = false;
      combat.currentAction = CombatAction.idle;

      // 3. Heavy attack deducts 28 stamina
      final heavyOk = combat.executeHeavyAttack(playerPosition: dummyPos, playerRotationY: 0.0);
      expect(heavyOk, isTrue);
      expect(combat.playerStamina, 40.0);
      combat.actionTimer = 0.0;
      combat.currentAction = CombatAction.idle;

      // 4. Melee weapon attack (machete slot 1) deducts 16 stamina
      combat.equipSlot(1);
      final weaponOk = combat.executeWeaponAttack(playerPosition: dummyPos, playerRotationY: 0.0);
      expect(weaponOk, isTrue);
      expect(combat.playerStamina, 24.0);
    });

    test('Stamina exhaustion prevents offensive strikes and dodges until recovery', () {
      final combat = CombatSystem();
      combat.playerStamina = 5.0; // Less than light attack cost (12)
      final dummyPos = three.Vector3(0, 0, 0);

      expect(combat.executeLightAttack(playerPosition: dummyPos, playerRotationY: 0.0), isFalse);
      expect(combat.executeHeavyAttack(playerPosition: dummyPos, playerRotationY: 0.0), isFalse);
      expect(combat.executeDodge(), isFalse);

      // Force exhaustion
      combat.playerStamina = 0.0;
      combat.isExhausted = true;

      // Attempt stamina recovery
      combat.restoreStamina(15.0);
      expect(combat.playerStamina, 15.0);
      expect(combat.isExhausted, isTrue); // Needs 25.0 to clear exhaustion

      combat.restoreStamina(12.0); // Now 27.0
      expect(combat.playerStamina, 27.0);
      expect(combat.isExhausted, isFalse); // Cleared!
    });

    test('CombatSystem regenerates stamina gradually when idle', () {
      final combat = CombatSystem();
      combat.playerStamina = 30.0;

      // Update after delay timer has elapsed
      combat.update(1.0); // 22.0 regen per second
      expect(combat.playerStamina > 30.0, isTrue);
      expect(combat.playerStamina, closeTo(52.0, 0.5));

      // Cannot exceed playerMaxStamina
      combat.update(5.0);
      expect(combat.playerStamina, 100.0);
    });

    test('Blocking absorbs incoming damage, drains stamina, and triggers Guard Break when depleted', () {
      final combat = CombatSystem();
      combat.playerStamina = 25.0;
      combat.setBlocking(true);
      expect(combat.isBlocking, isTrue);

      bool guardBreakCalled = false;
      combat.onGuardBroken = () {
        guardBreakCalled = true;
      };

      // 1. Take attack while blocking: mitigates 75% damage, drains 15 stamina
      combat.damagePlayer(DamageInfo(
        amount: 20.0,
        type: DamageType.melee,
        attackerId: 'thug_1',
      ));
      expect(combat.playerHealth, 95.0); // 20 * 0.25 = 5 damage taken
      expect(combat.playerStamina, 10.0); // 25 - 15 = 10 stamina left
      expect(combat.isGuardBroken, isFalse);

      // 2. Take another attack: stamina (10) < block cost (15) -> Guard Break!
      combat.damagePlayer(DamageInfo(
        amount: 20.0,
        type: DamageType.melee,
        attackerId: 'thug_1',
      ));
      expect(combat.playerStamina, 0.0);
      expect(combat.isGuardBroken, isTrue);
      expect(combat.isPlayerKnockedDown, isTrue);
      expect(combat.currentAction, CombatAction.knockedDown);
      expect(guardBreakCalled, isTrue);
    });

    test('CombatTarget experiences hit reaction flash, stagger timer, and knockdown', () {
      final target = CombatTarget(
        id: 'velu_thug',
        name: 'Harbour Thug',
        position: three.Vector3(0, 0, 0),
        health: 100.0,
      );

      expect(target.isStaggered, isFalse);
      expect(target.hitFlashTimer, 0.0);

      // Deal moderate damage: triggers stagger and hit flash
      target.takeDamage(DamageInfo(
        amount: 18.0,
        type: DamageType.melee,
        attackerId: 'aadi',
      ));
      expect(target.health, 82.0);
      expect(target.isStaggered, isTrue);
      expect(target.hitFlashTimer > 0.0, isTrue);

      // Tick update recovers stagger
      target.update(0.5);
      expect(target.isStaggered, isFalse);
      expect(target.hitFlashTimer, 0.0);

      // Deal heavy knockdown strike
      target.takeDamage(DamageInfo(
        amount: 40.0,
        type: DamageType.melee,
        attackerId: 'aadi',
        canKnockdown: true,
      ));
      expect(target.isKnockedDown, isTrue);
    });
  });

  // =========================================================================
  // PHASE 38: INVENTORY EXPANSION & EQUIPMENT PERSISTENCE TESTS
  // =========================================================================
  group('VAYAL Phase 38: Inventory Expansion & Equipment Persistence Tests', () {
    test('ItemData provides expanded crime thriller catalog including medical kits, key items, and collectibles', () {
      expect(ItemData.gingerChai.category, ItemCategory.consumable);
      expect(ItemData.gingerChai.effect, isNotNull);
      expect(ItemData.gingerChai.effect!.staminaRestore, 45.0);

      expect(ItemData.firstAidKit.category, ItemCategory.consumable);
      expect(ItemData.firstAidKit.effect!.healthRestore, 75.0);

      expect(ItemData.ayurvedicBalm.category, ItemCategory.consumable);
      expect(ItemData.ayurvedicBalm.effect!.staminaRestore, 60.0);

      expect(ItemData.docksMasterKey.category, ItemCategory.keyItem);
      expect(ItemData.fathersDiary.category, ItemCategory.collectible);
      expect(ItemData.policeRadioReceiver.category, ItemCategory.missionItem);
    });

    test('Inventory handles item stacking, capacity limits, and unit removal', () {
      final inventory = Inventory(capacity: 3);

      // Add 7 units of ginger chai (maxStack: 5)
      expect(inventory.addItem(ItemData.gingerChai, quantity: 7), isTrue);
      expect(inventory.slotCount, 2);
      expect(inventory.slots[0].quantity, 5); // full stack
      expect(inventory.slots[1].quantity, 2); // remaining stack

      // Add another item filling last slot
      expect(inventory.addItem(ItemData.firstAidKit, quantity: 1), isTrue);
      expect(inventory.isFull, isTrue);

      // Adding to new slot fails when full
      expect(inventory.addItem(ItemData.docksMasterKey, quantity: 1), isFalse);

      // Remove 3 units of ginger chai
      expect(inventory.removeItem('ginger_chai', quantity: 3), isTrue);
      expect(inventory.getItemQuantity('ginger_chai'), 4);
    });

    test('Inventory.useItem consumes consumable, applies health/stamina restoration, and fires callback', () {
      final inventory = Inventory();
      final combat = CombatSystem();
      combat.playerHealth = 40.0;
      combat.playerStamina = 30.0;

      inventory.addItem(ItemData.gingerChai, quantity: 2);

      Item? usedItem;
      ItemEffect? appliedEffect;
      inventory.onItemUsed = (item, effect) {
        usedItem = item;
        appliedEffect = effect;
      };

      final effect = inventory.useItem('ginger_chai', combatSystem: combat);
      expect(effect, isNotNull);
      expect(combat.playerHealth, 55.0); // +15 HP
      expect(combat.playerStamina, 75.0); // +45 Stamina
      expect(inventory.getItemQuantity('ginger_chai'), 1);
      expect(usedItem?.id, 'ginger_chai');
      expect(appliedEffect?.staminaRestore, 45.0);

      // Non-usable item cannot be consumed
      inventory.addItem(ItemData.docksMasterKey);
      expect(inventory.useItem('docks_master_key', combatSystem: combat), isNull);
    });

    test('Inventory manages equipment slots for weapons and gear', () {
      final inventory = Inventory();
      inventory.addItem(ItemData.pocketKnife);
      inventory.addItem(ItemData.fathersWatch);

      expect(inventory.equippedWeaponId, isNull);
      expect(inventory.isItemEquipped('pocket_knife'), isFalse);

      // Equip knife
      expect(inventory.equipItem('pocket_knife'), isTrue);
      expect(inventory.equippedWeaponId, 'pocket_knife');
      expect(inventory.isItemEquipped('pocket_knife'), isTrue);

      // Equip watch
      expect(inventory.equipItem('fathers_watch'), isTrue);
      expect(inventory.equippedAttireId, 'fathers_watch');
      expect(inventory.isItemEquipped('fathers_watch'), isTrue);

      // Unequip weapon
      expect(inventory.unequipItem(ItemCategory.weapon), isTrue);
      expect(inventory.equippedWeaponId, isNull);
      expect(inventory.isItemEquipped('pocket_knife'), isFalse);
    });

    test('Inventory serializes to JSON and restores state with slots and equipped items', () {
      final original = Inventory(capacity: 8);
      original.addItem(ItemData.firstAidKit, quantity: 2);
      original.addItem(ItemData.pocketKnife);
      original.equipItem('pocket_knife');

      final json = original.toJson();
      expect(json['capacity'], 8);
      expect(json['equippedWeaponId'], 'pocket_knife');
      expect((json['slots'] as List).length, 2);

      // Restore from JSON
      final restored = Inventory.fromJson(json, ItemData.allItems);
      expect(restored.capacity, 8);
      expect(restored.equippedWeaponId, 'pocket_knife');
      expect(restored.isItemEquipped('pocket_knife'), isTrue);
      expect(restored.getItemQuantity('first_aid_kit'), 2);
    });

    testWidgets('InventorySheet widget renders slots, effect chips, and interactive action buttons', (tester) async {
      final gameState = GameState();
      gameState.inventory.addItem(ItemData.gingerChai, quantity: 2);
      gameState.inventory.addItem(ItemData.pocketKnife);

      final combat = CombatSystem();
      combat.playerHealth = 50.0;
      combat.playerStamina = 50.0;

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventorySheet(
              gameState: gameState,
              combatSystem: combat,
              onClose: () {
                closed = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header is rendered
      expect(find.text("INVENTORY // AADI'S GEAR"), findsOneWidget);
      expect(find.text('CONSUMABLES'), findsOneWidget);

      // Tap on ginger chai slot (in grid)
      final firstSlot = find.byIcon(Icons.local_cafe_outlined).last;
      await tester.tap(firstSlot);
      await tester.pumpAndSettle();

      // Inspector details are visible
      expect(find.text('Steaming Ginger Chai'), findsOneWidget);
      expect(find.text('+15 HP'), findsOneWidget);
      expect(find.text('+45 STM'), findsOneWidget);
      expect(find.text('USE ITEM'), findsOneWidget);

      // Tap USE ITEM
      await tester.tap(find.text('USE ITEM'));
      await tester.pumpAndSettle();

      // Health and stamina recovered
      expect(combat.playerHealth, 65.0);
      expect(combat.playerStamina, 95.0);
      expect(gameState.inventory.getItemQuantity('ginger_chai'), 1);

      // Close button
      final closeButton = find.byIcon(Icons.close);
      await tester.tap(closeButton);
      expect(closed, isTrue);
    });
  });

  group('VAYAL Phase 39: Collectibles & World Memories Tests', () {
    test('CollectibleDatabase creates default exploration collectibles with diverse types', () {
      final list = CollectibleDatabase.createDefaultCollectibles();
      expect(list.length, greaterThanOrEqualTo(10));

      final types = list.map((c) => c.type).toSet();
      expect(types.contains(CollectibleType.photograph), isTrue);
      expect(types.contains(CollectibleType.document), isTrue);
      expect(types.contains(CollectibleType.hiddenLetter), isTrue);
      expect(types.contains(CollectibleType.memory), isTrue);
      expect(types.contains(CollectibleType.storyClue), isTrue);

      for (final c in list) {
        expect(c.id.isNotEmpty, isTrue);
        expect(c.title.isNotEmpty, isTrue);
        expect(c.description.isNotEmpty, isTrue);
        expect(c.memoryText.isNotEmpty, isTrue);
        expect(c.locationName.isNotEmpty, isTrue);
        expect(c.isCollected, isFalse);
      }
    });

    test('CollectibleManager tracks collection state, callbacks, and completion ratio', () {
      final manager = CollectibleManager();
      expect(manager.totalCount, 10);
      expect(manager.collectedCount, 0);
      expect(manager.completionRatio, 0.0);

      Collectible? callbackCollectible;
      manager.onCollectibleFound = (c) {
        callbackCollectible = c;
      };

      // Collect first item
      final item = manager.collect('photo_harbor_1996');
      expect(item, isNotNull);
      expect(item!.isCollected, isTrue);
      expect(callbackCollectible?.id, 'photo_harbor_1996');
      expect(manager.collectedCount, 1);
      expect(manager.completionRatio, closeTo(0.1, 0.001));

      // Collecting already collected item should not trigger callback again
      callbackCollectible = null;
      final recollected = manager.collect('photo_harbor_1996');
      expect(recollected, isNotNull);
      expect(callbackCollectible, isNull);
      expect(manager.collectedCount, 1);

      // Collect a second item
      manager.collect('letter_unsent_ravi');
      expect(manager.collectedCount, 2);
      expect(manager.completionRatio, closeTo(0.2, 0.001));

      final photos = manager.getCollectedByType(CollectibleType.photograph);
      expect(photos.length, 1);
      expect(photos.first.id, 'photo_harbor_1996');

      final letters = manager.getCollectedByType(CollectibleType.hiddenLetter);
      expect(letters.length, 1);
      expect(letters.first.id, 'letter_unsent_ravi');
    });

    test('CollectibleManager getNearbyCollectible finds items in radius and ignores collected ones', () {
      final manager = CollectibleManager();
      // 'photo_harbor_1996' is at (2.5, 0.0, -9.0)
      final nearPlayerPos = three.Vector3(3.0, 0.0, -8.5);
      final nearby = manager.getNearbyCollectible(nearPlayerPos, maxRadius: 3.0);
      expect(nearby, isNotNull);
      expect(nearby!.id, 'photo_harbor_1996');

      // Far player
      final farPlayerPos = three.Vector3(500.0, 0.0, 500.0);
      final noneNearby = manager.getNearbyCollectible(farPlayerPos, maxRadius: 3.0);
      expect(noneNearby, isNull);

      // Mark nearby as collected, then it should no longer be returned
      manager.collect('photo_harbor_1996');
      final afterCollected = manager.getNearbyCollectible(nearPlayerPos, maxRadius: 3.0);
      expect(afterCollected, isNull);
    });

    test('CollectibleManager serialization and restoration with collected IDs', () {
      final manager1 = CollectibleManager();
      manager1.collect('photo_harbor_1996');
      manager1.collect('doc_berth4_cargo');
      manager1.collect('memory_balan_bench');

      final savedIds = manager1.getCollectedIds();
      expect(savedIds, ['photo_harbor_1996', 'doc_berth4_cargo', 'memory_balan_bench']);

      final manager2 = CollectibleManager();
      expect(manager2.collectedCount, 0);

      manager2.restoreCollectedIds(savedIds);
      expect(manager2.collectedCount, 3);
      expect(manager2.getById('photo_harbor_1996')!.isCollected, isTrue);
      expect(manager2.getById('doc_berth4_cargo')!.isCollected, isTrue);
      expect(manager2.getById('memory_balan_bench')!.isCollected, isTrue);
      expect(manager2.getById('clue_brass_lighter')!.isCollected, isFalse);
    });
  });

  group('VAYAL Phase 40: Investigation & Evidence Board System Tests', () {
    test('InvestigationDatabase contains default clues and narrative leads', () {
      final clues = InvestigationDatabase.createDefaultClues();
      expect(clues.length, greaterThanOrEqualTo(10));

      final categories = clues.map((c) => c.category).toSet();
      expect(categories.contains(ClueCategory.photograph), isTrue);
      expect(categories.contains(ClueCategory.document), isTrue);
      expect(categories.contains(ClueCategory.physical), isTrue);
      expect(categories.contains(ClueCategory.forensics), isTrue);
      expect(categories.contains(ClueCategory.testimony), isTrue);

      final leads = InvestigationDatabase.createDefaultLeads();
      expect(leads.length, greaterThanOrEqualTo(3));
      final leadIds = leads.map((l) => l.id).toList();
      expect(leadIds.contains('lead_father_suspicious_death'), isTrue);
      expect(leadIds.contains('lead_harbour_smuggling_network'), isTrue);
      expect(leadIds.contains('lead_rahu_disappearance'), isTrue);
    });

    test('InvestigationManager discovers clues and synchronizes with inventory items and collectibles', () {
      final manager = InvestigationManager();
      expect(manager.discoveredClueCount, 0);

      // Manual discovery
      manager.discoverClue('clue_harbor_photo_1996');
      expect(manager.discoveredClueCount, 1);
      expect(manager.getClue('clue_harbor_photo_1996')?.isDiscovered, isTrue);

      // Synchronize with inventory items and collectibles
      manager.synchronizeWithWorld(
        inventoryItemIds: ['fathers_watch'],
        collectibleIds: ['doc_berth4_cargo'],
      );

      // fathers_watch maps to clue_fathers_watch
      expect(manager.getClue('clue_fathers_watch')?.isDiscovered, isTrue);
      // doc_berth4_cargo maps to clue_berth4_manifest
      expect(manager.getClue('clue_berth4_manifest')?.isDiscovered, isTrue);
      expect(manager.discoveredClueCount, 3);
    });

    test('InvestigationManager connects clues to deduce leads and triggers callbacks', () {
      final manager = InvestigationManager();

      // Discover required clues for father's death lead
      manager.discoverClue('clue_fathers_watch');
      manager.discoverClue('clue_police_memo_98');
      manager.discoverClue('clue_unsent_letter');

      InvestigationLead? solvedLead;
      manager.onLeadSolved = (lead) {
        solvedLead = lead;
      };

      // Connect correct clues
      final result = manager.connectClues({
        'clue_fathers_watch',
        'clue_police_memo_98',
        'clue_unsent_letter',
      });

      expect(result, isNotNull);
      expect(result!.id, 'lead_father_suspicious_death');
      expect(result.isSolved, isTrue);
      expect(solvedLead?.id, 'lead_father_suspicious_death');
      expect(manager.solvedLeadCount, 1);
      expect(manager.isLeadSolved('lead_father_suspicious_death'), isTrue);
    });

    test('InvestigationManager deduction fails with incorrect combinations', () {
      final manager = InvestigationManager();
      manager.discoverClue('clue_fathers_watch');
      manager.discoverClue('clue_syndicate_token');

      // Invalid combination
      final result = manager.connectClues({
        'clue_fathers_watch',
        'clue_syndicate_token',
      });

      expect(result, isNull);
      expect(manager.solvedLeadCount, 0);
    });

    test('InvestigationManager serialization and state restoration', () {
      final manager1 = InvestigationManager();
      manager1.discoverClue('clue_fathers_watch');
      manager1.discoverClue('clue_police_memo_98');
      manager1.discoverClue('clue_unsent_letter');
      manager1.connectClues({
        'clue_fathers_watch',
        'clue_police_memo_98',
        'clue_unsent_letter',
      });

      final json = manager1.toJson();
      expect(json['discoveredClueIds'], contains('clue_fathers_watch'));
      expect(json['solvedLeadIds'], contains('lead_father_suspicious_death'));

      final manager2 = InvestigationManager();
      manager2.restoreFromJson(json);

      expect(manager2.isClueDiscovered('clue_fathers_watch'), isTrue);
      expect(manager2.isClueDiscovered('clue_police_memo_98'), isTrue);
      expect(manager2.isClueDiscovered('clue_unsent_letter'), isTrue);
      expect(manager2.isLeadSolved('lead_father_suspicious_death'), isTrue);
      expect(manager2.solvedLeadCount, 1);
    });

    testWidgets('InvestigationBoardDialog renders evidence items, leads, collectibles and connects clues', (tester) async {
      final invManager = InvestigationManager();
      final colManager = CollectibleManager();

      invManager.discoverClue('clue_fathers_watch');
      invManager.discoverClue('clue_police_memo_98');
      invManager.discoverClue('clue_unsent_letter');
      colManager.collect('photo_harbor_1996');

      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InvestigationBoardDialog(
              investigationManager: invManager,
              collectibleManager: colManager,
              onClose: () {
                closed = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header is rendered
      expect(find.text('INVESTIGATION DOSSIER // EVIDENCE BOARD'), findsOneWidget);
      expect(find.text('EVIDENCE / CLUES'), findsOneWidget);
      expect(find.text('DEDUCTIONS & LEADS'), findsOneWidget);
      expect(find.text('MEMORIES & COLLECTIBLES'), findsOneWidget);

      // Clues in Evidence tab are visible
      expect(find.text('Shattered Mechanical Watch'), findsOneWidget);
      expect(find.text('Police Case Closure Memo #409'), findsOneWidget);
      expect(find.text('Ravi\'s Unsent Confession Letter'), findsOneWidget);

      // Select clues to connect
      await tester.tap(find.text('Shattered Mechanical Watch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Police Case Closure Memo #409'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ravi\'s Unsent Confession Letter'));
      await tester.pumpAndSettle();

      // Deduce button shows 3 selected
      expect(find.text('CONNECT EVIDENCE // DEDUCE (3 SELECTED)'), findsOneWidget);

      // Tap deduce button
      await tester.tap(find.text('CONNECT EVIDENCE // DEDUCE (3 SELECTED)'));
      await tester.pumpAndSettle();

      // Lead is solved and breakthrough announcement appears
      expect(invManager.isLeadSolved('lead_father_suspicious_death'), isTrue);
      expect(find.text('★ NEW BREAKTHROUGH UNLOCKED: RAVI MENON WAS MURDERED AT BERTH 4'), findsOneWidget);

      // Switch to Deductions & Leads tab
      await tester.tap(find.text('DEDUCTIONS & LEADS'));
      await tester.pumpAndSettle();
      expect(find.text('THE TRUTH OF RAVI MENON\'S DEATH'), findsOneWidget);

      // Switch to Memories & Collectibles tab
      await tester.tap(find.text('MEMORIES & COLLECTIBLES'));
      await tester.pumpAndSettle();
      expect(find.text('The Harbour Brotherhood (1996)'), findsOneWidget);

      // Tap close button
      final closeBtn = find.byIcon(Icons.close);
      await tester.tap(closeBtn);
      expect(closed, isTrue);
    });
  });
}








