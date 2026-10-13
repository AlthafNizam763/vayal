import 'package:flutter/material.dart';
import '../game/save/save_manager.dart';
import '../game/save/save_data.dart';
import '../game/vayal_game.dart';
import '../ui/boot/studio_intro_screen.dart';
import '../ui/menu/main_menu_screen.dart';
import '../ui/menu/credits_screen.dart';
import '../ui/menu/save_slot_picker_dialog.dart';

enum _BootStage { studioIntro, credits, menu, game }

/// Root application flow: Suppid Games studio intro → VAYAL title screen /
/// main menu (with live save state) → into the 3D game.
class VayalGameRoot extends StatefulWidget {
  const VayalGameRoot({super.key});

  @override
  State<VayalGameRoot> createState() => _VayalGameRootState();
}

class _VayalGameRootState extends State<VayalGameRoot> {
  _BootStage _stage = _BootStage.studioIntro;

  final SaveManager _menuSaveManager = SaveManager();
  List<SaveSlotMetadata>? _availableSaves;
  int _gameSession = 0;

  // Persisted across sessions: the slot to auto-load once the game is ready.
  int? _pendingAutoLoadSlot;

  @override
  void initState() {
    super.initState();
    _refreshSaves();
  }

  Future<void> _refreshSaves() async {
    final slots = await _menuSaveManager.listSaveSlots();
    if (!mounted) return;
    setState(() {
      _availableSaves = slots;
      if (slots.isEmpty) {
        _pendingAutoLoadSlot = null;
      }
    });
  }

  int? _mostRecentSaveSlot() {
    final slots = _availableSaves;
    if (slots == null || slots.isEmpty) return null;
    var latest = slots.first;
    for (final s in slots.skip(1)) {
      if (s.timestamp.isAfter(latest.timestamp)) latest = s;
    }
    return latest.slotId;
  }

  void _enterGame({int? autoLoadSlot}) {
    setState(() {
      _pendingAutoLoadSlot = autoLoadSlot;
      _gameSession++; // forces a fresh VayalGameView instance
      _stage = _BootStage.game;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _BootStage.studioIntro:
        return StudioIntroScreen(
          onFinished: () => setState(() => _stage = _BootStage.menu),
        );

      case _BootStage.credits:
        return CreditsScreen(
          onClose: () => setState(() => _stage = _BootStage.menu),
        );

      case _BootStage.menu:
        return _buildMainMenu();

      case _BootStage.game:
        return VayalGameView(
          key: ValueKey('game_session_$_gameSession'),
          autoLoadSlotId: _pendingAutoLoadSlot,
          onExitToMainMenu: () {
            _refreshSaves();
            setState(() {
              _stage = _BootStage.menu;
            });
          },
        );
    }
  }

  Widget _buildMainMenu() {
    final saves = _availableSaves;
    final ready = saves != null; // loading skeleton until first scan completes

    return MainMenuScreen(
      hasSaveData: ready && saves!.isNotEmpty,
      onContinue: _onContinue,
      onNewGame: () => _enterGame(),
      onLoadGame: _onLoadGame,
      onOpenSettings: () {
        // Placeholder — full menu-level settings are a follow-up;
        // Settings remain available in the pause menu in-game.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Open settings from the in-game pause menu.'),
            backgroundColor: Color(0xFF141820),
          ),
        );
      },
      onOpenCredits: () => setState(() => _stage = _BootStage.credits),
    );
  }

  void _onContinue() {
    final slot = _mostRecentSaveSlot();
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No checkpoints found yet. Start a new game.'),
          backgroundColor: Color(0xFF141820),
        ),
      );
      _refreshSaves();
      return;
    }
    _enterGame(autoLoadSlot: slot);
  }

  Future<void> _onLoadGame() async {
    await _refreshSaves();
    if (!mounted) return;
    final slots = _availableSaves;
    if (slots == null || slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No save files found. Start a new game first.'),
          backgroundColor: Color(0xFF141820),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => SaveSlotPickerDialog(
        slots: slots,
        onSlotSelected: (slotId) {
          Navigator.of(ctx).pop();
          _enterGame(autoLoadSlot: slotId);
        },
      ),
    );
  }
}
