import '../missions/mission_manager.dart';
import '../systems/game_state.dart';
import 'story_act.dart';

/// Phase 16: Story Act Manager controlling progression across the 5 narrative acts of VAYAL.
/// Coordinates mission transitions, act intro banners, and story checkpoints.
class StoryActManager {
  StoryAct currentAct = StoryAct.act1Home;
  final List<StoryAct> completedActs = [];

  // Callbacks
  void Function(StoryAct newAct, StoryActData data)? onActChanged;

  StoryActData get currentActData => StoryActData.allActs[currentAct]!;

  /// Advances the story to a specific act, updating GameState and mission queues.
  void setAct(
    StoryAct newAct, {
    required GameState gameState,
    required MissionManager missionManager,
  }) {
    if (currentAct == newAct) return;

    if (!completedActs.contains(currentAct)) {
      completedActs.add(currentAct);
    }

    currentAct = newAct;
    final actData = currentActData;

    // Sync with GameState
    gameState.storyAct = actData.actNumber;
    gameState.setFlag('current_act_name', actData.title);

    onActChanged?.call(currentAct, actData);
  }

  /// Progresses sequentially to the next story act if available.
  bool advanceSequentialAct({
    required GameState gameState,
    required MissionManager missionManager,
  }) {
    switch (currentAct) {
      case StoryAct.act1Home:
        setAct(StoryAct.act2Ghosts, gameState: gameState, missionManager: missionManager);
        return true;
      case StoryAct.act2Ghosts:
        setAct(StoryAct.act3Blood, gameState: gameState, missionManager: missionManager);
        return true;
      case StoryAct.act3Blood:
        setAct(StoryAct.act4TheTruth, gameState: gameState, missionManager: missionManager);
        return true;
      case StoryAct.act4TheTruth:
        setAct(StoryAct.act5Vayal, gameState: gameState, missionManager: missionManager);
        return true;
      case StoryAct.act5Vayal:
        return false; // Climax act reached
    }
  }

  /// Whether a specific act has been completed.
  bool isActCompleted(StoryAct act) => completedActs.contains(act);
}
