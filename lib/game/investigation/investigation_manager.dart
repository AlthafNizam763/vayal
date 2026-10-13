import 'package:flutter/foundation.dart';
import 'clue.dart';
import 'investigation_database.dart';
import 'investigation_lead.dart';

/// Central offline investigation manager handling clue discovery,
/// evidence examination, deduction synthesis, and story breakthrough triggers.
class InvestigationManager extends ChangeNotifier {
  final List<Clue> clues;
  final List<InvestigationLead> leads;

  void Function(Clue clue)? onClueDiscovered;
  void Function(InvestigationLead lead)? onLeadSolved;

  InvestigationManager({
    List<Clue>? initialClues,
    List<InvestigationLead>? initialLeads,
  })  : clues = initialClues ?? InvestigationDatabase.createDefaultClues(),
        leads = initialLeads ?? InvestigationDatabase.createDefaultLeads();

  int get totalClueCount => clues.length;
  int get discoveredClueCount => clues.where((c) => c.isDiscovered).length;

  int get totalLeadCount => leads.length;
  int get solvedLeadCount => leads.where((l) => l.isSolved).length;

  List<Clue> get discoveredClues => clues.where((c) => c.isDiscovered).toList();
  List<InvestigationLead> get solvedLeads => leads.where((l) => l.isSolved).toList();
  List<InvestigationLead> get unsolvedLeads => leads.where((l) => !l.isSolved).toList();

  /// Retrieves a clue by ID.
  Clue? getClueById(String id) {
    try {
      return clues.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Alias for getClueById.
  Clue? getClue(String id) => getClueById(id);

  /// Retrieves a lead by ID.
  InvestigationLead? getLeadById(String id) {
    try {
      return leads.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Checks if a clue is already discovered.
  bool isClueDiscovered(String id) {
    return getClueById(id)?.isDiscovered ?? false;
  }

  /// Checks if a lead is already solved.
  bool isLeadSolved(String id) {
    return getLeadById(id)?.isSolved ?? false;
  }

  /// Marks a clue as discovered and triggers feedback callbacks.
  bool discoverClue(String id) {
    final clue = getClueById(id);
    if (clue == null || clue.isDiscovered) return false;

    clue.markDiscovered();
    onClueDiscovered?.call(clue);
    notifyListeners();
    return true;
  }

  /// Attempts to connect a group of selected clues.
  /// If the combination matches an unsolved lead, solves the lead and returns it.
  InvestigationLead? connectClues(Iterable<String> clueIds) {
    final idList = clueIds.toList();

    // Verify all selected clues are actually discovered
    for (final id in idList) {
      if (!isClueDiscovered(id)) return null;
    }

    for (final lead in unsolvedLeads) {
      if (lead.matches(idList)) {
        lead.solve();
        onLeadSolved?.call(lead);
        notifyListeners();
        return lead;
      }
    }

    return null;
  }

  /// Automatically discovers clues linked to newly acquired items or collectibles.
  void synchronizeWithWorld({
    required List<String> inventoryItemIds,
    required List<String> collectibleIds,
  }) {
    final itemSet = inventoryItemIds.toSet();
    final colSet = collectibleIds.toSet();

    for (final clue in clues) {
      if (!clue.isDiscovered) {
        if (clue.associatedItemId != null && itemSet.contains(clue.associatedItemId)) {
          discoverClue(clue.id);
        } else if (clue.associatedCollectibleId != null &&
            colSet.contains(clue.associatedCollectibleId)) {
          discoverClue(clue.id);
        }
      }
    }
  }

  /// Serializes investigation progress for offline game saving.
  Map<String, dynamic> toJson() => {
        'discoveredClueIds':
            clues.where((c) => c.isDiscovered).map((c) => c.id).toList(),
        'solvedLeadIds':
            leads.where((l) => l.isSolved).map((l) => l.id).toList(),
      };

  /// Restores investigation state from save file.
  void restoreFromJson(Map<String, dynamic> json) {
    final clueIds = Set<String>.from(json['discoveredClueIds'] as List? ?? []);
    final leadIds = Set<String>.from(json['solvedLeadIds'] as List? ?? []);

    for (final c in clues) {
      if (clueIds.contains(c.id)) {
        c.isDiscovered = true;
      }
    }

    for (final l in leads) {
      if (leadIds.contains(l.id)) {
        l.isSolved = true;
      }
    }

    notifyListeners();
  }

  void reset() {
    for (final c in clues) {
      c.isDiscovered = false;
      c.discoveredAt = null;
    }
    for (final l in leads) {
      l.isSolved = false;
      l.solvedAt = null;
    }
    notifyListeners();
  }
}
