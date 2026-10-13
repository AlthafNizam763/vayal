import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:three_js/three_js.dart' as three;

import 'isometric_world_scene.dart';
import 'isometric_world_painter.dart';
import '../missions/mission_manager.dart';
import '../dialogue/dialogue_manager.dart';
import '../save/save_manager.dart';
import '../systems/game_state.dart';
import '../../data/dialogue/dialogue_data.dart';
import '../../ui/dialogue/dialogue_view.dart';
import '../../ui/mission/mission_hud.dart';
import '../../ui/hud/virtual_controls.dart';

/// Complete 2.5D Isometric Gameplay View for VAYAL.
/// Operates seamlessly with the existing MissionManager, DialogueManager,
/// SaveManager, GameState, and landscape UI overlays.
class VayalIsometricGameView extends StatefulWidget {
  final int? autoLoadSlotId;
  final VoidCallback? onExitToMainMenu;

  const VayalIsometricGameView({
    super.key,
    this.autoLoadSlotId,
    this.onExitToMainMenu,
  });

  @override
  State<VayalIsometricGameView> createState() => _VayalIsometricGameViewState();
}

class _VayalIsometricGameViewState extends State<VayalIsometricGameView>
    with SingleTickerProviderStateMixin {
  late final IsometricWorldScene scene;
  late final MissionManager missionManager;
  late final DialogueManager dialogueManager;
  late final SaveManager saveManager;
  late final GameState gameState;
  late final AnimationController _ticker;

  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  // Touch and virtual input
  Offset _virtualMoveInput = Offset.zero;
  bool _isSprinting = false;

  // Interaction feedback
  String? _interactionPrompt;
  VoidCallback? _activeInteraction;

  double _lastTickTime = 0.0;

  @override
  void initState() {
    super.initState();
    scene = IsometricWorldScene();

    missionManager = MissionManager();
    dialogueManager = DialogueManager();
    saveManager = SaveManager();
    gameState = GameState();

    // MissionManager automatically begins mission_01_homecoming during initialization

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);
    _ticker.repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _gameLoop() {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (_lastTickTime == 0.0) _lastTickTime = now;
    final dt = (now - _lastTickTime).clamp(0.001, 0.05);
    _lastTickTime = now;

    // 1. Process movement inputs
    _processMovement(dt);

    // 2. Update isometric scene & camera
    scene.update(dt);

    // 3. Update mission checks against Aadi's ground position
    final playerPos3D = Offset(scene.player.worldX, scene.player.worldZ);
    // Location check for Homecoming objectives
    _checkMissionObjectives(playerPos3D);

    // 4. Check nearby interaction triggers
    _checkNearbyInteractions(playerPos3D);

    setState(() {});
  }

  void _processMovement(double dt) {
    if (dialogueManager.isDialogueActive) return;

    double inputX = _virtualMoveInput.dx;
    double inputZ = -_virtualMoveInput.dy; // invert Y for South/North

    // Keyboard support (WASD or Arrow Keys)
    if (_pressedKeys.contains(LogicalKeyboardKey.keyW) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
      inputZ -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyS) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
      inputZ += 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      inputX -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      inputX += 1.0;
    }

    final len = math.sqrt(inputX * inputX + inputZ * inputZ);
    if (len > 0.01) {
      final normX = inputX / (len > 1.0 ? len : 1.0);
      final normZ = inputZ / (len > 1.0 ? len : 1.0);

      final speed = _isSprinting ? 6.5 : 4.0;
      final targetX = scene.player.worldX + normX * speed * dt;
      final targetZ = scene.player.worldZ + normZ * speed * dt;

      // Collision detection with solid village objects
      if (!scene.checkCollision(targetX, targetZ, 0.6)) {
        scene.player.worldX = targetX;
        scene.player.worldZ = targetZ;
      } else if (!scene.checkCollision(targetX, scene.player.worldZ, 0.6)) {
        // Slide along X axis
        scene.player.worldX = targetX;
      } else if (!scene.checkCollision(scene.player.worldX, targetZ, 0.6)) {
        // Slide along Z axis
        scene.player.worldZ = targetZ;
      }

      scene.player.setFacingFromMovement(normX, normZ);
      scene.player.updateAnimation(dt, speed);
    } else {
      scene.player.updateAnimation(dt, 0.0);
    }
  }

  void _checkMissionObjectives(Offset pos) {
    // Uses existing three.Vector3 checkLocation on MissionManager
    missionManager.checkLocation(three.Vector3(pos.dx, 0.0, pos.dy));
  }

  void _checkNearbyInteractions(Offset pos) {
    // Check distance to house veranda / front door
    final doorDx = pos.dx - (-13.5);
    final doorDz = pos.dy - (-8.0);
    final doorDist = math.sqrt(doorDx * doorDx + doorDz * doorDz);

    if (doorDist < 3.0) {
      final curObj = missionManager.activeMission?.currentObjective;

      if (curObj?.id == 'obj_talk_meera') {
        _interactionPrompt = 'Talk to Meera [E]';
        _activeInteraction = _talkToMeera;
        return;
      } else if (curObj?.id == 'obj_enter_house') {
        _interactionPrompt = 'Enter Family Home [E]';
        _activeInteraction = _enterHouse;
        return;
      }
    }

    _interactionPrompt = null;
    _activeInteraction = null;
  }

  void _talkToMeera() {
    final tree = DialogueData.getTree('meera_homecoming');
    if (tree != null) {
      dialogueManager.startDialogue(tree);
      dialogueManager.onDialogueClosed = () {
        missionManager.notifyNpcTalked('meera');
      };
    }
  }

  void _enterHouse() {
    missionManager.notifyObjectInteracted('aadi_house_door');
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.keyE && _activeInteraction != null) {
        _activeInteraction!();
      }
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        _isSprinting = true;
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        _isSprinting = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          children: [
            // 1. 2.5D Isometric Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: IsometricWorldPainter(
                  scene: scene,
                  animationTime: _ticker.value,
                ),
              ),
            ),

            // 2. Mobile Touch Controls (Virtual Joystick & Action Buttons)
            if (!dialogueManager.isDialogueActive)
              Positioned.fill(
                child: VirtualControls(
                  onMove: (offset) => _virtualMoveInput = offset,
                  onCameraDrag: (_) {},
                  onJump: () {},
                  onSprintToggle: (s) => setState(() => _isSprinting = s),
                  isSprinting: _isSprinting,
                  onInteract: _activeInteraction,
                  showInteractButton: _interactionPrompt != null,
                ),
              ),

            // 3. Top Cinematic Header & Branding
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
                          'A VEYRAPURAM STORY // PROVIDED BY SUPPID GAMES',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: widget.onExitToMainMenu,
                    ),
                  ],
                ),
              ),
            ),

            // 4. Mission HUD Tracker
            if (missionManager.activeMission != null &&
                !dialogueManager.isDialogueActive)
              MissionHud(
                manager: missionManager,
                showIntroCard: false,
              ),

            // 5. Interaction Prompt Banner
            if (_interactionPrompt != null && !dialogueManager.isDialogueActive)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withAlpha(240),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFD97736), width: 1.5),
                    ),
                    child: Text(
                      _interactionPrompt!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Dialogue System View
            if (dialogueManager.isDialogueActive)
              DialogueView(
                manager: dialogueManager,
                onAdvance: () => dialogueManager.advanceLinear(),
                onSelectChoice: (choice) => dialogueManager.selectChoice(choice),
              ),
          ],
        ),
      ),
    );
  }
}
