import 'package:flutter/material.dart';

/// Phase 41: Categorization of dialogue choice tones and player conversational postures.
enum DialogueTone {
  friendly,
  neutral,
  threat,
  lie,
  persuasion,
  silence;

  String get displayName {
    switch (this) {
      case DialogueTone.friendly:
        return 'Friendly';
      case DialogueTone.neutral:
        return 'Neutral';
      case DialogueTone.threat:
        return 'Threat';
      case DialogueTone.lie:
        return 'Lie';
      case DialogueTone.persuasion:
        return 'Persuasion';
      case DialogueTone.silence:
        return 'Silence';
    }
  }

  String get tagLabel {
    switch (this) {
      case DialogueTone.friendly:
        return '[FRIENDLY]';
      case DialogueTone.neutral:
        return '[NEUTRAL]';
      case DialogueTone.threat:
        return '[THREAT]';
      case DialogueTone.lie:
        return '[LIE]';
      case DialogueTone.persuasion:
        return '[PERSUADE]';
      case DialogueTone.silence:
        return '[SILENCE]';
    }
  }

  Color get color {
    switch (this) {
      case DialogueTone.friendly:
        return const Color(0xFF26A69A); // Teal / Compassion
      case DialogueTone.neutral:
        return const Color(0xFF78909C); // Cool Slate / Pragmatic
      case DialogueTone.threat:
        return const Color(0xFFE53935); // Crimson / Intimidation
      case DialogueTone.lie:
        return const Color(0xFFAB47BC); // Purple / Deception
      case DialogueTone.persuasion:
        return const Color(0xFFFFA726); // Warm Amber / Charisma
      case DialogueTone.silence:
        return const Color(0xFF42A5F5); // Muted Sky Blue / Stoic
    }
  }

  IconData get icon {
    switch (this) {
      case DialogueTone.friendly:
        return Icons.favorite_border_rounded;
      case DialogueTone.neutral:
        return Icons.chat_bubble_outline_rounded;
      case DialogueTone.threat:
        return Icons.warning_amber_rounded;
      case DialogueTone.lie:
        return Icons.masks_outlined;
      case DialogueTone.persuasion:
        return Icons.record_voice_over_outlined;
      case DialogueTone.silence:
        return Icons.more_horiz_rounded;
    }
  }
}

/// A branching option presented to the player during a dialogue.
class DialogueChoice {
  final String id;
  final String text;
  final DialogueTone tone;
  final String? nextNodeId;
  final Map<String, dynamic>? setFlags;
  final Map<String, int>? relationshipDeltas;
  final int reputationDelta;
  final int policeTrustDelta;
  final int criminalRepDelta;
  final String? consequencePreview;
  final String? triggerMissionId;
  final String? unlockMissionId;
  final String? lockMissionId;
  final bool Function(Map<String, dynamic> storyFlags)? condition;

  const DialogueChoice({
    required this.id,
    required this.text,
    this.tone = DialogueTone.neutral,
    this.nextNodeId,
    this.setFlags,
    this.relationshipDeltas,
    this.reputationDelta = 0,
    this.policeTrustDelta = 0,
    this.criminalRepDelta = 0,
    this.consequencePreview,
    this.triggerMissionId,
    this.unlockMissionId,
    this.lockMissionId,
    this.condition,
  });

  /// Evaluates whether this choice is available given current story flags.
  bool isAvailable(Map<String, dynamic> flags) {
    if (condition == null) return true;
    return condition!(flags);
  }
}

/// A single step in a dialogue sequence.
class DialogueNode {
  final String id;
  final String speaker;
  final String text;
  final String? emotion;
  final String? nextNodeId;
  final List<DialogueChoice> choices;
  final Map<String, dynamic>? setFlagsOnEnter;
  final Map<String, int>? relationshipDeltasOnEnter;
  final String? triggerMissionOnEnter;

  const DialogueNode({
    required this.id,
    required this.speaker,
    required this.text,
    this.emotion,
    this.nextNodeId,
    this.choices = const [],
    this.setFlagsOnEnter,
    this.relationshipDeltasOnEnter,
    this.triggerMissionOnEnter,
  });

  bool get hasChoices => choices.isNotEmpty;
}

/// A complete structured dialogue sequence with branching paths.
class DialogueTree {
  final String id;
  final String initialNodeId;
  final Map<String, DialogueNode> nodes;

  const DialogueTree({
    required this.id,
    required this.initialNodeId,
    required this.nodes,
  });

  DialogueNode? get initialNode => nodes[initialNodeId];
  DialogueNode? getNode(String nodeId) => nodes[nodeId];
}
