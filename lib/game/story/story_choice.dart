/// Predefined major narrative choice identifiers across the 5 acts of VAYAL.
enum ChoiceId {
  confidedInMeera,
  keptSecretsFromMeera,
  sparedInformant,
  silencedInformant,
  reportedBerth4ToPolice,
  raidedBerth4Alone,
  trustedRahu,
  betrayedRahu,
  walkAwayWithFamily,
  avengeFatherBlood,
  exposeDevrajSyndicate,
}

/// Predicted narrative climax ending.
enum PredictedEnding {
  walkAway, // Ending A: Leave criminal past, protect family
  revenge, // Ending B: Embrace violence, eliminate Devraj
  exposeEverything, // Ending C: Hand evidence to Raghav, dismantle syndicate legally
}

/// A recorded pivotal narrative decision made by Aadi.
class StoryChoiceRecord {
  final ChoiceId id;
  final String title;
  final String description;
  final int actNumber;
  final Map<String, dynamic> flags;
  final int policeTrustDelta;
  final int criminalRepDelta;
  final int familyLoyaltyDelta;
  final DateTime timestamp;

  StoryChoiceRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.actNumber,
    required this.flags,
    this.policeTrustDelta = 0,
    this.criminalRepDelta = 0,
    this.familyLoyaltyDelta = 0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
