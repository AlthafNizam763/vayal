import 'package:flutter/foundation.dart';
import 'story_flag_manager.dart';

/// The 8 major story revelations of VAYAL in dramatic order.
enum StoryReveal {
  aadisOldGang,
  rahusDisappearance,
  fathersSuspiciousDeath,
  devrajsInvolvement,
  theBetrayalOfRahu,
  theOldVideo,
  hiddenPersonInVideo,
  theRealTruth,
}

/// Metadata for a single revelation.
class StoryRevealData {
  final StoryReveal reveal;
  final int order; // 1-8 for display ordering
  final String title;
  final String shortSummary;
  final String narrativeText; // Full text shown when unlocked

  /// Flag conditions that must ALL be true before this reveal can unlock.
  final Map<String, dynamic> requiredFlags;

  /// Flag written to StoryFlagManager when this reveal fires.
  final String revealFlagKey;

  const StoryRevealData({
    required this.reveal,
    required this.order,
    required this.title,
    required this.shortSummary,
    required this.narrativeText,
    required this.requiredFlags,
    required this.revealFlagKey,
  });
}

/// Phase 44: Tracks 8 major story revelations, gates them behind
/// [StoryFlagManager] conditions, and fires callbacks when newly unlocked.
///
/// Integrate by calling [evaluateReveals] whenever flags change. Never skip
/// ahead — each reveal is only surfaced after its predecessor is unlocked.
class StoryRevealManager extends ChangeNotifier {
  static final List<StoryRevealData> _allReveals = [
    // 1 ─ Aadi's Old Gang
    const StoryRevealData(
      reveal: StoryReveal.aadisOldGang,
      order: 1,
      title: 'The Gang That Was',
      shortSummary:
          'Aadithyan was once a key enforcer for the Devraj Syndicate\'s Old Town crew.',
      narrativeText:
          'Before leaving Veyrapuram twelve years ago, Aadithyan "Aadi" Menon was part of Rahu\'s street crew — the enforcers who kept the dock workers in line. He was trusted, feared, and complicit. He left to forget. But Veyrapuram remembers.',
      requiredFlags: {'completed_mission_02': true},
      revealFlagKey: 'reveal_aadis_old_gang',
    ),

    // 2 ─ Rahu's Disappearance
    const StoryRevealData(
      reveal: StoryReveal.rahusDisappearance,
      order: 2,
      title: 'Where Did Rahu Go?',
      shortSummary:
          'After a botched job, Rahu vanished. Devraj claimed he fled. That was a lie.',
      narrativeText:
          'Three years after Aadi left, Rahu disappeared. Devraj told everyone he had gone into hiding after a deal went wrong. But informants in the Old Town bazaar whisper that Rahu resurfaced secretly — changed, dangerous, and working alone.',
      requiredFlags: {
        'completed_mission_03': true,
        'reveal_aadis_old_gang': true,
      },
      revealFlagKey: 'reveal_rahus_disappearance',
    ),

    // 3 ─ Father's Suspicious Death
    const StoryRevealData(
      reveal: StoryReveal.fathersSuspiciousDeath,
      order: 3,
      title: 'The Dock Accident',
      shortSummary:
          'Ravi Menon\'s death at Berth 4 was ruled an accident. The ledger says otherwise.',
      narrativeText:
          'Ravi Menon, Aadi\'s father, died at Port Veyrapuram Berth 4 — officially crushed by a shifted cargo pallet during a night offload. The shipping ledger recovered from the depot reveals the berth was supposed to be empty that night. Ravi was there to document contraband. Someone made sure he never left.',
      requiredFlags: {
        'has_shipping_ledger': true,
        'reveal_rahus_disappearance': true,
      },
      revealFlagKey: 'reveal_fathers_suspicious_death',
    ),

    // 4 ─ Devraj's Involvement
    const StoryRevealData(
      reveal: StoryReveal.devrajsInvolvement,
      order: 4,
      title: 'The Name Behind It All',
      shortSummary:
          'Devraj personally authorised the order that killed Ravi Menon.',
      narrativeText:
          'A second ledger page, cross-referenced with cargo manifests from Devraj Enterprises, carries a single handwritten note: "D.R. — remove the interference." The abbreviation is Devraj\'s. He ordered Ravi\'s death to keep his contraband network running.',
      requiredFlags: {
        StoryFlagManager.fatherTruthFound: true,
        'reveal_fathers_suspicious_death': true,
      },
      revealFlagKey: 'reveal_devrajs_involvement',
    ),

    // 5 ─ The Betrayal
    const StoryRevealData(
      reveal: StoryReveal.theBetrayalOfRahu,
      order: 5,
      title: 'Blood on Familiar Hands',
      shortSummary:
          'Rahu was the one who lured Ravi to Berth 4 that night.',
      narrativeText:
          'Rahu did not disappear because of a failed deal. He disappeared because he executed Devraj\'s order — luring Ravi Menon to Berth 4 on false pretenses — and could not live openly with the guilt. He has been running ever since. Not from Devraj, but from Aadi.',
      requiredFlags: {
        StoryFlagManager.metRahu: true,
        'reveal_devrajs_involvement': true,
      },
      revealFlagKey: 'reveal_betrayal_of_rahu',
    ),

    // 6 ─ The Old Video
    const StoryRevealData(
      reveal: StoryReveal.theOldVideo,
      order: 6,
      title: 'A Recording Survived',
      shortSummary:
          'A mobile phone video captured part of what happened at Berth 4.',
      narrativeText:
          'An encrypted file on a burner phone recovered near the harbour fence contains a 43-second video. Shaky, dark, monsoon rain obscuring much of the frame — but the dock platform at Berth 4 is visible, along with three figures during the fatal night.',
      requiredFlags: {
        StoryFlagManager.truthVideoDiscovered: true,
        'reveal_betrayal_of_rahu': true,
      },
      revealFlagKey: 'reveal_old_video',
    ),

    // 7 ─ Hidden Person in the Video
    const StoryRevealData(
      reveal: StoryReveal.hiddenPersonInVideo,
      order: 7,
      title: 'The Third Figure',
      shortSummary:
          'The video contains a third witness — someone who was never supposed to be there.',
      narrativeText:
          'Enhancing the video reveals a third figure standing at the dock gate. Not Rahu. Not Devraj. A woman in a police rain cape — Inspector Raghavi Nair. She was there that night and did nothing. She has since risen through ranks under Devraj\'s patronage.',
      requiredFlags: {
        'reveal_old_video': true,
        StoryFlagManager.berth4Infiltrated: true,
      },
      revealFlagKey: 'reveal_hidden_person_video',
    ),

    // 8 ─ The Real Truth
    const StoryRevealData(
      reveal: StoryReveal.theRealTruth,
      order: 8,
      title: 'What Ravi Actually Found',
      shortSummary:
          'Ravi Menon did not just find contraband — he was about to expose a kidnapping network.',
      narrativeText:
          'The final document hidden inside the ledger details a trafficking route disguised as fish export containers. Ravi Menon was not just documenting cargo irregularities — he had identified the network and was preparing to hand evidence to a national journalist. Devraj had to act fast. The accident was never an accident. It was an execution, witnessed by Raghavi, enabled by Rahu, and ordered by Devraj.',
      requiredFlags: {
        'reveal_hidden_person_video': true,
        StoryFlagManager.devrajConfronted: true,
      },
      revealFlagKey: 'reveal_real_truth',
    ),
  ];

