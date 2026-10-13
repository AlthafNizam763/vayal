import 'mission_objective.dart';

/// Progression state of a mission.
enum MissionStatus {
  locked,
  available,
  active,
  completed,
  failed,
}

/// Rewards granted upon completing a mission.
class MissionReward {
  final int money;
  final int reputation;
  final List<String> items;
  final Map<String, dynamic> storyFlags;

  const MissionReward({
    this.money = 0,
    this.reputation = 0,
    this.items = const [],
    this.storyFlags = const {},
  });
}

/// Reusable mission structure supporting multiple sequential or optional objectives,
/// dialogue integration, failure conditions, and rewards.
class Mission {
  final String id;
  final String title;
  final String description;
  final List<MissionObjective> objectives;
  final MissionReward reward;
  final String? nextMissionId;

  MissionStatus status;
  int currentObjectiveIndex = 0;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.objectives,
    this.reward = const MissionReward(),
    this.nextMissionId,
    this.status = MissionStatus.available,
  });

  /// The currently active objective in this mission.
  MissionObjective? get currentObjective {
    if (status != MissionStatus.active || objectives.isEmpty) return null;
    if (currentObjectiveIndex >= 0 && currentObjectiveIndex < objectives.length) {
      return objectives[currentObjectiveIndex];
    }
    return null;
  }

  bool get isAllObjectivesCompleted =>
      objectives.every((obj) => obj.isCompleted || obj.isOptional);

  void start() {
    status = MissionStatus.active;
    currentObjectiveIndex = 0;
  }

  /// Advances to next objective or completes mission if all are done.
  bool advanceObjective() {
    if (currentObjectiveIndex < objectives.length) {
      objectives[currentObjectiveIndex].isCompleted = true;
    }

    // Find next uncompleted objective
    for (int i = 0; i < objectives.length; i++) {
      if (!objectives[i].isCompleted && !objectives[i].isOptional) {
        currentObjectiveIndex = i;
        return false;
      }
    }

    // All objectives fulfilled
    status = MissionStatus.completed;
    return true;
  }

  void complete() {
    for (final obj in objectives) {
      obj.isCompleted = true;
    }
    status = MissionStatus.completed;
  }

  void fail() {
    status = MissionStatus.failed;
  }
}
