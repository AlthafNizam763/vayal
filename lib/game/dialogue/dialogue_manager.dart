import '../../data/dialogue/dialogue_data.dart';
import 'dialogue.dart';

/// Central state manager for interactive dialogue, story flags,
/// character relationship scores, and branching narratives.
class DialogueManager {
  DialogueTree? currentTree;
  DialogueNode? currentNode;

  // Persistent story flags (crime thriller choices, investigation clues)
  final Map<String, dynamic> storyFlags = {};

  // Character affinity / trust scores (0 to 100)
  final Map<String, int> relationships = {
    'meera': 60,
    'diya': 35,
    'balan': 50,
    'rahu': 20,
    'devraj': 0,
  };

  // Choice history log
  final List<String> choiceHistory = [];

  // Event callbacks
  void Function(String missionId)? onMissionTriggered;
  void Function(String missionId)? onMissionUnlocked;
  void Function(String missionId)? onMissionLocked;
  void Function(DialogueNode node)? onNodeChanged;
  void Function(DialogueChoice choice)? onChoiceSelected;
  void Function(int repDelta, int policeTrustDelta, int criminalRepDelta)? onAlignmentDelta;
  void Function()? onDialogueClosed;
  void Function(String flagKey, dynamic flagValue)? onStoryFlagChanged;

  bool get isDialogueActive => currentTree != null && currentNode != null;

  /// Starts a dialogue sequence from a pre-registered tree ID.
  bool startDialogueById(String treeId) {
    final tree = DialogueData.getTree(treeId);
    if (tree == null) return false;
    return startDialogue(tree);
  }

  /// Starts a dialogue sequence from a DialogueTree instance.
  bool startDialogue(DialogueTree tree) {
    currentTree = tree;
    final initialNode = tree.initialNode;
    if (initialNode == null) {
      closeDialogue();
      return false;
    }

    _setCurrentNode(initialNode);
    return true;
  }

  void _setCurrentNode(DialogueNode node) {
    currentNode = node;

    // Apply entry flags
    if (node.setFlagsOnEnter != null) {
      storyFlags.addAll(node.setFlagsOnEnter!);
      node.setFlagsOnEnter!.forEach((k, v) => onStoryFlagChanged?.call(k, v));
    }

    // Apply entry relationship deltas
    if (node.relationshipDeltasOnEnter != null) {
      for (final entry in node.relationshipDeltasOnEnter!.entries) {
        modifyRelationship(entry.key, entry.value);
      }
    }

    // Trigger mission hook if defined on enter
    if (node.triggerMissionOnEnter != null) {
      onMissionTriggered?.call(node.triggerMissionOnEnter!);
    }

    onNodeChanged?.call(node);
  }

  /// Handles player choice selection and applies its consequences.
  void selectChoice(DialogueChoice choice) {
    if (!isDialogueActive) return;

    choiceHistory.add(choice.id);

    // Track last choice tone in story flags
    storyFlags['last_choice_tone'] = choice.tone.name;
    storyFlags['choice_${choice.id}'] = true;
    onStoryFlagChanged?.call('last_choice_tone', choice.tone.name);
    onStoryFlagChanged?.call('choice_${choice.id}', true);

    // 1. Set story flags
    if (choice.setFlags != null) {
      storyFlags.addAll(choice.setFlags!);
      choice.setFlags!.forEach((k, v) => onStoryFlagChanged?.call(k, v));
    }

    // 2. Modify character relationships
    if (choice.relationshipDeltas != null) {
      for (final entry in choice.relationshipDeltas!.entries) {
        modifyRelationship(entry.key, entry.value);
      }
    }

    // 3. Alignments and reputation consequences
    if (choice.reputationDelta != 0 ||
        choice.policeTrustDelta != 0 ||
        choice.criminalRepDelta != 0) {
      onAlignmentDelta?.call(
        choice.reputationDelta,
        choice.policeTrustDelta,
        choice.criminalRepDelta,
      );
    }

    // 4. Trigger / unlock / lock missions
    if (choice.triggerMissionId != null) {
      onMissionTriggered?.call(choice.triggerMissionId!);
    }
    if (choice.unlockMissionId != null) {
      onMissionUnlocked?.call(choice.unlockMissionId!);
    }
    if (choice.lockMissionId != null) {
      onMissionLocked?.call(choice.lockMissionId!);
    }

    onChoiceSelected?.call(choice);

    // 5. Branch to next node or conclude dialogue
    if (choice.nextNodeId != null) {
      final next = currentTree!.getNode(choice.nextNodeId!);
      if (next != null) {
        _setCurrentNode(next);
      } else {
        closeDialogue();
      }
    } else {
      closeDialogue();
    }
  }

  /// Advances linear dialogue nodes that don't have multiple branching choices.
  void advanceLinear() {
    if (!isDialogueActive) return;

    if (currentNode!.hasChoices) {
      // If node has only 1 choice, auto-select it
      if (currentNode!.choices.length == 1) {
        selectChoice(currentNode!.choices.first);
      }
      return;
    }

    if (currentNode!.nextNodeId != null) {
      final next = currentTree!.getNode(currentNode!.nextNodeId!);
      if (next != null) {
        _setCurrentNode(next);
      } else {
        closeDialogue();
      }
    } else {
      closeDialogue();
    }
  }

  void closeDialogue() {
    currentTree = null;
    currentNode = null;
    onDialogueClosed?.call();
  }

  /// Returns valid choices filtered by current story conditions.
  List<DialogueChoice> getAvailableChoices() {
    if (currentNode == null) return [];
    return currentNode!.choices.where((c) => c.isAvailable(storyFlags)).toList();
  }

  // --- Story State Helpers ---

  bool getFlag(String key, {bool defaultValue = false}) {
    final val = storyFlags[key];
    if (val is bool) return val;
    return defaultValue;
  }

  void setFlag(String key, dynamic value) {
    storyFlags[key] = value;
  }

  int getRelationship(String characterId) {
    return relationships[characterId] ?? 50;
  }

  void modifyRelationship(String characterId, int delta) {
    final current = getRelationship(characterId);
    relationships[characterId] = (current + delta).clamp(0, 100);
  }
}
