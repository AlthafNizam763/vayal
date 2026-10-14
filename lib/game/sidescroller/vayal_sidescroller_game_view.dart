import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as three;

import 'sidescroller_world_scene.dart';
import 'sidescroller_painter.dart';
import 'sidescroller_player.dart';
import '../missions/mission_manager.dart';
import '../dialogue/dialogue_manager.dart';
import '../save/save_manager.dart';
import '../systems/game_state.dart';
import '../../data/dialogue/dialogue_data.dart';
import '../../ui/dialogue/dialogue_view.dart';
import '../../ui/mission/mission_hud.dart';

/// 2D Side-Scrolling Gameplay View for VAYAL.
/// Renders an authentic Kerala pixel-art side-scroller with multi-layer parallax,
/// connected directly to the established MissionManager, DialogueManager, and Save systems.
class VayalSideScrollerGameView extends StatefulWidget {
  final int? autoLoadSlotId;
  final VoidCallback? onExitToMainMenu;

  const VayalSideScrollerGameView({
    super.key,
    this.autoLoadSlotId,
    this.onExitToMainMenu,
  });

  @override
  State<VayalSideScrollerGameView> createState() =>
      _VayalSideScrollerGameViewState();
}

class _VayalSideScrollerGameViewState extends State<VayalSideScrollerGameView>
    with SingleTickerProviderStateMixin {
  late final SideScrollerWorldScene scene;
  late final MissionManager missionManager;
  late final DialogueManager dialogueManager;
  late final SaveManager saveManager;
  late final GameState gameState;
  late final AnimationController _ticker;

  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  // Touch Virtual Controls state
  double _touchDirection = 0.0;
  bool _isTouchSprinting = false;

  // Interaction prompt & action
  String? _interactionPrompt;
  VoidCallback? _activeInteraction;

  double _lastTickTime = 0.0;

  @override
  void initState() {
    super.initState();
    scene = SideScrollerWorldScene();

    missionManager = MissionManager();
    dialogueManager = DialogueManager();
    saveManager = SaveManager();
    gameState = GameState();

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

    _processMovement(dt);
    scene.update(dt);

    // Location objective checks (evaluate Aadi's X position on street)
    _checkMissionObjectives();

    // Check interaction prompt proximity
    _checkInteractions();

    setState(() {});
  }

  void _processMovement(double dt) {
    if (dialogueManager.isDialogueActive) {
      scene.player.isMoving = false;
      return;
    }

    double dir = _touchDirection;

    if (_pressedKeys.contains(LogicalKeyboardKey.keyA) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
      dir -= 1.0;
    }
    if (_pressedKeys.contains(LogicalKeyboardKey.keyD) ||
        _pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
      dir += 1.0;
    }

    final isSprinting = _isTouchSprinting ||
        _pressedKeys.contains(LogicalKeyboardKey.shiftLeft);

    scene.player.isSprinting = isSprinting;

    if (dir.abs() > 0.05) {
      final speed = isSprinting ? 7.5 : 4.5;
      final moveDist = dir.sign * speed * dt;

      scene.player.worldX = (scene.player.worldX + moveDist).clamp(
        scene.minX,
        scene.maxX,
      );

      scene.player.facing =
          (dir > 0) ? PlayerFacing.right : PlayerFacing.left;
      scene.player.isMoving = true;
    } else {
      scene.player.isMoving = false;
    }
  }

  void _checkMissionObjectives() {
    final curObj = missionManager.activeMission?.currentObjective;
    if (curObj == null) return;

    final aadiX = scene.player.worldX;

    // In 2D side-scrolling:
    // obj_reach_crossroad: Crossroad with Banyan tree is located at X ~ 8.0
    // obj_reach_house: Aadi's family home is located at X ~ 36.0
    if (curObj.id == 'obj_reach_crossroad') {
      if ((aadiX - 8.0).abs() < 2.5) {
        missionManager.checkLocation(three.Vector3(0.0, 0.0, 0.0));
      }
    } else if (curObj.id == 'obj_reach_house') {
      if ((aadiX - 34.0).abs() < 3.0) {
        missionManager.checkLocation(three.Vector3(-14.0, 0.0, -10.0));
      }
    }
  }

  void _checkInteractions() {
    final aadiX = scene.player.worldX;
    final curObj = missionManager.activeMission?.currentObjective;

    // Check Meera NPC at veranda (X = 33.5)
    if ((aadiX - 33.5).abs() < 2.0 && curObj?.id == 'obj_talk_meera') {
      _interactionPrompt = 'Talk to Meera [E]';
      _activeInteraction = _talkToMeera;
      return;
    }

    // Check Aadi's House Door (X = 36.0)
    if ((aadiX - 36.0).abs() < 2.5 && curObj?.id == 'obj_enter_house') {
      _interactionPrompt = 'Enter Family House [E]';
      _activeInteraction = _enterHouse;
      return;
    }

    // Check Balan's Tea Stall (X = 14.0)
    if ((aadiX - 14.0).abs() < 2.0) {
      _interactionPrompt = "Talk to Balan [E]";
      _activeInteraction = _talkToBalan;
      return;
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

  void _talkToBalan() {
    final tree = DialogueData.getTree('balan_tea_stall');
    if (tree != null) {
      dialogueManager.startDialogue(tree);
    }
  }

  void _enterHouse() {
    missionManager.notifyObjectInteracted('aadi_house_door');
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.keyE &&
          _activeInteraction != null) {
        _activeInteraction!();
      }
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
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
            // 1. 2D Side-Scrolling Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: SideScrollerPainter(
                  scene: scene,
                  animationTime: _ticker.value,
                ),
              ),
            ),

            // 2. Mobile Landscape Touch Controls (Left / Right Movement)
            if (!dialogueManager.isDialogueActive)
              Positioned(
                left: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Move Left Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => setState(() => _touchDirection = -1.0),
                          onTapUp: (_) => setState(() => _touchDirection = 0.0),
                          onTapCancel: () => setState(() => _touchDirection = 0.0),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _touchDirection < -0.1
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF0F172A).withAlpha(220),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _touchDirection < -0.1
                                    ? Colors.white
                                    : const Color(0xFF38BDF8),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Move Right Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => setState(() => _touchDirection = 1.0),
                          onTapUp: (_) => setState(() => _touchDirection = 0.0),
                          onTapCancel: () => setState(() => _touchDirection = 0.0),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _touchDirection > 0.1
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF0F172A).withAlpha(220),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _touchDirection > 0.1
                                    ? Colors.white
                                    : const Color(0xFF38BDF8),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Sprint & Action Buttons on Bottom-Right
            if (!dialogueManager.isDialogueActive)
              Positioned(
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sprint Toggle Button
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _isTouchSprinting = !_isTouchSprinting),
                          child: Container(
                            height: 56,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: _isTouchSprinting
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF0F172A).withAlpha(220),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isTouchSprinting
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFF38BDF8),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isTouchSprinting ? Icons.directions_run : Icons.directions_walk,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isTouchSprinting ? 'RUN' : 'WALK',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_activeInteraction != null) ...[
                          const SizedBox(width: 12),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _activeInteraction,
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF15803D),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF4ADE80), width: 2.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF15803D).withAlpha(140),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.touch_app, color: Colors.white, size: 22),
                                  SizedBox(width: 6),
                                  Text(
                                    'INTERACT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // 3. Top Header & Title Branding
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
                            color: Color(0xFFBAE6FD),
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
                  padding: const EdgeInsets.only(bottom: 95),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withAlpha(240),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
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
