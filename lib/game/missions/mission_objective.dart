import 'package:three_js/three_js.dart' as three;

/// Categories of mission objectives supported in VAYAL.
enum ObjectiveType {
  reachLocation,
  talkToNpc,
  interactObject,
  enterBuilding,
  collectItem,
  followNpc,
  escapeArea,
  defeatEnemy,
  driveToLocation,
  makeDecision,
}

/// An individual step or objective within a mission.
class MissionObjective {
  final String id;
  final String description;
  final ObjectiveType type;
  final three.Vector3? targetLocation;
  final double locationTolerance;
  final String? targetNpcId;
  final String? targetObjectId;
  final bool isOptional;

  bool isCompleted;

  MissionObjective({
    required this.id,
    required this.description,
    required this.type,
    this.targetLocation,
    this.locationTolerance = 4.0,
    this.targetNpcId,
    this.targetObjectId,
    this.isOptional = false,
    this.isCompleted = false,
  });

  /// Evaluates if a given location satisfies this objective.
  bool checkLocation(three.Vector3 playerPos) {
    if (isCompleted || type != ObjectiveType.reachLocation || targetLocation == null) {
      return false;
    }
    final dx = playerPos.x - targetLocation!.x;
    final dz = playerPos.z - targetLocation!.z;
    final distance = (dx * dx + dz * dz);
    return distance <= (locationTolerance * locationTolerance);
  }

  /// Evaluates if an NPC interaction satisfies this objective.
  bool checkNpcTalk(String npcId) {
    if (isCompleted || type != ObjectiveType.talkToNpc) {
      return false;
    }
    return targetNpcId == npcId;
  }

  /// Evaluates if an object interaction satisfies this objective.
  bool checkObjectInteract(String objectId) {
    if (isCompleted ||
        (type != ObjectiveType.interactObject && type != ObjectiveType.enterBuilding)) {
      return false;
    }
    return targetObjectId == objectId;
  }
}
