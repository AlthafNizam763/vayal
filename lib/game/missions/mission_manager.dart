import 'package:three_js/three_js.dart' as three;
import '../../data/missions/mission_data.dart';
import 'mission.dart';
import 'mission_objective.dart';

/// Central manager orchestrating story missions, objective tracking,
/// completion states, rewards, and checkpoint saves.
class MissionManager {
  final Map<String, Mission> missions = {};
  Mission? activeMission;
  final List<String> completedMissions = [];

  int playerMoney = 0;
  int playerReputation = 0;
  bool isCheckpointSaved = false;

  // Event callbacks
  void Function(Mission mission)? onMissionStarted;
  void Function(Mission mission, MissionObjective completedObj)? onObjectiveCompleted;
  void Function(Mission mission)? onMissionCompleted;

  MissionManager() {
    initializeMissions();
  }

  void initializeMissions() {
    missions.clear();
    missions.addAll(MissionData.getAllMissions());

    // Automatically activate Mission 01: Homecoming as the starting mission
    startMission('mission_01_homecoming');
  }

  /// Begins a mission by ID.
  bool startMission(String missionId) {
    final mission = missions[missionId];
    if (mission == null) return false;

    activeMission = mission;
    mission.start();
    onMissionStarted?.call(mission);
    return true;
  }

  /// Checks if player's current coordinate completes a location objective.
  void checkLocation(three.Vector3 playerPos) {
    final objective = activeMission?.currentObjective;
    if (objective == null || objective.type != ObjectiveType.reachLocation) {
      return;
    }

    if (objective.checkLocation(playerPos)) {
      _advanceObjective(objective);
    }
  }

  /// Evaluates NPC interaction against active objective.
  void notifyNpcTalked(String npcId) {
    final objective = activeMission?.currentObjective;
    if (objective == null || objective.type != ObjectiveType.talkToNpc) {
      return;
    }

    if (objective.checkNpcTalk(npcId)) {
      _advanceObjective(objective);
    }
  }

  /// Evaluates world object or building interaction against active objective.
  void notifyObjectInteracted(String objectId) {
    final objective = activeMission?.currentObjective;
    if (objective == null) return;

    if (objective.checkObjectInteract(objectId)) {
      _advanceObjective(objective);
    }
  }

  void _advanceObjective(MissionObjective completedObj) {
    if (activeMission == null) return;

    onObjectiveCompleted?.call(activeMission!, completedObj);

    final isMissionComplete = activeMission!.advanceObjective();

    if (isMissionComplete) {
      _completeActiveMission();
    }
  }

  void _completeActiveMission() {
    if (activeMission == null) return;

    final completedMission = activeMission!;
    completedMissions.add(completedMission.id);

    // Apply rewards
    playerMoney += completedMission.reward.money;
    playerReputation += completedMission.reward.reputation;

    // Trigger Checkpoint Save
    isCheckpointSaved = true;

    onMissionCompleted?.call(completedMission);

    // If next mission exists, queue it as available or active
    final nextId = completedMission.nextMissionId;
    if (nextId != null && missions.containsKey(nextId)) {
      final nextMission = missions[nextId]!;
      nextMission.status = MissionStatus.active;
      activeMission = nextMission;
      activeMission!.start();
      onMissionStarted?.call(activeMission!);
    } else {
      activeMission = null;
    }
  }
}
