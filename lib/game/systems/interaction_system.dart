import 'package:three_js/three_js.dart' as three;

/// Categories of interactable world entities.
enum InteractableType {
  door,
  npc,
  vehicle,
  itemPickup,
  shop,
  missionObject,
  document,
  container,
  phone,
}

/// Context provided to an interactable when interaction is requested.
class InteractionContext {
  final three.Vector3 playerPosition;
  final Map<String, dynamic> storyFlags;
  final int playerMoney;

  const InteractionContext({
    required this.playerPosition,
    required this.storyFlags,
    required this.playerMoney,
  });
}

/// Result returned after executing an interaction.
class InteractionResult {
  final bool success;
  final String? message;
  final String? triggerDialogueTreeId;
  final String? triggerMissionId;
  final String? collectedItemId;

  const InteractionResult({
    required this.success,
    this.message,
    this.triggerDialogueTreeId,
    this.triggerMissionId,
    this.collectedItemId,
  });

  const InteractionResult.success([this.message])
      : success = true,
        triggerDialogueTreeId = null,
        triggerMissionId = null,
        collectedItemId = null;

  const InteractionResult.failure(this.message)
      : success = false,
        triggerDialogueTreeId = null,
        triggerMissionId = null,
        collectedItemId = null;
}

/// Universal contract for any interactive element in Veyrapuram.
abstract class Interactable {
  String get id;
  String get name;
  InteractableType get type;
  three.Vector3 get position;
  double get interactionRadius => 2.8;
  String get prompt;

  bool canInteract(InteractionContext context) => true;
  InteractionResult onInteract(InteractionContext context);
}

/// Universal manager that scans, highlights, and dispatches interactions.
class InteractionSystem {
  final List<Interactable> _interactables = [];

  void register(Interactable interactable) {
    _interactables.removeWhere((i) => i.id == interactable.id);
    _interactables.add(interactable);
  }

  void unregister(String id) {
    _interactables.removeWhere((i) => i.id == id);
  }

  void clear() {
    _interactables.clear();
  }

  /// Finds the closest valid interactable within its interaction radius.
  Interactable? findClosestInteractable(InteractionContext context) {
    Interactable? closest;
    double minDistanceSq = double.infinity;

    for (final item in _interactables) {
      if (!item.canInteract(context)) continue;

      final dx = context.playerPosition.x - item.position.x;
      final dz = context.playerPosition.z - item.position.z;
      final distSq = (dx * dx + dz * dz);

      final maxRadiusSq = item.interactionRadius * item.interactionRadius;
      if (distSq <= maxRadiusSq && distSq < minDistanceSq) {
        minDistanceSq = distSq;
        closest = item;
      }
    }

    return closest;
  }

  /// Executes interaction with the given target or the nearest target.
  InteractionResult executeInteraction(Interactable target, InteractionContext context) {
    if (!target.canInteract(context)) {
      return const InteractionResult.failure("Cannot interact right now.");
    }
    return target.onInteract(context);
  }
}
