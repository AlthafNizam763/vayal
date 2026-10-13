/// Represents a deductive case lead formed by connecting evidentiary clues.
class InvestigationLead {
  final String id;
  final String title;
  final String hypothesis;
  final Set<String> requiredClueIds;
  final String breakthroughTitle;
  final String breakthroughDescription;
  final String? storyFlagKey;
  final String? rewardMissionId;

  bool isSolved;
  DateTime? solvedAt;

  InvestigationLead({
    required this.id,
    required this.title,
    required this.hypothesis,
    required Set<String> requiredClueIds,
    required this.breakthroughTitle,
    required this.breakthroughDescription,
    this.storyFlagKey,
    this.rewardMissionId,
    this.isSolved = false,
    this.solvedAt,
  }) : requiredClueIds = Set.unmodifiable(requiredClueIds);

  /// Checks if a set of selected clue IDs satisfies this lead's required evidence.
  bool matches(Iterable<String> clueIds) {
    final candidateSet = clueIds.toSet();
    if (candidateSet.length != requiredClueIds.length) return false;
    return candidateSet.containsAll(requiredClueIds);
  }

  void solve([DateTime? timestamp]) {
    isSolved = true;
    solvedAt = timestamp ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isSolved': isSolved,
        'solvedAt': solvedAt?.toIso8601String(),
      };
}
