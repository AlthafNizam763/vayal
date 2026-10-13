import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../inventory/inventory.dart';
import '../systems/game_state.dart';
import 'side_quest.dart';
import 'side_quest_database.dart';

/// Central manager for tracking optional, character-driven side stories in VAYAL.
/// Side stories provide optional immersion, rewards, and reputation without blocking
/// main story acts or endings.
class SideQuestManager {
  final List<SideQuest> quests;

  void Function(SideQuest quest)? onQuestStarted;
  void Function(SideQuest quest, SideQuestStep completedStep)? onQuestStepAdvanced;
  void Function(SideQuest quest)? onQuestCompleted;

  SideQuestManager({List<SideQuest>? initialQuests})
      : quests = initialQuests ?? SideQuestDatabase.allQuests;

  SideQuest? get activeQuest =>
      quests.cast<SideQuest?>().firstWhere(
        (q) => q?.status == SideQuestStatus.active,
        orElse: () => null,
      );

  List<SideQuest> get availableQuests =>
      quests.where((q) => q.status == SideQuestStatus.available).toList();

  List<SideQuest> get completedQuests =>
      quests.where((q) => q.status == SideQuestStatus.completed).toList();

  SideQuest? getQuest(String id) {
    return quests.cast<SideQuest?>().firstWhere(
      (q) => q?.id == id,
      orElse: () => null,
    );
  }

  /// Begins tracking an available side quest.
  bool startQuest(String id) {
    final quest = getQuest(id);
    if (quest == null || quest.status == SideQuestStatus.completed) return false;

    // Set any currently active side quest back to available
    for (final q in quests) {
      if (q.status == SideQuestStatus.active && q.id != id) {
        q.status = SideQuestStatus.available;
      }
    }

    quest.status = SideQuestStatus.active;
    onQuestStarted?.call(quest);
    return true;
  }

  /// Checks if player is within reach of active quest objective target.
  SideQuestStep? checkLocationObjectives(
    three.Vector3 playerPosition, {
    GameState? gameState,
    Inventory? inventory,
  }) {
    final current = activeQuest;
    if (current == null) return null;

    final step = current.currentStep;
    if (step == null || step.isCompleted) return null;

    final dist = math.sqrt(
      math.pow(playerPosition.x - step.targetLocation.x, 2) +
          math.pow(playerPosition.z - step.targetLocation.z, 2),
    );

    if (dist <= step.targetRadius) {
      advanceQuestStep(current.id, gameState: gameState, inventory: inventory);
      return step;
    }

    return null;
  }

  /// Advances the current objective step of a side quest.
  bool advanceQuestStep(
    String id, {
    GameState? gameState,
    Inventory? inventory,
  }) {
    final quest = getQuest(id);
    if (quest == null || quest.status != SideQuestStatus.active) return false;

    final step = quest.currentStep;
    if (step != null) {
      step.isCompleted = true;
      onQuestStepAdvanced?.call(quest, step);
    }

    if (quest.currentStepIndex < quest.steps.length - 1) {
      quest.currentStepIndex++;
      return true;
    } else {
      completeQuest(id, gameState: gameState, inventory: inventory);
      return true;
    }
  }

  /// Completes a side quest and awards rewards to GameState and Inventory.
  bool completeQuest(
    String id, {
    GameState? gameState,
    Inventory? inventory,
  }) {
    final quest = getQuest(id);
    if (quest == null) return false;

    quest.status = SideQuestStatus.completed;

    if (gameState != null) {
      gameState.addMoney(quest.cashReward);
      gameState.addReputation(quest.reputationReward);
    }

    onQuestCompleted?.call(quest);
    return true;
  }
}
