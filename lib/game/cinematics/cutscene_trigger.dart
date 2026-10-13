import '../story/story_flag_manager.dart';

/// Identifies when a cutscene should fire relative to story events.
enum CutsceneTriggerEvent {
  missionStart,
  missionComplete,
  storyFlagSet,
  actTransition,
  playerArrival,
}

/// Links a story condition to a cinematic sequence ID.
class CutsceneTrigger {
  final String cinematicId;
  final CutsceneTriggerEvent event;

  /// For [missionStart] / [missionComplete]: the mission ID.
  final String? missionId;

  /// For [storyFlagSet]: the flag key and required value.
  final String? flagKey;
  final dynamic flagValue;

  /// Whether this trigger can only fire once per campaign.
  final bool oneShot;

  bool _fired = false;

  CutsceneTrigger({
    required this.cinematicId,
    required this.event,
    this.missionId,
    this.flagKey,
    this.flagValue,
    this.oneShot = true,
  });

  bool get hasFired => _fired;

  void markFired() => _fired = true;

  void reset() => _fired = false;
}

/// Phase 43: Central registry and evaluator of all cutscene triggers.
///
/// Call [checkMissionStart], [checkMissionComplete], or [checkFlagChanged]
/// from the appropriate managers; when a trigger fires, [onTrigger] is called
/// with the cinematic sequence ID so VayalGame can start CinematicManager.
class CutsceneTriggerSystem {
  final List<CutsceneTrigger> _triggers = [];
  void Function(String cinematicId)? onTrigger;

  CutsceneTriggerSystem() {
    _registerDefaults();
  }

  // ─── Registration ────────────────────────────────────────────────────────────

  void addTrigger(CutsceneTrigger trigger) => _triggers.add(trigger);

  void _registerDefaults() {
    // Act I cinematics
    _triggers.add(CutsceneTrigger(
      cinematicId: 'intro_arrival',
      event: CutsceneTriggerEvent.missionStart,
      missionId: 'mission_01_homecoming',
    ));
    _triggers.add(CutsceneTrigger(
      cinematicId: 'porch_reveal',
      event: CutsceneTriggerEvent.missionStart,
      missionId: 'mission_03_shadows_on_porch',
    ));

    // Act II — photograph reveal fires when informant mission completes
    _triggers.add(CutsceneTrigger(
      cinematicId: 'photograph_reveal',
      event: CutsceneTriggerEvent.missionComplete,
      missionId: 'mission_03_shadows_on_porch',
    ));

    // Act III — Berth 4 establishing shot
    _triggers.add(CutsceneTrigger(
      cinematicId: 'berth4_establishing',
      event: CutsceneTriggerEvent.missionStart,
      missionId: 'mission_04_cold_trail_berth4',
    ));

    // Act IV — Rahu highway confrontation
    _triggers.add(CutsceneTrigger(
      cinematicId: 'rahu_confrontation_intro',
      event: CutsceneTriggerEvent.missionStart,
      missionId: 'mission_16_rahu_ultimatum',
    ));

    // Story flag: father's truth discovered → reveal cinematic
    _triggers.add(CutsceneTrigger(
      cinematicId: 'father_truth_reveal',
      event: CutsceneTriggerEvent.storyFlagSet,
      flagKey: StoryFlagManager.fatherTruthDiscovered,
      flagValue: true,
    ));

    // Story flag: video discovered → video reveal cinematic
    _triggers.add(CutsceneTrigger(
      cinematicId: 'truth_video_reveal',
      event: CutsceneTriggerEvent.storyFlagSet,
      flagKey: StoryFlagManager.truthVideoDiscovered,
      flagValue: true,
    ));

    // Act V — Devraj final confrontation
    _triggers.add(CutsceneTrigger(
      cinematicId: 'devraj_final_confrontation',
      event: CutsceneTriggerEvent.missionStart,
      missionId: 'mission_30_vayal_reckoning',
    ));

    // Act transition cards
    for (final entry in {
      'act2': 'act2_transition',
      'act3': 'act3_transition',
      'act4': 'act4_transition',
      'act5': 'act5_transition',
    }.entries) {
      _triggers.add(CutsceneTrigger(
        cinematicId: entry.value,
        event: CutsceneTriggerEvent.actTransition,
        flagKey: 'act_transition_id',
        flagValue: entry.key,
      ));
    }
  }

  // ─── Evaluation ──────────────────────────────────────────────────────────────

  /// Called by MissionManager.onMissionStarted.
  void checkMissionStart(String missionId) {
    _evaluate(
      (t) =>
          t.event == CutsceneTriggerEvent.missionStart &&
          t.missionId == missionId,
    );
  }

  /// Called by MissionManager.onMissionCompleted.
  void checkMissionComplete(String missionId) {
    _evaluate(
      (t) =>
          t.event == CutsceneTriggerEvent.missionComplete &&
          t.missionId == missionId,
    );
  }

  /// Called by StoryFlagManager.onFlagChanged.
  void checkFlagChanged(String key, dynamic value) {
    _evaluate(
      (t) =>
          t.event == CutsceneTriggerEvent.storyFlagSet &&
          t.flagKey == key &&
          t.flagValue == value,
    );
  }

  /// Called by StoryActManager.onActChanged with act identifier ('act2'...'act5').
  void checkActTransition(String actId) {
    _evaluate(
      (t) =>
          t.event == CutsceneTriggerEvent.actTransition &&
          t.flagValue == actId,
    );
  }

  void _evaluate(bool Function(CutsceneTrigger t) condition) {
    for (final trigger in _triggers) {
      if (trigger.oneShot && trigger.hasFired) continue;
      if (condition(trigger)) {
        if (trigger.oneShot) trigger.markFired();
        onTrigger?.call(trigger.cinematicId);
        break; // Only fire first matching trigger per event
      }
    }
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────

  List<String> firedIds() =>
      _triggers.where((t) => t.hasFired).map((t) => t.cinematicId).toList();

  void restoreFired(List<String> ids) {
    for (final t in _triggers) {
      if (ids.contains(t.cinematicId)) t.markFired();
    }
  }

  void resetAll() {
    for (final t in _triggers) {
      t.reset();
    }
  }
}