  final Set<StoryReveal> _unlockedReveals = {};
  final List<StoryRevealData> _revealHistory = [];

  /// Called whenever a reveal newly unlocks.
  void Function(StoryRevealData data)? onRevealUnlocked;

  // ─── Query ───────────────────────────────────────────────────────────────────

  bool isUnlocked(StoryReveal reveal) => _unlockedReveals.contains(reveal);

  List<StoryRevealData> get unlockedReveals =>
      _allReveals.where((r) => _unlockedReveals.contains(r.reveal)).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  List<StoryRevealData> get lockedReveals =>
      _allReveals.where((r) => !_unlockedReveals.contains(r.reveal)).toList();

  /// Ordered history in which reveals were first discovered.
  List<StoryRevealData> get revealHistory => List.unmodifiable(_revealHistory);

  int get totalReveals => _allReveals.length;
  int get unlockedCount => _unlockedReveals.length;

  // ─── Evaluation ──────────────────────────────────────────────────────────────

  /// Evaluate all reveals against current flag state.
  /// Must be called from [StoryFlagManager.onFlagChanged] hook.
  void evaluateReveals(StoryFlagManager flags) {
    bool any = false;
    for (final revealData in _allReveals) {
      if (_unlockedReveals.contains(revealData.reveal)) continue;

      if (_conditionsMet(revealData.requiredFlags, flags)) {
        _unlockedReveals.add(revealData.reveal);
        _revealHistory.add(revealData);
        // Write the reveal flag so future gates can depend on it
        flags.setBool(revealData.revealFlagKey, true,
            source: 'StoryRevealManager');
        onRevealUnlocked?.call(revealData);
        any = true;
      }
    }
    if (any) notifyListeners();
  }

  bool _conditionsMet(Map<String, dynamic> conditions, StoryFlagManager flags) {
    for (final entry in conditions.entries) {
      final val = flags.getAllFlags()[entry.key];
      if (val != entry.value) return false;
    }
    return true;
  }

  // ─── Persistence ─────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'unlocked': _unlockedReveals.map((r) => r.name).toList(),
      };

  void restoreFromJson(Map<String, dynamic> json) {
    _unlockedReveals.clear();
    _revealHistory.clear();
    final unlocked = (json['unlocked'] as List?)?.cast<String>() ?? [];
    for (final name in unlocked) {
      final reveal = StoryReveal.values.firstWhere(
        (r) => r.name == name,
        orElse: () => StoryReveal.aadisOldGang,
      );
      _unlockedReveals.add(reveal);
      final data = _allReveals.firstWhere((d) => d.reveal == reveal);
      _revealHistory.add(data);
    }
    notifyListeners();
  }

  void reset() {
    _unlockedReveals.clear();
    _revealHistory.clear();
    notifyListeners();
  }
}
