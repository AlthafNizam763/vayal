import 'dart:math' as math;
import 'lock_data.dart';

/// Mechanics controller for the interactive lockpicking mini-game.
/// Simulates bobby pin angular alignment, tension wrench torque,
/// tumbler binding resistance, pin shear fatigue, and audible tumbler releases.
class LockpickingSession {
  final LockData lock;

  double pickAngle = 90.0; // 0° to 180°
  double cylinderAngle = 0.0; // 0° to 90° (90° triggers unlock)
  double stress = 0.0; // 0.0 to 100.0%
  int picksRemaining;

  bool isTurning = false;
  bool isUnlocked = false;
  bool isPickBroken = false;

  // Callbacks
  void Function()? onLockOpened;
  void Function()? onPickBroke;
  void Function(double stress)? onStressChanged;

  LockpickingSession({
    required this.lock,
    this.picksRemaining = 5,
  }) {
    isUnlocked = lock.isUnlocked;
  }

  /// Sets pick angle along the keyhole arc (0° left to 180° right).
  void setPickAngle(double angle) {
    if (isTurning || isUnlocked || picksRemaining <= 0) return;
    pickAngle = angle.clamp(0.0, 180.0);
  }

  /// Applies torque with the tension wrench.
  void startTurning() {
    if (picksRemaining <= 0 || isUnlocked) return;
    isTurning = true;
    isPickBroken = false;
  }

  /// Releases tension wrench torque, allowing cylinder to spring back.
  void stopTurning() {
    isTurning = false;
  }

  /// Evaluates maximum cylinder rotation possible given current pick angle.
  double get maxAllowedTurnAngle {
    final diff = (pickAngle - lock.sweetSpotAngle).abs();
    if (diff <= lock.sweetSpotTolerance) {
      return 90.0;
    }
    // Resistance bound proportional to deviation from sweet spot
    final accuracy = (1.0 - (diff / 180.0)).clamp(0.0, 0.88);
    return accuracy * 55.0;
  }

  /// Main simulation tick.
  void update(double dt) {
    if (isUnlocked) return;

    final maxTurn = maxAllowedTurnAngle;

    if (isTurning && picksRemaining > 0) {
      if (cylinderAngle < maxTurn) {
        cylinderAngle = math.min(maxTurn, cylinderAngle + (85.0 * dt));
      }

      if (cylinderAngle >= 89.5) {
        cylinderAngle = 90.0;
        isUnlocked = true;
        lock.isUnlocked = true;
        isTurning = false;
        stress = 0.0;
        onLockOpened?.call();
        return;
      }

      // Cylinder is bound against resistance: stress accumulates
      if (cylinderAngle >= maxTurn && maxTurn < 89.5) {
        stress = (stress + (75.0 * dt)).clamp(0.0, 100.0);
        onStressChanged?.call(stress);

        if (stress >= 100.0) {
          picksRemaining = math.max(0, picksRemaining - 1);
          isPickBroken = true;
          stress = 0.0;
          cylinderAngle = 0.0;
          pickAngle = 90.0;
          isTurning = false;
          onPickBroke?.call();
        }
      }
    } else {
      // Releasing tension: cylinder springs back and pick stress dissipates
      if (cylinderAngle > 0.0) {
        cylinderAngle = math.max(0.0, cylinderAngle - (140.0 * dt));
      }
      if (stress > 0.0) {
        stress = math.max(0.0, stress - (120.0 * dt));
        onStressChanged?.call(stress);
      }
      isPickBroken = false;
    }
  }
}
