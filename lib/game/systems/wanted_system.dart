import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

/// Categories of infractions that alert the Veyrapuram police department.
enum CrimeType {
  assaultCivilian,
  assaultOfficer,
  vehicleHitAndRun,
  recklessDriving,
  weaponDischarge,
  trespassing,
}

/// Dynamic alert and pursuit state.
enum PursuitStatus {
  inactive,
  investigating,
  pursuit,
  evading,
  arrested,
}

/// Police and Wanted Level System for VAYAL.
/// Features 0-5 stars, crime triggers, pursuit AI tracking, sight radius checks,
/// line-of-sight evasion cooldown with blinking star UI states.
/// Disabled by default so early story/conversations are peaceful.
class WantedSystem {
  int _wantedLevel = 0;
  int get wantedLevel => _wantedLevel;

  PursuitStatus status = PursuitStatus.inactive;

  /// System remains dormant until enabled by a crime or story mission.
  bool isEnabled = false;

  double evasionTimer = 0.0;
  final double evasionCooldownPerStar = 12.0; // Seconds to lose 1 star while hidden
  final double policeSightRange = 20.0; // Distance within which police detect player

  // Callbacks
  void Function(int oldLevel, int newLevel)? onWantedLevelChanged;
  void Function(CrimeType crime, String description)? onCrimeReported;
  void Function(PursuitStatus status)? onPursuitStatusChanged;
  void Function()? onPursuitEvaded;

  /// Whether stars should blink on the HUD (indicating evasion / cooldown mode).
  bool get isEvading => status == PursuitStatus.evading && _wantedLevel > 0;

  /// Reports a crime committed by the player, activating the police response.
  void reportCrime(CrimeType crime, {String? customDescription}) {
    isEnabled = true;
    final oldLevel = _wantedLevel;

    int starsToAdd = 1;
    String description = customDescription ?? '';

    switch (crime) {
      case CrimeType.assaultCivilian:
        starsToAdd = 1;
        description = 'Assault reported on civilian bystander';
        break;
      case CrimeType.assaultOfficer:
        starsToAdd = 2;
        description = 'Assault on active duty police officer';
        break;
      case CrimeType.vehicleHitAndRun:
        starsToAdd = 2;
        description = 'Vehicular hit-and-run with pedestrian';
        break;
      case CrimeType.recklessDriving:
        starsToAdd = 1;
        description = 'High speed reckless driving in town';
        break;
      case CrimeType.weaponDischarge:
        starsToAdd = 2;
        description = 'Shots fired in public sector';
        break;
      case CrimeType.trespassing:
        starsToAdd = 1;
        description = 'Trespassing in restricted territory';
        break;
    }

    _wantedLevel = math.min(5, math.max(1, _wantedLevel + starsToAdd));
    status = PursuitStatus.pursuit;
    evasionTimer = evasionCooldownPerStar;

    onCrimeReported?.call(crime, description);
    if (oldLevel != _wantedLevel) {
      onWantedLevelChanged?.call(oldLevel, _wantedLevel);
    }
    onPursuitStatusChanged?.call(status);
  }

  /// Sets wanted level directly (e.g. for story missions requiring a police chase).
  void setWantedLevel(int level) {
    final oldLevel = _wantedLevel;
    _wantedLevel = level.clamp(0, 5);
    isEnabled = _wantedLevel > 0;
    status = _wantedLevel > 0 ? PursuitStatus.pursuit : PursuitStatus.inactive;
    evasionTimer = evasionCooldownPerStar;

    if (oldLevel != _wantedLevel) {
      onWantedLevelChanged?.call(oldLevel, _wantedLevel);
      onPursuitStatusChanged?.call(status);
    }
  }

  /// Clears wanted level completely and restores calm.
  void clearWantedLevel() {
    final oldLevel = _wantedLevel;
    _wantedLevel = 0;
    status = PursuitStatus.inactive;
    evasionTimer = 0.0;
    if (oldLevel != 0) {
      onWantedLevelChanged?.call(oldLevel, 0);
      onPursuitStatusChanged?.call(status);
    }
  }

  /// Updates police awareness, sight range checks, and evasion cooldown decay.
  void update({
    required double dt,
    required three.Vector3 playerPosition,
    required List<three.Vector3> policePositions,
  }) {
    if (!isEnabled || _wantedLevel <= 0) {
      if (status != PursuitStatus.inactive) {
        status = PursuitStatus.inactive;
        onPursuitStatusChanged?.call(status);
      }
      return;
    }

    // Check if any police officer has visual detection on player
    bool spottedByPolice = false;
    for (final officerPos in policePositions) {
      final dx = playerPosition.x - officerPos.x;
      final dz = playerPosition.z - officerPos.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist <= policeSightRange) {
        spottedByPolice = true;
        break;
      }
    }

    if (spottedByPolice) {
      // In sight: active pursuit!
      if (status != PursuitStatus.pursuit) {
        status = PursuitStatus.pursuit;
        onPursuitStatusChanged?.call(status);
      }
      evasionTimer = evasionCooldownPerStar; // Reset cooldown timer
    } else {
      // Out of sight: evading police search
      if (status != PursuitStatus.evading) {
        status = PursuitStatus.evading;
        onPursuitStatusChanged?.call(status);
      }

      evasionTimer -= dt;
      if (evasionTimer <= 0) {
        // Lost 1 star!
        final oldLevel = _wantedLevel;
        _wantedLevel--;

        if (_wantedLevel <= 0) {
          _wantedLevel = 0;
          status = PursuitStatus.inactive;
          onWantedLevelChanged?.call(oldLevel, 0);
          onPursuitStatusChanged?.call(status);
          onPursuitEvaded?.call();
        } else {
          evasionTimer = evasionCooldownPerStar;
          onWantedLevelChanged?.call(oldLevel, _wantedLevel);
        }
      }
    }
  }
}
