import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as three;

import 'audio/audio_event.dart';
import 'audio/audio_manager.dart';
import 'cinematics/cinematic_database.dart';
import 'cinematics/cinematic_manager.dart';
import 'combat/combat_system.dart';
import 'dialogue/dialogue_manager.dart';
import 'missions/mission_manager.dart';
import 'npc/npc_controller.dart';
import 'performance/performance_manager.dart';
import 'player/player.dart';
import 'player/player_camera.dart';
import 'player/player_controller.dart';
import 'save/save_manager.dart';
import 'story/ending_manager.dart';
import 'story/story_act.dart';
import 'story/story_act_manager.dart';
import 'story/story_choice_system.dart';
import 'systems/game_state.dart';
import 'systems/interaction_system.dart';
import 'systems/wanted_system.dart';
import 'vehicles/vehicle.dart';
import 'vehicles/vehicle_controller.dart';
import 'vehicles/vehicle_radio.dart';
import 'vehicles/police_pursuit_manager.dart';
import 'vehicles/vehicle_world_manager.dart';
import 'ai/police_ai.dart';
import 'world/world.dart';
import 'world/world_object.dart';
import 'world/world_region.dart';
import 'time/game_time_manager.dart';
import 'time/time_of_day_period.dart';
import 'weather/weather_manager.dart';
import 'weather/weather_state.dart';
import 'world/world_life_manager.dart';
import 'phone/phone_manager.dart';
import 'quests/side_quest_manager.dart';
import 'combat/boss_encounter.dart';
import 'combat/enemy_ai.dart';
import 'stealth/stealth_system.dart';
import 'disguise/disguise.dart';
import 'disguise/disguise_manager.dart';
import 'infiltration/lock_data.dart';
import '../ui/phone/phone_overlay.dart';
import '../ui/hud/boss_hud.dart';
import '../ui/hud/stealth_hud.dart';
import '../ui/hud/disguise_hud.dart';
import '../ui/hud/vehicle_hud.dart';
import '../ui/infiltration/lockpicking_dialog.dart';
import 'collectibles/collectible.dart';
import 'collectibles/collectible_manager.dart';
import 'investigation/investigation_manager.dart';
import 'cinematics/cutscene_trigger.dart';
import '../ui/investigation/investigation_board_dialog.dart';

import '../data/inventory/item_data.dart';
import '../ui/cinematics/cinematic_overlay.dart';
import '../ui/dialogue/dialogue_view.dart';
import '../ui/hud/clock_weather_hud.dart';
import '../ui/hud/performance_hud.dart';
import '../ui/hud/virtual_controls.dart';
import '../ui/hud/wanted_hud.dart';
import '../ui/hud/weapon_hud.dart';
import '../ui/inventory/inventory_sheet.dart';
import '../ui/menu/credits_screen.dart';
import '../ui/menu/main_menu_screen.dart';
import '../ui/menu/missions_screen.dart';
import '../ui/menu/pause_menu_dialog.dart';
import '../ui/menu/settings_dialog.dart';
import '../ui/menu/world_map_screen.dart';
import '../ui/mission/mission_hud.dart';
import '../ui/save/save_load_dialog.dart';
import '../ui/story/ending_screen.dart';

/// Concrete interactable implementation for world objects & triggers.
class WorldInteractable implements Interactable {
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

  final InteractionResult Function(InteractionContext context) onExecute;

  WorldInteractable({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.interactionRadius = 2.8,
    required this.prompt,
    required this.onExecute,
  });

  @override
  bool canInteract(InteractionContext context) => true;

  @override
  InteractionResult onInteract(InteractionContext context) => onExecute(context);
}

/// Main 3D Game screen coordinating the ThreeJS viewport,
/// Player physics, Camera controls, Combat actions, Vehicles, Wanted Police system,
/// NPCs, Dialogue System, Story Missions, Inventory, and Currency.
class VayalGameView extends StatefulWidget {
  final int? autoLoadSlotId;
  final VoidCallback? onExitToMainMenu;

  /// Load/Continue sessions skip the "CHAPTER 1" intro card since the
  /// player is resuming mid-story.
  const VayalGameView({
    super.key,
    this.autoLoadSlotId,
    this.onExitToMainMenu,
  });

  @override
  State<VayalGameView> createState() => _VayalGameViewState();
}

class _VayalGameViewState extends State<VayalGameView> {
  late final three.ThreeJS threeJs;
  late final World world;
  late final Player player;
  late final PlayerCamera playerCamera;
  late final PlayerController playerController;
  late final NpcController npcController;
  late final DialogueManager dialogueManager;
  late final MissionManager missionManager;
  late final GameState gameState;
  late final InteractionSystem interactionSystem;

  // Phase 11 & Phase 30: Combat & Advanced Enemy AI
  late final CombatSystem combatSystem;
  late final EnemyAI syndicateThug;
  BossEncounter? activeBossEncounter;

  // Phase 31: Stealth & Infiltration System
  late final StealthSystem stealthSystem;
  EnemyAI? _takedownCandidate;

  // Phase 32: Disguise & Social Stealth System
  late final DisguiseManager disguiseManager;

  // Phase 12 & Phase 34: Vehicle System & Advanced Pursuits
  late final Vehicle vehicle;
  late final VehicleController vehicleController;
  late final VehicleRadio vehicleRadio;
  late final PolicePursuitManager pursuitManager;
  double _virtualThrottle = 0.0;
  bool _virtualHandbrake = false;

  // Phase 35: Advanced Police AI System
  late final PoliceManager policeManager;

  // Phase 36: Multi-Vehicle World System
  late final VehicleWorldManager vehicleWorldManager;

  // Phase 13: Police / Wanted System
  late final WantedSystem wantedSystem;

  // Phase 14: Story Choice System
  late final StoryChoiceSystem storyChoiceSystem;

  // Phase 15: Open World Region Tracking
  WorldRegion _currentRegion = WorldRegion.village;
  String? _regionBannerTitle;

  // Phase 16: Story Act Manager
  late final StoryActManager storyActManager;
  String? _actBannerTitle;

  // Phase 17: Ending Manager
  late final EndingManager endingManager;
  bool _showEndingScreen = false;

  // Phase 18: Save & Load System
  late final SaveManager saveManager;

  // Phase 19: Audio System
  late final AudioManager audioManager;

  // Phase 20: Cinematic Manager
  late final CinematicManager cinematicManager;

  // Phase 21: UI Screens
  bool _showMapScreen = false;
  bool _showMissionsScreen = false;
  bool _isGamePaused = false;
  bool _showMainMenu = false;

  // Phase 22: Performance Manager
  late final PerformanceManager performanceManager;
  bool _showPerformanceHud = false;

  // Phase 23, 24, 25: World Life, Day/Night, and Weather Systems
  late final GameTimeManager timeManager;
  late final WeatherManager weatherManager;
  late final WorldLifeManager worldLifeManager;

  // Phase 26: Map Waypoint
  three.Vector3? _customDestinationWaypoint;

  // Phase 27: Phone System
  late final PhoneManager phoneManager;
  bool _showPhoneScreen = false;

  // Phase 28: Quest / Side Story System
  late final SideQuestManager sideQuestManager;
  String? _sideQuestNotification;

  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  bool isReady = false;
  bool isSprinting = false;
  bool showIntroCard = true;
  bool showInventory = false;

  // Phase 39 & Phase 40: Collectibles & Investigation System
  late final CollectibleManager collectibleManager;
  late final InvestigationManager investigationManager;
  bool showInvestigationBoard = false;

  // Active interaction tracking
  Interactable? _nearbyInteractable;
  String? _interactionMessage;
  String? _completedMissionNotification;

  // Track touch vs keyboard input
  Offset _virtualMoveInput = Offset.zero;

  @override
  void initState() {
    super.initState();
    world = World();
    player = Player();
    npcController = NpcController();
    dialogueManager = DialogueManager();
    missionManager = MissionManager();
    gameState = GameState();
    interactionSystem = InteractionSystem();

    // Initialize Combat, Vehicle, Wanted, Story, Save, and Audio systems
    combatSystem = CombatSystem();
    wantedSystem = WantedSystem();
    vehicleController = VehicleController();
    storyChoiceSystem = StoryChoiceSystem();
    storyActManager = StoryActManager();
    endingManager = EndingManager();
    saveManager = SaveManager();
    audioManager = AudioManager();
    cinematicManager = CinematicManager();
    performanceManager = PerformanceManager();

    // Phase 23, 24, 25: World Life, Day/Night, and Weather Systems
    timeManager = GameTimeManager(initialTime: 18.0);
    weatherManager = WeatherManager(initialWeather: WeatherState.clear);
    worldLifeManager = WorldLifeManager();

    // Phase 27: Phone System & Phase 28: Side Quest System
    phoneManager = PhoneManager();
    sideQuestManager = SideQuestManager();

    // Phase 39 & Phase 40: Collectibles & Investigation System
    collectibleManager = CollectibleManager();
    investigationManager = InvestigationManager();

    // Synchronize initial inventory with clues
    investigationManager.synchronizeWithWorld(
      inventoryItemIds: gameState.inventory.slots.map((s) => s.item.id).toList(),
      collectibleIds: collectibleManager.getCollectedIds(),
    );

    gameState.inventory.onItemUsed = (item, effect) {
      investigationManager.synchronizeWithWorld(
        inventoryItemIds: gameState.inventory.slots.map((s) => s.item.id).toList(),
        collectibleIds: collectibleManager.getCollectedIds(),
      );
    };

    collectibleManager.onCollectibleFound = (col) {
      audioManager.playUi(AudioEvent.missionObjectiveTick);
      if (col.clueId != null) {
        investigationManager.discoverClue(col.clueId!);
      }
      if (mounted) {
        setState(() {
          _interactionMessage = 'COLLECTIBLE DISCOVERED: ${col.title}';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _interactionMessage = null);
        });
      }
    };

