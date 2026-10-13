import '../systems/game_state.dart';
import 'story_choice.dart';

/// Phase 14: Story Choice System managing persistent story decisions,
/// faction alignments (Police Trust, Criminal Reputation, Family Loyalty),
/// narrative branches, and ending determination.
class StoryChoiceSystem {
  int policeTrust;
  int criminalReputation;
  int familyLoyalty;

  final List<StoryChoiceRecord> history = [];

  // Callbacks
  void Function(StoryChoiceRecord record)? onChoiceRecorded;
  void Function(int policeTrust, int criminalRep, int familyLoyalty)? onAlignmentUpdated;

  StoryChoiceSystem({
    this.policeTrust = 15,
    this.criminalReputation = 40,
    this.familyLoyalty = 50,
  });

  /// Executes a story choice, persisting flags in GameState and modifying alignments.
  void recordChoice(StoryChoiceRecord choice, GameState gameState) {
    history.add(choice);

    // Apply persistent flags to GameState
    choice.flags.forEach((key, value) {
      gameState.setFlag(key, value);
    });

    // Update alignment scores (clamped between 0 and 100)
    policeTrust = (policeTrust + choice.policeTrustDelta).clamp(0, 100);
    criminalReputation = (criminalReputation + choice.criminalRepDelta).clamp(0, 100);
    familyLoyalty = (familyLoyalty + choice.familyLoyaltyDelta).clamp(0, 100);

    // Also sync to persistent flags for save system readiness
    gameState.setFlag('police_trust', policeTrust);
    gameState.setFlag('criminal_reputation', criminalReputation);
    gameState.setFlag('family_loyalty', familyLoyalty);

    onChoiceRecorded?.call(choice);
    onAlignmentUpdated?.call(policeTrust, criminalReputation, familyLoyalty);
  }

  /// Checks if a specific choice has been made.
  bool hasChoice(ChoiceId choiceId) {
    return history.any((rec) => rec.id == choiceId);
  }

  /// Evaluates which of the 3 major game endings Aadi is currently heading towards.
  PredictedEnding calculatePredictedEnding() {
    // If player prioritizes family and rejects crime
    if (familyLoyalty >= 65 && criminalReputation < 45) {
      return PredictedEnding.walkAway;
    }

    // If player gathers evidence and builds high trust with police officer Raghav
    if (policeTrust >= 55 && familyLoyalty >= 40) {
      return PredictedEnding.exposeEverything;
    }

    // If player leans into criminal violence, underworld dominance, or revenge
    if (criminalReputation >= 55) {
      return PredictedEnding.revenge;
    }

    // Default based on highest relative alignment
    if (familyLoyalty >= policeTrust && familyLoyalty >= criminalReputation) {
      return PredictedEnding.walkAway;
    } else if (policeTrust >= criminalReputation) {
      return PredictedEnding.exposeEverything;
    } else {
      return PredictedEnding.revenge;
    }
  }

  /// Human-readable title for the predicted ending.
  String get predictedEndingTitle {
    switch (calculatePredictedEnding()) {
      case PredictedEnding.walkAway:
        return 'ENDING A: WALK AWAY (Fresh Start)';
      case PredictedEnding.revenge:
        return 'ENDING B: REVENGE (Embrace the Underworld)';
      case PredictedEnding.exposeEverything:
        return 'ENDING C: EXPOSE EVERYTHING (Justice for Ravi)';
    }
  }
}
