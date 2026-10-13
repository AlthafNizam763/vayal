import 'package:three_js/three_js.dart' as three;

/// Status lifecycle for optional character side quests.
enum SideQuestStatus {
  locked,
  available,
  active,
  completed,
  failed,
}

/// An individual objective step in an optional side quest.
class SideQuestStep {
  final String id;
  final String instruction;
  final three.Vector3 targetLocation;
  final double targetRadius;
  bool isCompleted;

  SideQuestStep({
    required this.id,
    required this.instruction,
    required this.targetLocation,
    this.targetRadius = 6.0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'instruction': instruction,
    'targetLocation': {'x': targetLocation.x, 'y': targetLocation.y, 'z': targetLocation.z},
    'targetRadius': targetRadius,
    'isCompleted': isCompleted,
  };

  factory SideQuestStep.fromJson(Map<String, dynamic> json) {
    final loc = json['targetLocation'] as Map<String, dynamic>;
    return SideQuestStep(
      id: json['id'] as String,
      instruction: json['instruction'] as String,
      targetLocation: three.Vector3(
        (loc['x'] as num).toDouble(),
        (loc['y'] as num).toDouble(),
        (loc['z'] as num).toDouble(),
      ),
      targetRadius: (json['targetRadius'] as num?)?.toDouble() ?? 6.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

/// A character-driven optional side story in Veyrapuram.
class SideQuest {
  final String id;
  final String title;
  final String characterId;
  final String characterName;
  final String description;
  final List<SideQuestStep> steps;
  final int cashReward;
  final int reputationReward;
  final String rewardDescription;
  final String completionSummary;

  SideQuestStatus status;
  int currentStepIndex;

  SideQuest({
    required this.id,
    required this.title,
    required this.characterId,
    required this.characterName,
    required this.description,
    required this.steps,
    required this.cashReward,
    required this.reputationReward,
    required this.rewardDescription,
    required this.completionSummary,
    this.status = SideQuestStatus.available,
    this.currentStepIndex = 0,
  });

  SideQuestStep? get currentStep =>
      (currentStepIndex >= 0 && currentStepIndex < steps.length)
          ? steps[currentStepIndex]
          : null;

  bool get isCompleted => status == SideQuestStatus.completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'characterId': characterId,
    'characterName': characterName,
    'description': description,
    'status': status.name,
    'currentStepIndex': currentStepIndex,
    'cashReward': cashReward,
    'reputationReward': reputationReward,
    'rewardDescription': rewardDescription,
    'completionSummary': completionSummary,
    'steps': steps.map((s) => s.toJson()).toList(),
  };

  factory SideQuest.fromJson(Map<String, dynamic> json) => SideQuest(
    id: json['id'] as String,
    title: json['title'] as String,
    characterId: json['characterId'] as String,
    characterName: json['characterName'] as String,
    description: json['description'] as String,
    status: SideQuestStatus.values.byName(json['status'] as String),
    currentStepIndex: json['currentStepIndex'] as int? ?? 0,
    cashReward: json['cashReward'] as int? ?? 0,
    reputationReward: json['reputationReward'] as int? ?? 0,
    rewardDescription: json['rewardDescription'] as String? ?? '',
    completionSummary: json['completionSummary'] as String? ?? '',
    steps: (json['steps'] as List)
        .map((s) => SideQuestStep.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}