    investigationManager.onLeadSolved = (lead) {
      audioManager.playUi(AudioEvent.missionCompleteFanfare);
      if (lead.storyFlagKey != null) {
        gameState.setFlag(lead.storyFlagKey!, true);
      }
      if (mounted) {
        setState(() {
          _interactionMessage = 'CASE BREAKTHROUGH: ${lead.breakthroughTitle}';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _interactionMessage = null);
        });
      }
    };

    // Phase 31: Stealth & Infiltration System
    stealthSystem = StealthSystem();
    stealthSystem.onStealthTakedown = (enemy) {
      audioManager.playSfx(AudioEvent.combatPunchHeavy);
      gameState.earnMoney(150);
      gameState.addReputation(15);
      if (mounted) {
        setState(() {
          _interactionMessage = 'SILENT TAKEDOWN EXECUTED: ${enemy.name} (+₹150, +15 REP)';
        });
      }
    };

    // Phase 32: Disguise & Social Stealth System
    disguiseManager = DisguiseManager();
    disguiseManager.onTrespassingStarted = (zone) {
      if (mounted) {
        setState(() {
          _interactionMessage = 'TRESPASSING: ${zone.name.toUpperCase()}';
        });
      }
      wantedSystem.reportCrime(CrimeType.trespassing, customDescription: 'Trespassing in ${zone.name}');
    };

    disguiseManager.onDisguiseBlown = () {
      if (mounted) {
        setState(() {
          _interactionMessage = 'COVER BLOWN! GUARDS ARE ALERTED!';
        });
      }
    };

    phoneManager.onIncomingCallTriggered = (call) {
      audioManager.playUi(AudioEvent.uiClick);
      if (mounted) setState(() {});
    };

    phoneManager.onCallAnswered = (call) {
      audioManager.playUi(AudioEvent.uiClick);
      if (mounted) setState(() {});
    };

    phoneManager.onCallEnded = (call) {
      if (mounted) setState(() {});
    };

    phoneManager.onMessageReceived = (msg) {
      audioManager.playUi(AudioEvent.uiClick);
      if (mounted) setState(() {});
    };

    phoneManager.onStoryTriggerFired = (triggerId) {
      sideQuestManager.startQuest(triggerId);
      if (mounted) setState(() {});
    };

    sideQuestManager.onQuestStarted = (quest) {
      phoneManager.pushNotification('SIDE STORY STARTED', quest.title);
      if (mounted) {
        setState(() {
          _sideQuestNotification = 'SIDE STORY STARTED // ${quest.title}';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _sideQuestNotification = null);
        });
      }
    };

    sideQuestManager.onQuestStepAdvanced = (quest, step) {
      if (mounted) {
        setState(() {
          _sideQuestNotification = 'OBJECTIVE COMPLETE // ${step.instruction}';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _sideQuestNotification = null);
        });
      }
    };

    sideQuestManager.onQuestCompleted = (quest) {
      audioManager.playUi(AudioEvent.missionCompleteFanfare);
      phoneManager.pushNotification('SIDE STORY COMPLETE', '₹${quest.cashReward} awarded: ${quest.title}');
      if (mounted) {
        setState(() {
          _sideQuestNotification = 'SIDE STORY RESOLVED // ${quest.title} (+₹${quest.cashReward})';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _sideQuestNotification = null);
        });
      }
    };

    // Phase 29: Weapon & Firearms combat audio and state synchronization
    combatSystem.onWeaponFired = (w) {
      audioManager.playSfx(w.soundEvent, position: player.position);
      if (mounted) setState(() {});
    };

    combatSystem.onWeaponReloaded = (w) {
      audioManager.playSfx(AudioEvent.combatReload, position: player.position);
      if (mounted) setState(() {});
    };

    combatSystem.onWeaponSwitched = (w) {
      audioManager.playUi(AudioEvent.uiClick);
      if (mounted) setState(() {});
    };

    timeManager.onPeriodChanged = (oldPeriod, newPeriod) {
      if (!weatherManager.isRaining) {
        audioManager.playAmbient(newPeriod.ambientSound);
      }
      if (mounted) setState(() {});
    };

    weatherManager.onWeatherChanged = (oldWeather, newWeather) {
      if (mounted) setState(() {});
    };

    endingManager.onEndingTriggered = () {
      if (mounted) setState(() => _showEndingScreen = true);
    };
    endingManager.onEndingCompleted = () {
      if (mounted) setState(() => _showEndingScreen = false);
    };

    // Story Act transition callback
    storyActManager.onActChanged = (newAct, actData) {
      audioManager.playUi(AudioEvent.actTitleGong);
      if (mounted) {
        setState(() {
          _actBannerTitle = '${actData.romanTitle} : ${actData.title}';
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _actBannerTitle = null);
        });
      }
    };

    // Open World region transition callback
    world.chunkManager.onRegionChanged = (oldRegion, newRegion) {
      if (mounted) {
        final regData = RegionData.registry[newRegion]!;
        setState(() {
          _currentRegion = newRegion;
          _regionBannerTitle = regData.title;
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _regionBannerTitle = null);
        });
      }
    };

    // Phase 36: Multi-Vehicle World System
    vehicleWorldManager = VehicleWorldManager();
    vehicle = vehicleWorldManager.vehicles.first;

    // Phase 34: In-Car Radio & Police Pursuit System
    vehicleRadio = VehicleRadio();
    pursuitManager = PolicePursuitManager();

    // Phase 35: Kerala Police AI System
    policeManager = PoliceManager();
    policeManager.hookWantedSystem(wantedSystem);
    pursuitManager.onPitManeuverLanded = (dmg) {
      audioManager.playVehicleSfx(AudioEvent.vehicleCrash, position: vehicle.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'CRUISER PIT MANEUVER! Spun out (-${dmg.toInt()} HP)';
        });
      }
    };
    pursuitManager.onSpikeStripImpact = () {
      audioManager.playVehicleSfx(AudioEvent.vehicleCrash, position: vehicle.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'SPIKE STRIP HIT! Front tires punctured!';
        });
      }
    };

    // Hook vehicle impact events
    vehicleController.onPedestrianHit = (npc, speed) {
      wantedSystem.reportCrime(
        CrimeType.vehicleHitAndRun,
        customDescription: 'Hit pedestrian ${npc.name} at ${speed.toStringAsFixed(1)} m/s',
      );
      audioManager.playVehicleSfx(AudioEvent.vehicleCrash, position: vehicle.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'HIT-AND-RUN: Struck ${npc.name}! Police alerted!';
        });
      }
    };

    vehicleController.onVehicleCrashed = (veh, dmg) {
      audioManager.playVehicleSfx(AudioEvent.vehicleCrash, position: vehicle.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'VEHICLE CRASH (-${dmg.toInt()} HP)';
        });
      }
    };

    // Hook combat events
    combatSystem.onHitLanded = (target, dmg) {
      audioManager.playCombatSfx(AudioEvent.combatPunchLight, position: target.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'LANDED HIT: ${target.name} (-${dmg.amount.toInt()} HP)';
        });
      }
    };

    combatSystem.onPlayerDamaged = (dmg) {
      audioManager.playCombatSfx(AudioEvent.combatPain, position: player.position);
      if (mounted) {
        setState(() {
          _interactionMessage = 'AADI INJURED (-${dmg.amount.toInt()} HP)';
        });
      }
    };

    // Hook wanted system
    wantedSystem.onWantedLevelChanged = (oldLvl, newLvl) {
      if (mounted) setState(() {});
    };
    wantedSystem.onPursuitStatusChanged = (status) {
      if (mounted) setState(() {});
    };
    wantedSystem.onPursuitEvaded = () {
      if (mounted) {
        setState(() {
          _interactionMessage = 'PURSUIT EVADED: Police lost track.';
        });
      }
    };

    // Hook dialogue manager events
    dialogueManager.onNodeChanged = (_) {
      audioManager.playUi(AudioEvent.uiDialogueNext);
      if (mounted) setState(() {});
    };
    dialogueManager.onDialogueClosed = () {
      if (mounted) setState(() {});
    };
    dialogueManager.onStoryFlagChanged = (flagKey, flagValue) {
      gameState.setFlag(flagKey, flagValue);
      if (flagKey == 'ending_walk_away') {
        endingManager.triggerEnding(EndingType.walkAway, gameState);
        audioManager.playMusic(AudioEvent.themeEndingWalkAway);
      } else if (flagKey == 'ending_revenge') {
        endingManager.triggerEnding(EndingType.revenge, gameState);
        audioManager.playMusic(AudioEvent.themeEndingRevenge);
      } else if (flagKey == 'ending_expose') {
        endingManager.triggerEnding(EndingType.exposeEverything, gameState);
        audioManager.playMusic(AudioEvent.themeEndingExpose);
      }
    };
    dialogueManager.onAlignmentDelta = (repDelta, policeDelta, crimDelta) {
      if (repDelta != 0) gameState.addReputation(repDelta);
      if (policeDelta != 0) {
        storyChoiceSystem.policeTrust =
            (storyChoiceSystem.policeTrust + policeDelta).clamp(0, 100);
      }
      if (crimDelta != 0) {
        storyChoiceSystem.criminalReputation =
            (storyChoiceSystem.criminalReputation + crimDelta).clamp(0, 100);
      }
      gameState.storyFlagManager.setInt('police_trust', storyChoiceSystem.policeTrust);
      gameState.storyFlagManager
          .setInt('criminal_reputation', storyChoiceSystem.criminalReputation);
    };
    dialogueManager.onMissionTriggered = (missionEventId) {
      if (mounted) {
        if (missionEventId == 'mission_01_done') {
          missionManager.notifyNpcTalked('meera');
        }
      }
    };

    // Hook mission manager events
    missionManager.onMissionStarted = (mission) {
      // Phase 43: Fire cutscene triggers on mission start
      gameState.cutsceneTriggers.checkMissionStart(mission.id);
      final seq = CinematicDatabase.getSequence(
        gameState.cutsceneTriggers.firedIds().last,
      );
      if (seq != null) {
        cinematicManager.playSequence(seq);
      }
    };
    missionManager.onObjectiveCompleted = (mission, obj) {
      audioManager.playUi(AudioEvent.missionObjectiveTick);
      if (mounted) {
        setState(() {
          _interactionMessage = 'OBJECTIVE COMPLETE: ${obj.description}';
        });
      }
    };
    missionManager.onMissionCompleted = (mission) {
      audioManager.playUi(AudioEvent.missionCompleteFanfare);

      // Phase 43: Fire cutscene on mission completion
      gameState.cutsceneTriggers.checkMissionComplete(mission.id);

      if (mounted) {
        gameState.earnMoney(mission.reward.money);
        gameState.addReputation(mission.reward.reputation);

        // Apply story flags from mission reward
        for (final entry in mission.reward.storyFlags.entries) {
          gameState.setFlag(entry.key, entry.value);
        }

        // Phase 16 updated: Act progression mapped to new 30-mission structure
        if (mission.id == 'mission_06_old_town_recon') {
          storyActManager.setAct(StoryAct.act2Ghosts, gameState: gameState, missionManager: missionManager);
          gameState.cutsceneTriggers.checkActTransition('act2');
        } else if (mission.id == 'mission_12_the_shipping_ledger') {
          storyActManager.setAct(StoryAct.act3Blood, gameState: gameState, missionManager: missionManager);
          gameState.cutsceneTriggers.checkActTransition('act3');
        } else if (mission.id == 'mission_18_the_burner_phone') {
          storyActManager.setAct(StoryAct.act4TheTruth, gameState: gameState, missionManager: missionManager);
          gameState.cutsceneTriggers.checkActTransition('act4');
        } else if (mission.id == 'mission_24_imran_help') {
          storyActManager.setAct(StoryAct.act5Vayal, gameState: gameState, missionManager: missionManager);
          gameState.cutsceneTriggers.checkActTransition('act5');
        }

        // Phase 18: Auto-save checkpoint upon mission completion
        final snap = saveManager.createSaveSnapshot(
          slotId: -1,
          label: 'Checkpoint: ${mission.title}',
          player: player,
          gameState: gameState,
          chunkManager: world.chunkManager,
          choiceSystem: storyChoiceSystem,
          actManager: storyActManager,
          missionManager: missionManager,
          vehicleController: vehicleController,
          collectibleManager: collectibleManager,
          investigationManager: investigationManager,
          isCheckpoint: true,
        );
        saveManager.saveGame(-1, snap);

        setState(() {
          _completedMissionNotification = mission.title;
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _completedMissionNotification = null;
            });
          }
        });
      }
    };

    // Faithful start: Chapter intro card only for a fresh begin.
    if (widget.autoLoadSlotId != null) {
      showIntroCard = false;
    } else {
      // Fade out opening cinematic title card after 4.5 seconds
      Future.delayed(const Duration(milliseconds: 4500), () {
        if (mounted) {
          setState(() {
            showIntroCard = false;
          });
        }
      });
    }

    threeJs = three.ThreeJS(
      onSetupComplete: () {
        setState(() {
          isReady = true;
        });
      },
      setup: _setupScene,
    );
  }

  Future<void> _setupScene() async {
    // 1. Initialize Scene
    threeJs.scene = three.Scene();

    // 2. Setup Camera
    final aspect = threeJs.width / threeJs.height;
    playerCamera = PlayerCamera(aspectRatio: aspect);
    threeJs.camera = playerCamera.camera;

    // 3. Initialize Controller with WorldManager Collisions
    playerController = PlayerController(
      player: player,
      camera: playerCamera,
      worldManager: world.manager,
    );

    // 4. Setup World (Terrain, Roads, Houses, Shops, Park, Lamps, Walls)
    world.initialize(threeJs.scene);

    // 5. Populate and Register NPCs in Veyrapuram
    npcController.initializeWorldNpcs();
    for (final npc in npcController.npcs) {
      threeJs.scene.add(npc.group);

      // Register with WorldManager
      world.manager.registerObject(WorldObject(
        id: 'npc_${npc.id}',
        name: npc.name,
        mesh: npc.group,
        bounds: WorldBounds.fromCenter(
          cx: npc.position.x,
          cz: npc.position.z,
          width: npc.radius * 2,
          depth: npc.radius * 2,
        ),
        isSolid: false,
        isInteractive: true,
        interactionRadius: npc.interactionRadius,
        interactionPrompt: 'Talk to ${npc.name}',
      ));

      // Register with Universal InteractionSystem
      interactionSystem.register(WorldInteractable(
        id: 'npc_${npc.id}',
        name: npc.name,
        type: InteractableType.npc,
        position: npc.position,
        interactionRadius: npc.interactionRadius,
        prompt: 'Talk to ${npc.name}',
        onExecute: (context) {
          missionManager.notifyNpcTalked(npc.id);
          final treeId = _getTreeIdForNpc(npc.id);
          dialogueManager.startDialogueById(treeId);
          return InteractionResult.success('Speaking with ${npc.name}');
        },
      ));

      // Hook Combat targets for NPCs
      if (npc.id == 'raghav') {
        // Officer Raghav
        final raghavTarget = CombatTarget(
          id: 'combat_raghav',
          name: 'Officer Raghav',
          position: npc.position,
          health: 120.0,
        );
        raghavTarget.onDamageTaken = (dmg) {
          wantedSystem.reportCrime(
            CrimeType.assaultOfficer,
            customDescription: 'Assaulted Officer Raghav!',
          );
        };
        combatSystem.activeTargets.add(raghavTarget);
      } else if (npc.id == 'balan') {
        // Civilian Balan
        final balanTarget = CombatTarget(
          id: 'combat_balan',
          name: 'Balan',
          position: npc.position,
          health: 80.0,
        );
        balanTarget.onDamageTaken = (dmg) {
          wantedSystem.reportCrime(
            CrimeType.assaultCivilian,
            customDescription: 'Assaulted Balan at chai stall!',
          );
        };
        combatSystem.activeTargets.add(balanTarget);
      }
    }

    // 6. Spawn Syndicate Combat Target (Karan in the park alley)
    _setupSyndicateTarget();

    // 7. Spawn World Vehicles (Cars, Bikes, Vans, Trucks, Police Cruisers)
    vehicleWorldManager.initialize(threeJs.scene, interactionSystem);

    // Phase 35: Register Kerala Police Officers in Scene and Combat System
    for (final officer in policeManager.officers) {
      threeJs.scene.add(officer.group);
      combatSystem.activeTargets.add(officer);
    }

    // 8. Register Interactive World Objects (Door, Tea Stall Shop, Document Pickup)
    _registerWorldInteractables();

    // 9. Spawn Aadi at designated Arrival point on south road
    player.setPosition(
      world.manager.spawnPointArrival.x,
      world.manager.spawnPointArrival.y,
      world.manager.spawnPointArrival.z,
    );
    threeJs.scene.add(player.group);

    // 10. Point camera at Aadi
    playerCamera.resetToTarget(player.position);

    // 11. Start Background Theme & Environmental Ambience
    audioManager.playMusic(AudioEvent.themeHome);
    audioManager.playAmbient(AudioEvent.ambientVillageRain);

    // Phase 22: Build spatial broadphase collision grid
    performanceManager.buildSpatialGrid(world.manager.objects);

    // Phase 25: Initialize 3D Rain & Weather Particles in Scene
    weatherManager.initializeScene(threeJs.scene);

    // Phase 23: Initialize World Life Traffic & Pedestrians in Scene
    worldLifeManager.initialize(threeJs.scene);

    // Phase 20: Play opening cinematic cutscene
    cinematicManager.playSequence(CinematicDatabase.introArrival);

    // 12. Core Game Loop Tick
    threeJs.addAnimationEvent((double dt) {
      // Keep camera aspect ratio in sync with window/viewport resizing
      if (threeJs.height > 0) {
        final currentAspect = threeJs.width / threeJs.height;
        if ((playerCamera.camera.aspect - currentAspect).abs() > 0.001) {
          playerCamera.updateAspectRatio(currentAspect);
        }
      }

      // Phase 22: Record frame metrics
      performanceManager.recordFrame(dt);

      if (_isGamePaused) return;

      // Phase 20: Cinematic sequencer camera update
      if (cinematicManager.isPlaying) {
        cinematicManager.update(dt, playerCamera);
        timeManager.update(
          dt: dt,
          scene: threeJs.scene,
          sun: world.sunLight,
          ambient: world.ambientLight,
        );
        weatherManager.update(
          dt: dt,
          scene: threeJs.scene,
          playerPosition: playerCamera.camera.position,
        );
        audioManager.updateListenerPosition(playerCamera.camera.position);
        return;
      }

      _processKeyboardInputs();

      if (vehicleController.isDriving) {
        // Vehicle Drive Physics Tick
        double throttle = _virtualThrottle;
        if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
            _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
          throttle = 1.0;
        } else if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
            _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
          throttle = -1.0;
        }

        double steer = 0.0;
        if (_virtualMoveInput.dx.abs() > 0.05) {
          steer = _virtualMoveInput.dx;
        } else {
          if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
              _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
            steer = -1.0;
          } else if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
              _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
            steer = 1.0;
          }
        }

        final handbrake = _virtualHandbrake || _pressedKeys.contains(LogicalKeyboardKey.space);

        vehicleController.update(
          dt: dt,
          throttleInput: throttle,
          steerInput: steer,
          handbrake: handbrake,
          npcs: npcController.npcs,
          camera: playerCamera,
        );

        // Phase 34: Pursuit Cruisers & Roadblocks Tick
        pursuitManager.update(
          dt: dt,
          playerVehicle: vehicleController.activeVehicle ?? vehicle,
          wantedSystem: wantedSystem,
          scene: threeJs.scene,
        );
      } else {
        // Clean up pursuit cruisers if player not driving and wanted cleared
        if (wantedSystem.wantedLevel == 0 && pursuitManager.activeCruisers.isNotEmpty) {
          pursuitManager.clear(threeJs.scene);
        }
        // On Foot Player Simulation Tick
        playerController.update(dt);
        playerCamera.update(dt, player.position);

        combatSystem.update(dt);

        player.updateAnimation(
          dt,
          playerController.currentSpeed,
          playerController.isGrounded,
          isLightAttacking: combatSystem.currentAction == CombatAction.lightAttack,
          isHeavyAttacking: combatSystem.currentAction == CombatAction.heavyAttack,
          isBlocking: combatSystem.isBlocking,
          isDodging: combatSystem.currentAction == CombatAction.dodging,
          isKnockedDown: combatSystem.isPlayerKnockedDown,
          isCrouching: playerController.isCrouching,
        );
      }

      // Wanted & Police Simulation Tick
      final activePos = vehicleController.isDriving
          ? (vehicleController.activeVehicle?.position ?? vehicle.position)
          : player.position;

      // Phase 35: Advanced Kerala Police AI (Patrol, Incident Response, Chase, Search)
      policeManager.update(
        dt: dt,
        playerPos: activePos,
        wantedSystem: wantedSystem,
        combatSystem: combatSystem,
        scene: threeJs.scene,
      );

      // Phase 36: Vehicle World Manager (Distance-based LOD & Mobile Culling)
      vehicleWorldManager.update(dt, activePos);

      // Phase 24: Day/Night Cycle & Scalable Clock progression
      timeManager.update(
        dt: dt,
        scene: threeJs.scene,
        sun: world.sunLight,
        ambient: world.ambientLight,
      );

      // Phase 25: Weather simulation & 3D rain streaks
      weatherManager.update(
        dt: dt,
        scene: threeJs.scene,
        playerPosition: activePos,
      );

      // Phase 23: Traffic AI and ambient pedestrian simulation
      worldLifeManager.update(
        dt: dt,
        timeManager: timeManager,
        playerPosition: activePos,
      );

      // Phase 30: Update Syndicate Enemy AI & Boss Encounter
      syndicateThug.updateAI(
        dt: dt,
        playerPos: activePos,
        combatSystem: combatSystem,
      );

      activeBossEncounter?.update(
        dt: dt,
        playerPos: activePos,
        combatSystem: combatSystem,
        scene: threeJs.scene,
      );

      // Phase 31: Stealth, Vision Cones & Awareness Simulation Tick
      final activeEnemiesList = <EnemyAI>[
        syndicateThug,
        if (activeBossEncounter != null) activeBossEncounter!.boss,
        if (activeBossEncounter != null) ...activeBossEncounter!.reinforcements,
      ];

      stealthSystem.update(
        dt: dt,
        playerPos: activePos,
        playerSpeed: playerController.currentSpeed,
        activeEnemies: activeEnemiesList,
        isShooting: combatSystem.currentAction == CombatAction.shooting,
        isMeleeAttacking: combatSystem.isAttacking,
      );

      _takedownCandidate = stealthSystem.findTakedownCandidate(
        playerPos: activePos,
        activeEnemies: activeEnemiesList,
      );

      // Phase 32: Social Stealth & Disguise Simulation Tick
      disguiseManager.update(
        dt: dt,
        playerPos: activePos,
        playerSpeed: playerController.currentSpeed,
        isArmed: combatSystem.isAiming || combatSystem.equippedWeapon.isFirearm,
        isCrouching: playerController.isCrouching,
        nearbyEnemies: activeEnemiesList,
      );

      // Update NPC AI behaviors, patrols, and awareness
      npcController.update(dt, activePos);

      // Check Mission Location Objectives
      missionManager.checkLocation(activePos);

      // Phase 28: Check optional character side quest location objectives
      sideQuestManager.checkLocationObjectives(
        activePos,
        gameState: gameState,
        inventory: gameState.inventory,
      );

      // Phase 15: Stream active chunks & detect current region
      world.chunkManager.update(activePos);

      // Phase 18: Advance save playtime counter
      saveManager.tickPlayTime(dt);

      // Phase 19: Update 3D Audio Listener position
      audioManager.updateListenerPosition(activePos);

      // Detect nearby interactive elements
      _checkNearbyInteractions();
    });

    // Auto-load a saved session (Continue / Load Game) once all systems exist.
    if (widget.autoLoadSlotId != null) {
      final snap = await saveManager.loadGame(widget.autoLoadSlotId!);
      if (snap != null) {
        saveManager.applySaveDataToGame(
          data: snap,
          player: player,
          gameState: gameState,
          chunkManager: world.chunkManager,
          choiceSystem: storyChoiceSystem,
          actManager: storyActManager,
          missionManager: missionManager,
          vehicleController: vehicleController,
          collectibleManager: collectibleManager,
          investigationManager: investigationManager,
        );
        if (mounted) {
          setState(() {
            _interactionMessage =
                'RESTORED: ${snap.metadata.label}';
          });
        }
      }
    }
  }

  void _setupSyndicateTarget() {
    syndicateThug = EnemyAI(
      id: 'thug_karan',
      name: 'Karan (Syndicate Enforcer)',
      position: three.Vector3(-14.0, 0.0, 15.0),
      archetype: EnemyArchetype.enforcer,
      health: 120.0,
      maxHealth: 120.0,
    );
    combatSystem.activeTargets.add(syndicateThug);
    threeJs.scene.add(syndicateThug.group);

    syndicateThug.onDamageTaken = (dmg) {
      if (mounted) {
        setState(() {
          _interactionMessage =
              'STRUCK KARAN: -${dmg.amount.toInt()} HP (${syndicateThug.health.toInt()}/120)';
        });
        if (syndicateThug.isDead) {
          gameState.earnMoney(250);
          gameState.addReputation(20);
          setState(() {
            _interactionMessage = 'DEFEATED SYNDICATE ENFORCER! (+₹250, +20 REP)';
          });
        }
      }
    };

    // Phase 30: Spawn Syndicate Boss Captain Velu
    activeBossEncounter = BossEncounter.createCaptainVelu(
      spawnPosition: three.Vector3(24.0, 0.0, -22.0),
    );
    combatSystem.activeTargets.add(activeBossEncounter!.boss);
    threeJs.scene.add(activeBossEncounter!.boss.group);

    activeBossEncounter!.onPhaseChanged = (phase, prompt) {
      if (mounted) {
        setState(() {
          _interactionMessage = prompt;
        });
      }
    };

    activeBossEncounter!.onBossDefeated = (title) {
      gameState.earnMoney(1500);
      gameState.addReputation(50);
      if (mounted) {
        setState(() {
          _interactionMessage = 'SYNDICATE BOSS $title DEFEATED! (+₹1500, +50 REP)';
        });
      }
    };
  }

  void _registerWorldInteractables() {
    // Front Entrance Door
    interactionSystem.register(WorldInteractable(
      id: 'aadi_house_door',
      name: "Aadi's House Door",
      type: InteractableType.door,
      position: three.Vector3(-16.0, 0, -8.0),
      interactionRadius: 3.5,
      prompt: 'Enter House',
      onExecute: (context) {
        missionManager.notifyObjectInteracted('aadi_house_door');
        if (dialogueManager.getFlag('mission_01_complete')) {
          return const InteractionResult.success(
              'Aadi enters his family home. The door clicks shut behind him.');
        } else {
          return const InteractionResult.failure(
              'Door is locked from inside. Speak to Meera on the veranda first.');
        }
      },
    ));

    // Balan Chai Stall (Shop Purchase)
    interactionSystem.register(WorldInteractable(
      id: 'tea_stall_counter',
      name: "Balan's Chai Stall",
      type: InteractableType.shop,
      position: three.Vector3(12.0, 0, 7.5),
      interactionRadius: 3.0,
      prompt: 'Buy Hot Ginger Chai (₹15)',
      onExecute: (context) {
        if (!worldLifeManager.isShopOpen('tea_stall_counter', timeManager.timeOfDay)) {
          return InteractionResult.failure(
            worldLifeManager.getShopPrompt('tea_stall_counter', '', timeManager.timeOfDay),
          );
        }
        if (gameState.spendMoney(15)) {
          gameState.inventory.addItem(ItemData.gingerChai);
          return const InteractionResult.success(
              'Purchased hot ginger chai! Added to inventory.');
        } else {
          return const InteractionResult.failure('Not enough rupees.');
        }
      },
    ));

    // Clue Document Pickup near garden gate: The Old Photograph
    interactionSystem.register(WorldInteractable(
      id: 'pickup_photograph',
      name: 'Weathered Photograph',
      type: InteractableType.document,
      position: three.Vector3(-12.0, 0, -4.5),
      interactionRadius: 2.5,
      prompt: 'Pick up Old Photograph',
      onExecute: (context) {
        gameState.inventory.addItem(ItemData.oldPhotograph);
        gameState.setFlag('found_photograph', true);
        interactionSystem.unregister('pickup_photograph');
        return const InteractionResult.success(
            'Found Weathered Photograph! "You left us once. Don\'t do it again." Added to inventory.');
      },
    ));

    // Phase 33: Locked Contraband Casket in Warehouse Dock
    final warehouseChestLock = LockData.warehouseContraband();
    interactionSystem.register(WorldInteractable(
      id: 'warehouse_contraband_chest',
      name: 'Warehouse Contraband Casket',
      type: InteractableType.container,
      position: three.Vector3(22.0, 0, -16.0),
      interactionRadius: 3.0,
      prompt: 'Pick Lock: Contraband Casket',
      onExecute: (context) {
        if (warehouseChestLock.isUnlocked) {
          return const InteractionResult.failure('Casket has already been picked open and looted.');
        }
        _openLockpickingMiniGame(warehouseChestLock);
        return const InteractionResult.success('Began picking lock on Contraband Casket...');
      },
    ));

    // Phase 33: Syndicate Kingpin Safe
    final syndicateSafeLock = LockData.syndicateSafe();
    interactionSystem.register(WorldInteractable(
      id: 'syndicate_safe',
      name: 'Syndicate Kingpin Iron Safe',
      type: InteractableType.container,
      position: three.Vector3(-14.0, 0, 18.0),
      interactionRadius: 3.0,
      prompt: 'Pick Lock: Syndicate Safe',
      onExecute: (context) {
        if (syndicateSafeLock.isUnlocked) {
          return const InteractionResult.failure('Safe has already been unlocked.');
        }
        _openLockpickingMiniGame(syndicateSafeLock);
        return const InteractionResult.success('Began picking lock on Syndicate Kingpin Safe...');
      },
    ));

    // Phase 39 & Phase 40: Exploration Collectibles & World Clues
    for (final col in collectibleManager.collectibles) {
      interactionSystem.register(WorldInteractable(
        id: 'col_${col.id}',
        name: col.title,
        type: InteractableType.document,
        position: col.worldPosition,
        interactionRadius: 3.5,
        prompt: col.type == CollectibleType.memory
            ? 'Reflect: ${col.title}'
            : 'Examine: ${col.title}',
        onExecute: (context) {
          if (col.isCollected) {
            return InteractionResult.failure('${col.title} has already been discovered.');
          }
          final collected = collectibleManager.collect(col.id);
          if (collected != null) {
            final clueNote = col.clueId != null ? ' (Clue added to Dossier)' : '';
            return InteractionResult.success(
              '${col.type == CollectibleType.memory ? "Memory Recalled" : "Found Collectible"}: ${col.title}$clueNote',
            );
          }
          return const InteractionResult.failure('Unable to inspect collectible.');
        },
      ));
    }
  }

  void _openLockpickingMiniGame(LockData lock) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LockpickingDialog(
        lock: lock,
        initialPicks: 5,
        onUnlocked: (unlockedLock, picksRemaining) {
          audioManager.playUi(AudioEvent.missionObjectiveTick);
          if (unlockedLock.rewardMoney > 0) {
            gameState.earnMoney(unlockedLock.rewardMoney);
            gameState.addReputation(15);
          }
          if (mounted) {
            setState(() {
              _interactionMessage =
                  'LOCKPICKED ${unlockedLock.name.toUpperCase()}! (+₹${unlockedLock.rewardMoney}, +15 REP)';
            });
          }
        },
        onClosed: (picksRemaining) {
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _checkNearbyInteractions() {
    if (vehicleController.isDriving) {
      if (_nearbyInteractable != null) {
        setState(() {
          _nearbyInteractable = null;
        });
      }
      return;
    }

    final context = InteractionContext(
      playerPosition: player.position,
      storyFlags: gameState.persistentFlags,
      playerMoney: gameState.money,
    );

    final closest = interactionSystem.findClosestInteractable(context);
    if (closest?.id != _nearbyInteractable?.id) {
      setState(() {
        _nearbyInteractable = closest;
      });
    }
  }

  void _triggerInteraction() {
    if (_nearbyInteractable == null) return;

    if (_nearbyInteractable is Vehicle) {
      final targetVeh = _nearbyInteractable as Vehicle;
      // Toggle enter / exit vehicle
      if (!vehicleController.isDriving) {
        vehicleController.enterVehicle(targetVeh, player);
        if (!targetVeh.isOwnedByPlayer && !targetVeh.isStolen) {
          targetVeh.isStolen = true;
          wantedSystem.reportCrime(CrimeType.recklessDriving, customDescription: 'Stole a vehicle: ${targetVeh.name}');
        }
        setState(() {
          _interactionMessage = 'Mounted ${targetVeh.name}. Use WASD/Stick to drive, Space to brake, E to exit.';
        });
      }
      return;
    }

    final context = InteractionContext(
      playerPosition: player.position,
      storyFlags: gameState.persistentFlags,
      playerMoney: gameState.money,
    );

    final result = interactionSystem.executeInteraction(_nearbyInteractable!, context);

    if (result.message != null) {
      setState(() {
        _interactionMessage = result.message;
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _interactionMessage = null;
          });
        }
      });
    }

    _checkNearbyInteractions();
  }

  String _getTreeIdForNpc(String npcId) {
    switch (npcId) {
      case 'meera':
        return 'meera_homecoming';
      case 'diya':
        return 'diya_encounter';
      case 'balan':
        return 'balan_tea_stall';
      case 'informant':
        return 'informant_warning';
      case 'raghav':
        return 'raghav_chat';
      case 'rahu':
        return 'rahu_confrontation';
      case 'devraj':
        return 'devraj_showdown';
      default:
        return 'raghav_chat';
    }
  }

  void _processKeyboardInputs() {
    if (dialogueManager.isDialogueActive || showIntroCard || showInventory) {
      playerController.setMovementInput(Offset.zero);
      return;
    }

    if (vehicleController.isDriving) return;

    if (_virtualMoveInput != Offset.zero) {
      playerController.setMovementInput(_virtualMoveInput);
      return;
    }

    double dx = 0.0;
    double dy = 0.0;

    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      dy += 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      dy -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dx -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dx += 1.0;
    }

    final bool shiftPressed = _pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.shiftRight);

    playerController.setSprint(isSprinting || shiftPressed);
    playerController.setMovementInput(Offset(dx, dy));
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);

      // Escape: Skip cutscene or open Pause Menu
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (cinematicManager.isPlaying && cinematicManager.canSkip) {
          cinematicManager.skipSequence();
          return;
        }
        if (showInvestigationBoard) {
          setState(() => showInvestigationBoard = false);
          return;
        }
        if (_showMapScreen) {
          setState(() => _showMapScreen = false);
          return;
        }
        if (_showMissionsScreen) {
          setState(() => _showMissionsScreen = false);
          return;
        }
        if (showInventory) {
          setState(() => showInventory = false);
          return;
        }
        _openPauseMenu();
        return;
      }

      // Phase 39 & Phase 40: Toggle Investigation Board / Dossier with 'L'
      if (event.logicalKey == LogicalKeyboardKey.keyL) {
        setState(() {
          showInvestigationBoard = !showInvestigationBoard;
          _showMapScreen = false;
          _showMissionsScreen = false;
          _showPhoneScreen = false;
          showInventory = false;
        });
        audioManager.playUi(AudioEvent.uiClick);
        return;
      }

      // Toggle Tactical Map with 'M'
      if (event.logicalKey == LogicalKeyboardKey.keyM) {
        setState(() {
          _showMapScreen = !_showMapScreen;
          _showMissionsScreen = false;
        });
        audioManager.playUi(AudioEvent.uiClick);
        return;
      }

      // Toggle Mission Journal with 'J'
      if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        setState(() {
          _showMissionsScreen = !_showMissionsScreen;
          _showMapScreen = false;
          _showPhoneScreen = false;
        });
        audioManager.playUi(AudioEvent.uiClick);
        return;
      }

      // Phase 27: Toggle Smartphone with 'P'
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        setState(() {
          _showPhoneScreen = !_showPhoneScreen;
          _showMapScreen = false;
          _showMissionsScreen = false;
        });
        audioManager.playUi(AudioEvent.uiClick);
        return;
      }

      // Toggle Performance HUD with F3
      if (event.logicalKey == LogicalKeyboardKey.f3) {
        setState(() {
          _showPerformanceHud = !_showPerformanceHud;
        });
        return;
      }

      // Cycle Weather with F4
      if (event.logicalKey == LogicalKeyboardKey.f4) {
        _cycleWeatherDebug();
        return;
      }

      // Toggle inventory with 'I'
      if (event.logicalKey == LogicalKeyboardKey.keyI) {
        setState(() {
          showInventory = !showInventory;
        });
        return;
      }

      // In Dialogue Mode
      if (dialogueManager.isDialogueActive) {
        final choices = dialogueManager.getAvailableChoices();
        final digitKeys = [
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.digit4,
          LogicalKeyboardKey.digit5,
          LogicalKeyboardKey.digit6,
        ];
        for (int i = 0; i < digitKeys.length; i++) {
          if (event.logicalKey == digitKeys[i] && choices.length > i) {
            dialogueManager.selectChoice(choices[i]);
            return;
          }
        }
        if (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.keyE) {
          dialogueManager.advanceLinear();
          return;
        }
      }

      // In Driving Mode
      if (vehicleController.isDriving) {
        if (event.logicalKey == LogicalKeyboardKey.keyE) {
          vehicleController.exitVehicle(player);
          setState(() {
            _interactionMessage = 'Exited vehicle.';
          });
          return;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          vehicleRadio.nextStation();
          setState(() {
            _interactionMessage = 'Radio: ${vehicleRadio.currentStation.name}';
          });
          return;
        }
      }

      // Combat keybindings (on foot)
      if (!vehicleController.isDriving) {
        // Quick-slot weapon selection (1, 2, 3, 4)
        if (event.logicalKey == LogicalKeyboardKey.digit1) {
          combatSystem.equipSlot(0);
          setState(() {});
          return;
        }
        if (event.logicalKey == LogicalKeyboardKey.digit2) {
          combatSystem.equipSlot(1);
          setState(() {});
          return;
        }
        if (event.logicalKey == LogicalKeyboardKey.digit3) {
          combatSystem.equipSlot(2);
          setState(() {});
          return;
        }
        if (event.logicalKey == LogicalKeyboardKey.digit4) {
          combatSystem.equipSlot(3);
          setState(() {});
          return;
        }

        // Toggle ADS Aiming mode with Z
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          combatSystem.setAiming(!combatSystem.isAiming);
          setState(() {});
          return;
        }

        // Weapon Attack / Fire with F
        if (event.logicalKey == LogicalKeyboardKey.keyF) {
          combatSystem.executeWeaponAttack(
            playerPosition: player.position,
            playerRotationY: player.rotationY,
          );
          setState(() {});
          return;
        }

        // Weapon Reload or Heavy Melee Strike with R
        if (event.logicalKey == LogicalKeyboardKey.keyR) {
          if (combatSystem.equippedWeapon.isFirearm) {
            combatSystem.startReload();
            setState(() {});
          } else {
            combatSystem.executeHeavyAttack(
              playerPosition: player.position,
              playerRotationY: player.rotationY,
            );
            setState(() {});
          }
          return;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyQ) {
          combatSystem.setBlocking(!combatSystem.isBlocking);
          setState(() {});
          return;
        }

        // Phase 31: Toggle Crouch / Sneak with Key C
        if (event.logicalKey == LogicalKeyboardKey.keyC) {
          playerController.toggleCrouch();
          stealthSystem.setCrouched(playerController.isCrouching);
          setState(() {});
          return;
        }

        // Phase 32: Toggle Social Blending with Key B
        if (event.logicalKey == LogicalKeyboardKey.keyB) {
          disguiseManager.toggleBlend();
          setState(() {});
          return;
        }

        // Phase 32: Cycle Disguise with Key U
        if (event.logicalKey == LogicalKeyboardKey.keyU) {
          final allDisguises = DisguiseDatabase.allDisguises;
          final currentIndex = allDisguises.indexWhere((d) => d.type == disguiseManager.currentDisguise.type);
          final nextIndex = (currentIndex + 1) % allDisguises.length;
          disguiseManager.unlockDisguise(allDisguises[nextIndex].type);
          disguiseManager.equipDisguise(allDisguises[nextIndex].type, player);
          setState(() {
            _interactionMessage = 'EQUIPPED DISGUISE: ${disguiseManager.currentDisguise.name.toUpperCase()}';
          });
          return;
        }
      }

      // Normal Foot Mode
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (!vehicleController.isDriving) {
          playerController.triggerJump();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
        if (_takedownCandidate != null) {
          stealthSystem.executeTakedown(_takedownCandidate!);
          setState(() {});
        } else {
          _triggerInteraction();
        }
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }
  }

  void _onCameraDrag(Offset delta) {
    if (!isReady || dialogueManager.isDialogueActive || showIntroCard || showInventory) {
      return;
    }
    const double sensitivity = 0.0055;
    playerCamera.rotate(-delta.dx * sensitivity, delta.dy * sensitivity);
  }

  void _openPauseMenu() {
    setState(() => _isGamePaused = true);
    audioManager.playUi(AudioEvent.uiClick);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PauseMenuDialog(
        onResume: () {
          setState(() => _isGamePaused = false);
        },
        onOpenMap: () {
          setState(() {
            _isGamePaused = false;
            _showMapScreen = true;
          });
        },
        onOpenMissions: () {
          setState(() {
            _isGamePaused = false;
            _showMissionsScreen = true;
          });
        },
        onOpenInventory: () {
          setState(() {
            _isGamePaused = false;
            showInventory = true;
          });
        },
        onOpenSaveLoad: () {
          _openSaveLoadDialog();
        },
        onOpenSettings: () {
          _openSettingsDialog();
        },
        onQuitToMainMenu: () {
          setState(() => _isGamePaused = false);
          // Lift to the real root menu flow when available.
          if (widget.onExitToMainMenu != null) {
            Navigator.of(context).pop(); // close pause dialog
            widget.onExitToMainMenu!();
          } else {
            setState(() => _showMainMenu = true);
          }
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _isGamePaused = false);
    });
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SettingsDialog(
        audioManager: audioManager,
        currentPreset: performanceManager.currentPreset,
        showPerformanceHud: _showPerformanceHud,
        onPresetChanged: (preset) {
          performanceManager.setPreset(preset);
          world.chunkManager.renderDistance = performanceManager.renderDistance;
        },
        onPerformanceHudToggled: (enabled) {
          setState(() => _showPerformanceHud = enabled);
        },
      ),
    );
  }

  void _cycleWeatherDebug() {
    final nextIndex = (weatherManager.currentWeather.index + 1) % WeatherState.values.length;
    final nextWeather = WeatherState.values[nextIndex];
    weatherManager.setWeather(nextWeather, audioManager: audioManager);
    setState(() {
      _interactionMessage = 'WEATHER CHANGED: ${nextWeather.displayName.toUpperCase()}';
    });
  }

  void _openSaveLoadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SaveLoadDialog(
        saveManager: saveManager,
        onSaveRequested: (slotId) async {
          final snap = saveManager.createSaveSnapshot(
            slotId: slotId,
            label: 'Manual Save (Slot $slotId)',
            player: player,
            gameState: gameState,
            chunkManager: world.chunkManager,
            choiceSystem: storyChoiceSystem,
            actManager: storyActManager,
            missionManager: missionManager,
            vehicleController: vehicleController,
            collectibleManager: collectibleManager,
            investigationManager: investigationManager,
          );
          await saveManager.saveGame(slotId, snap);
          if (mounted) {
            setState(() {
              _interactionMessage = 'GAME SAVED TO SLOT $slotId';
            });
          }
        },
        onLoadRequested: (slotId) async {
          final snap = await saveManager.loadGame(slotId);
          if (snap != null) {
            saveManager.applySaveDataToGame(
              data: snap,
              player: player,
              gameState: gameState,
              chunkManager: world.chunkManager,
              choiceSystem: storyChoiceSystem,
              actManager: storyActManager,
              missionManager: missionManager,
              vehicleController: vehicleController,
              collectibleManager: collectibleManager,
              investigationManager: investigationManager,
            );
            if (mounted) {
              setState(() {
                _interactionMessage = 'RESTORED GAME FROM SLOT $slotId';
              });
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    threeJs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDialogueOpen = dialogueManager.isDialogueActive;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          children: [
            // 1. 3D Canvas
            Positioned.fill(
              child: threeJs.build(),
            ),

            // 2. Mobile Touch Controls (Joystick & Action Buttons)
            if (isReady && !isDialogueOpen && !showIntroCard && !showInventory)
              Positioned.fill(
                child: VirtualControls(
                  onMove: (offset) {
                    _virtualMoveInput = offset;
                  },
                  onCameraDrag: _onCameraDrag,
                  onJump: () {
                    playerController.triggerJump();
                  },
                  onSprintToggle: (sprint) {
                    setState(() {
                      isSprinting = sprint;
                    });
                    playerController.setSprint(sprint);
                  },
                  isSprinting: isSprinting,
                  onInteract: _triggerInteraction,
                  showInteractButton: _nearbyInteractable != null && !vehicleController.isDriving,
                  // Combat Hooks
                  onLightAttack: () {
                    combatSystem.executeLightAttack(
                      playerPosition: player.position,
                      playerRotationY: player.rotationY,
                    );
                  },
                  onHeavyAttack: () {
                    combatSystem.executeHeavyAttack(
                      playerPosition: player.position,
                      playerRotationY: player.rotationY,
                    );
                  },
                  onBlockToggle: (blocking) {
                    combatSystem.setBlocking(blocking);
                    setState(() {});
                  },
                  isBlocking: combatSystem.isBlocking,
                  // Vehicle Driving Hooks
                  isDriving: vehicleController.isDriving,
                  onThrottle: (throttle) {
                    _virtualThrottle = throttle;
                  },
                  onHandbrake: () {
                    _virtualHandbrake = !_virtualHandbrake;
                    setState(() {});
                  },
                  onExitVehicle: () {
                    vehicleController.exitVehicle(player);
                    setState(() {});
                  },
                ),
              ),

            // 3. Top Cinematic Header & Indicators
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'V A Y A L',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 7.0,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'VEYRAPURAM // CHAPTER 1 : HOMECOMING',
                          style: TextStyle(
                            color: Color(0xFF8B95A2),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          children: [
                        // Health Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2C3540)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 12, color: Color(0xFFEF5350)),
                              const SizedBox(width: 4),
                              Text(
                                'HP ${combatSystem.playerHealth.toInt()}',
                                style: const TextStyle(
                                  color: Color(0xFFEF5350),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 37: Stamina Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: combatSystem.isGuardBroken
                                  ? const Color(0xFFEF4444)
                                  : (combatSystem.isExhausted
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF2C3540)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 13,
                                color: combatSystem.isGuardBroken
                                    ? const Color(0xFFEF4444)
                                    : (combatSystem.isExhausted
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF38BDF8)),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                combatSystem.isGuardBroken
                                    ? 'GUARD BROKEN'
                                    : (combatSystem.isExhausted
                                        ? 'EXHAUSTED'
                                        : 'STM ${combatSystem.playerStamina.toInt()}'),
                                style: TextStyle(
                                  color: combatSystem.isGuardBroken
                                      ? const Color(0xFFEF4444)
                                      : (combatSystem.isExhausted
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFF38BDF8)),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Vehicle Status Pill (if driving)
                        if (vehicleController.isDriving) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFD97736)),
                            ),
                            child: Text(
                              '${(vehicle.speed.abs() * 3.6).toInt()} KM/H | CAR ${vehicle.health.toInt()}%',
                              style: const TextStyle(
                                color: Color(0xFFD97736),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Currency Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2C3540)),
                          ),
                          child: Text(
                            '₹${gameState.money}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Reputation Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2C3540)),
                          ),
                          child: Text(
                            'REP: ${gameState.reputation}',
                            style: const TextStyle(
                              color: Color(0xFFD97736),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Story Act Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2C3540)),
                          ),
                          child: Text(
                            '${storyActManager.currentActData.romanTitle}: ${storyActManager.currentActData.title}',
                            style: const TextStyle(
                              color: Color(0xFFD97736),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // World Region Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14181E).withAlpha(210),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF2C3540)),
                          ),
                          child: Text(
                            RegionData.registry[_currentRegion]!.title,
                            style: const TextStyle(
                              color: Color(0xFF81C784),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 24 & 25: Dynamic Clock & Weather Status Pill
                        ClockWeatherHud(
                          timeManager: timeManager,
                          weatherManager: weatherManager,
                          onTap: _cycleWeatherDebug,
                        ),
                        const SizedBox(width: 8),

                        // Inventory Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showInventory = !showInventory;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: showInventory
                                  ? const Color(0xFFD97736)
                                  : const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: showInventory
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2C3540),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.backpack_outlined,
                                  color: showInventory ? Colors.white : const Color(0xFF9EAAB9),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'BAG [I]',
                                  style: TextStyle(
                                    color: showInventory ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 39 & 40: Investigation Dossier Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showInvestigationBoard = !showInvestigationBoard;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: showInvestigationBoard
                                  ? const Color(0xFFD97736)
                                  : const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: showInvestigationBoard
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2C3540),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.manage_search_rounded,
                                  color: showInvestigationBoard ? Colors.white : const Color(0xFF9EAAB9),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DOSSIER [L]',
                                  style: TextStyle(
                                    color: showInvestigationBoard ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 18: Save/Load Button
                        GestureDetector(
                          onTap: () {
                            audioManager.playUi(AudioEvent.uiClick);
                            showDialog(
                              context: context,
                              builder: (ctx) => SaveLoadDialog(
                                saveManager: saveManager,
                                onSaveRequested: (slotId) async {
                                  final snap = saveManager.createSaveSnapshot(
                                    slotId: slotId,
                                    label: 'Manual Save (Slot $slotId)',
                                    player: player,
                                    gameState: gameState,
                                    chunkManager: world.chunkManager,
                                    choiceSystem: storyChoiceSystem,
                                    actManager: storyActManager,
                                    missionManager: missionManager,
                                    vehicleController: vehicleController,
                                    collectibleManager: collectibleManager,
                                    investigationManager: investigationManager,
                                  );
                                  await saveManager.saveGame(slotId, snap);
                                  if (mounted) {
                                    setState(() {
                                      _interactionMessage = 'GAME SAVED TO SLOT $slotId';
                                    });
                                  }
                                },
                                onLoadRequested: (slotId) async {
                                  final snap = await saveManager.loadGame(slotId);
                                  if (snap != null) {
                                    saveManager.applySaveDataToGame(
                                      data: snap,
                                      player: player,
                                      gameState: gameState,
                                      chunkManager: world.chunkManager,
                                      choiceSystem: storyChoiceSystem,
                                      actManager: storyActManager,
                                      missionManager: missionManager,
                                      vehicleController: vehicleController,
                                      collectibleManager: collectibleManager,
                                      investigationManager: investigationManager,
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _interactionMessage = 'RESTORED GAME FROM SLOT $slotId';
                                      });
                                    }
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2C3540)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.save_outlined, color: Color(0xFF9EAAB9), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'SAVE',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 21: Tactical Map Button
                        GestureDetector(
                          onTap: () {
                            audioManager.playUi(AudioEvent.uiClick);
                            setState(() {
                              _showMapScreen = !_showMapScreen;
                              _showMissionsScreen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _showMapScreen
                                  ? const Color(0xFFD97736)
                                  : const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _showMapScreen
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2C3540),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  color: _showMapScreen ? Colors.white : const Color(0xFF9EAAB9),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'MAP [M]',
                                  style: TextStyle(
                                    color: _showMapScreen ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 21: Missions Journal Button
                        GestureDetector(
                          onTap: () {
                            audioManager.playUi(AudioEvent.uiClick);
                            setState(() {
                              _showMissionsScreen = !_showMissionsScreen;
                              _showMapScreen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _showMissionsScreen
                                  ? const Color(0xFFD97736)
                                  : const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _showMissionsScreen
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2C3540),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: _showMissionsScreen ? Colors.white : const Color(0xFF9EAAB9),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LOG [J]',
                                  style: TextStyle(
                                    color: _showMissionsScreen ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 27: Smartphone HUD Button
                        GestureDetector(
                          onTap: () {
                            audioManager.playUi(AudioEvent.uiClick);
                            setState(() {
                              _showPhoneScreen = !_showPhoneScreen;
                              _showMapScreen = false;
                              _showMissionsScreen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _showPhoneScreen
                                  ? const Color(0xFFD97736)
                                  : const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _showPhoneScreen
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF2C3540),
                              ),
                            ),
                            child: Row(
                              children: [
                                Badge(
                                  isLabelVisible: phoneManager.hasUnreadMessages,
                                  label: Text('${phoneManager.unreadMessageCount}', style: const TextStyle(fontSize: 8)),
                                  child: Icon(
                                    Icons.phone_android_rounded,
                                    color: _showPhoneScreen ? Colors.white : const Color(0xFF9EAAB9),
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PHONE [P]',
                                  style: TextStyle(
                                    color: _showPhoneScreen ? Colors.white : Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 21 & 22: Settings Button
                        GestureDetector(
                          onTap: () {
                            audioManager.playUi(AudioEvent.uiClick);
                            _openSettingsDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2C3540)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.settings_outlined, color: Color(0xFF9EAAB9), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'SETTINGS',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Phase 21: Pause Menu Button
                        GestureDetector(
                          onTap: () {
                            _openPauseMenu();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14181E).withAlpha(210),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2C3540)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.pause_outlined, color: Color(0xFF9EAAB9), size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'PAUSE',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

            // 4. Police Wanted Stars Overlay (Top Center)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: WantedHud(wantedSystem: wantedSystem),
                ),
              ),
            ),

            // 5. Mission HUD Tracker, Intro Card, and Mission Complete Banner
            if (!showInventory)
              MissionHud(
                manager: missionManager,
                completedMissionNotification: _completedMissionNotification,
                showIntroCard: showIntroCard,
              ),

            // 6. Universal Interaction Prompt Banner
            if (_nearbyInteractable != null && !isDialogueOpen && !showIntroCard && !showInventory)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 140),
                  child: GestureDetector(
                    onTap: _triggerInteraction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131820).withAlpha(240),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFD97736),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(160),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97736),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'E',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _nearbyInteractable!.prompt,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 7. Active Data-Driven Dialogue Overlay
            if (isDialogueOpen && !showInventory)
              DialogueView(
                manager: dialogueManager,
                onAdvance: () {
                  dialogueManager.advanceLinear();
                },
                onSelectChoice: (choice) {
                  dialogueManager.selectChoice(choice);
                },
              ),

            // Cinematic Story Act Banner Overlay
            if (_actBannerTitle != null && !showInventory)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 85),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1115).withAlpha(240),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFD97736), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD97736).withAlpha(100),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _actBannerTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          storyActManager.currentActData.tagline,
                          style: const TextStyle(
                            color: Color(0xFFB0B9C6),
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Open World Region Entry Banner
            if (_regionBannerTitle != null && _actBannerTitle == null && !showInventory)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 85),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141820).withAlpha(230),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4C586A), width: 1.2),
                    ),
                    child: Text(
                      'ENTERING // $_regionBannerTitle',
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),
                ),
              ),

            // 8. Interactive Offline Inventory Modal
            if (showInventory)
              InventorySheet(
                gameState: gameState,
                combatSystem: combatSystem,
                storyChoiceSystem: storyChoiceSystem,
                storyActManager: storyActManager,
                onClose: () {
                  setState(() {
                    showInventory = false;
                  });
                },
              ),

            // Phase 39 & 40: Interactive Investigation & Evidence Board Modal
            if (showInvestigationBoard)
              InvestigationBoardDialog(
                investigationManager: investigationManager,
                collectibleManager: collectibleManager,
                onClose: () {
                  setState(() {
                    showInvestigationBoard = false;
                  });
                },
              ),

            // 9. Interaction Toast Message
            if (_interactionMessage != null && !isDialogueOpen && !showIntroCard && !showInventory)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 90),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B202A),
                        border: Border.all(color: const Color(0xFF4C586A)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _interactionMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 10. Bottom-center Controls Hints (Desktop / Keyboard)
            if (!isDialogueOpen && !showIntroCard && !showInventory)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1217).withAlpha(190),
                        border: Border.all(color: const Color(0xFF222933)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicleController.isDriving
                            ? 'W/S: Gas & Reverse  •  A/D: Steer  •  SPACE: Handbrake  •  R: FM Radio  •  E: Exit Car'
                            : 'WASD: Move  •  1-4: Weapon  •  F: Attack  •  R: Reload/Heavy  •  Z: Aim  •  Q: Block  •  SPACE: Jump  •  E: Interact  •  P: Phone',
                        style: const TextStyle(
                          color: Color(0xFF788392),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Phase 29: Center Tactical Crosshair Overlay
            if (!vehicleController.isDriving && !isDialogueOpen && !showIntroCard && !showInventory && (combatSystem.isAiming || combatSystem.equippedWeapon.isFirearm))
              CrosshairOverlay(isAiming: combatSystem.isAiming),

            // Phase 29: Active Weapon HUD & Ammo Counter (Bottom Right)
            if (!vehicleController.isDriving && !isDialogueOpen && !showIntroCard && !showInventory)
              Positioned(
                bottom: 24,
                right: 20,
                child: WeaponHud(
                  combatSystem: combatSystem,
                  onSelectSlot: (slot) => setState(() => combatSystem.equipSlot(slot)),
                  onReload: () => setState(() => combatSystem.startReload()),
                ),
              ),

            // Phase 30: Boss Encounter HUD
            if (activeBossEncounter != null && !activeBossEncounter!.isDefeated)
              BossHudOverlay(encounter: activeBossEncounter!),

            // Phase 31: Stealth & Infiltration HUD Overlay
            if (!vehicleController.isDriving && !isDialogueOpen && !showIntroCard && !showInventory)
              StealthHudOverlay(
                stealthSystem: stealthSystem,
                takedownCandidate: _takedownCandidate,
                onExecuteTakedown: () {
                  if (_takedownCandidate != null) {
                    stealthSystem.executeTakedown(_takedownCandidate!);
                    setState(() {});
                  }
                },
                onToggleCrouch: () {
                  setState(() {
                    playerController.toggleCrouch();
                    stealthSystem.setCrouched(playerController.isCrouching);
                  });
                },
              ),

            // Phase 32: Disguise & Social Stealth HUD Overlay
            if (!vehicleController.isDriving && !isDialogueOpen && !showIntroCard && !showInventory)
              DisguiseHudOverlay(
                disguiseManager: disguiseManager,
                onToggleBlend: () => setState(() => disguiseManager.toggleBlend()),
              ),

            // Phase 34: Advanced Vehicle Driving HUD
            if (vehicleController.isDriving && !isDialogueOpen && !showIntroCard && !showInventory)
              VehicleHud(
                vehicle: vehicleController.activeVehicle ?? vehicle,
                radio: vehicleRadio,
                pursuitManager: pursuitManager,
                onCycleRadio: () => setState(() => vehicleRadio.nextStation()),
              ),

            // 11. Phase 17: Ending Screen Overlay
            if (_showEndingScreen && endingManager.isEndingActive)
              EndingScreen(
                endingManager: endingManager,
                choiceSystem: storyChoiceSystem,
                onReturnToFreeRoam: () {
                  setState(() {
                    _showEndingScreen = false;
                  });
                  audioManager.playMusic(AudioEvent.themeHome);
                },
              ),

            // 12. Phase 22: Performance Metrics Overlay (F3 Toggle)
            if (_showPerformanceHud)
              Positioned(
                top: 72,
                left: 20,
                child: PerformanceHud(
                  performanceManager: performanceManager,
                  visibleChunks: world.chunkManager.regionGroups.values.where((g) => g.visible).length,
                  totalChunks: world.chunkManager.regionGroups.length,
                  activeNpcs: performanceManager.filterActiveNpcs(npcController.npcs, player.position).length,
                  totalNpcs: npcController.npcs.length,
                ),
              ),

            // 13. Phase 20: Scripted Cinematic Letterbox & Subtitles
            CinematicOverlay(
              cinematicManager: cinematicManager,
              onSkip: () => cinematicManager.skip(),
            ),

            // 14. Phase 21 & Phase 26: Fullscreen Tactical World Map Screen
            if (_showMapScreen)
              Positioned.fill(
                child: WorldMapScreen(
                  playerPosition: player.position,
                  playerRotationY: player.rotationY,
                  vehiclePosition: vehicleController.isDriving ? vehicle.position : null,
                  missionWaypoint: missionManager.activeMission?.currentObjective?.targetLocation ??
                      sideQuestManager.activeQuest?.currentStep?.targetLocation,
                  missionTitle: missionManager.activeMission?.title ??
                      sideQuestManager.activeQuest?.title,
                  customWaypoint: _customDestinationWaypoint,
                  onSetCustomWaypoint: (wp) {
                    setState(() => _customDestinationWaypoint = wp);
                  },
                  currentRegion: _currentRegion,
                  onClose: () => setState(() => _showMapScreen = false),
                ),
              ),

            // 15. Phase 21 & Phase 28: Fullscreen Mission & Side Quest Log Screen
            if (_showMissionsScreen)
              Positioned.fill(
                child: MissionsScreen(
                  missionManager: missionManager,
                  sideQuestManager: sideQuestManager,
                  onTrackSideQuest: (qId) {
                    setState(() {
                      sideQuestManager.startQuest(qId);
                    });
                  },
                  onClose: () => setState(() => _showMissionsScreen = false),
                ),
              ),

            // 16. Phase 27: Fullscreen Smartphone Overlay
            if (_showPhoneScreen)
              Positioned.fill(
                child: PhoneOverlay(
                  phoneManager: phoneManager,
                  currentTimeString: timeManager.formattedTime,
                  onClose: () => setState(() => _showPhoneScreen = false),
                  onInitiateQuest: (qId) {
                    setState(() {
                      sideQuestManager.startQuest(qId);
                      _showPhoneScreen = false;
                    });
                  },
                ),
              ),

            // Phase 27: Incoming Call Pop-up Banner
            if (phoneManager.activeIncomingCall != null)
              IncomingCallBanner(
                call: phoneManager.activeIncomingCall!,
                onAnswer: () => setState(() => phoneManager.answerIncomingCall()),
                onDecline: () => setState(() => phoneManager.declineIncomingCall()),
              ),

            // Phase 27: Ongoing In-Call Speech Banner
            if (phoneManager.activeOngoingCall != null)
              OngoingCallBanner(
                call: phoneManager.activeOngoingCall!,
                onAdvance: () => setState(() => phoneManager.advanceOngoingCall()),
                onHangUp: () => setState(() => phoneManager.hangUpOngoingCall()),
              ),

            // Phase 28: Side Quest Step / Completion Notification Toast
            if (_sideQuestNotification != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80.0),
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101926).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.3),
                          blurRadius: 16.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: Text(
                      _sideQuestNotification!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

            // 16. Phase 21: Fullscreen Main Menu Screen
            if (_showMainMenu)
              Positioned.fill(
                child: MainMenuScreen(
                  hasSaveData: true,
                  onContinue: () {
                    setState(() => _showMainMenu = false);
                  },
                  onNewGame: () {
                    setState(() {
                      _showMainMenu = false;
                      showIntroCard = true;
                    });
                  },
                  onLoadGame: () {
                    _openSaveLoadDialog();
                  },
                  onOpenSettings: () {
                    _openSettingsDialog();
                  },
                  onOpenCredits: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreditsScreen(
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
