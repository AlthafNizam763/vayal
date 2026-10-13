import 'package:flutter/foundation.dart';
import '../systems/game_state.dart';
import 'story_choice.dart';
import 'story_choice_system.dart';

/// Major resolution endings for VAYAL.
enum EndingType {
  /// Ending A: Leave criminal past, return to family and ancestral land.
  walkAway,

  /// Ending B: Embrace violence, eliminate Devraj and seize the underworld.
  revenge,

  /// Ending C: Hand evidence to Inspector Raghav, dismantle syndicate legally.
  exposeEverything,
}

/// Comprehensive narrative and character epilogue data for an ending.
class EndingResolutionData {
  final EndingType type;
  final String code; // 'ENDING A', 'ENDING B', 'ENDING C'
  final String title;
  final String subtitle;
  final String thematicQuote;
  final List<String> epilogueSlides;
  final Map<String, String> charactersFate;
  final int requiredMinAlignment;

  const EndingResolutionData({
    required this.type,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.thematicQuote,
    required this.epilogueSlides,
    required this.charactersFate,
    this.requiredMinAlignment = 50,
  });
}

/// Repository containing literary narrative descriptions for all three endings.
class EndingDatabase {
  static const EndingResolutionData endingWalkAway = EndingResolutionData(
    type: EndingType.walkAway,
    code: 'ENDING A',
    title: 'WALK AWAY',
    subtitle: 'The Green Field (Vayal)',
    thematicQuote: '“A field is not reclaimed in a single night. It takes patience, rain, and the courage to drop the blade.”',
    epilogueSlides: [
      'The morning mist rolls over the paddy fields of Veyrapuram. For the first time in twelve years, Aadithyan Menon wakes up to the sound of rain rather than sirens.',
      'Aadi buried his father’s silver revolver beneath the roots of the ancient teak tree by the riverbank. He made no promises of perfection, but he stayed. He helped Meera repair the verandah roof, and walked Diya to the village school every sunrise.',
      'Devraj’s shadow never returned to the porch. Word traveled from the coastal docks that the syndicate found other pawns, but none dared venture into the quiet interior of Veyrapuram where Aadi had drawn his final line.',
      'Aadi looks out across the green expanse of the vayal. The ghosts of his past still linger in the evening shadows, but they no longer dictate his path. He is, at last, a free man.',
    ],
    charactersFate: {
      'Meera': 'Found peace in the family homestead, knowing Aadi chose to stay and protect them.',
      'Diya': 'Attending school in town without fear of shadowy men watching the gate.',
      'Rahu': 'Disappeared into the northern hills, having recognized that Aadi would never return to the trade.',
      'Devraj': 'His operations stalled at Berth 4 as local resistance stiffened in his absence.',
      'Raghav': 'Closed the old case file on Aadithyan Menon, marking it resolved with no charges filed.',
    },
  );

  static const EndingResolutionData endingRevenge = EndingResolutionData(
    type: EndingType.revenge,
    code: 'ENDING B',
    title: 'REVENGE',
    subtitle: 'The Blood Crown of Berth 4',
    thematicQuote: '“You cannot wash away blood with mud. You can only become the storm that swallows everything.”',
    epilogueSlides: [
      'The rain on Berth 4 was relentless. When the echoes of gunshots faded into the roaring Arabian Sea, Devraj lay motionless on the wet steel deck. The syndicate did not scatter; they bowed.',
      'Aadi stepped over the fallen kingpin and claimed the ledger of Berth 4. The vengeance for Ravi Menon’s murder was complete, but the cost was carved into Aadi’s very soul.',
      'Meera packed her bags before dawn. She looked at Aadi’s eyes—cold, detached, and burdened with blood—and saw the criminal she feared he would always be. She took Diya and left on the morning express train to Kochi.',
      'Aadithyan Menon stands at the highest gantry crane of Port Veyrapuram, smoking in the rain. He rules the entire coastline now. No one dares speak his name without trembling. But in the grand ancestral house, every room is empty and cold.',
    ],
    charactersFate: {
      'Meera': 'Fled Veyrapuram with Diya to start a life far away from the bloodstained empire.',
      'Diya': 'Grows up far from the coast, remembering only a distant father in dark photographs.',
      'Rahu': 'Became Aadi’s chief enforcer, enforcing the Menon syndicate’s rule with ruthless efficiency.',
      'Devraj': 'Eliminated at Berth 4, his ten-year stranglehold on the port shattered.',
      'Raghav': 'Opened an active manhunt dossier, designating Aadithyan Menon as District Enemy #1.',
    },
  );

  static const EndingResolutionData endingExposeEverything = EndingResolutionData(
    type: EndingType.exposeEverything,
    code: 'ENDING C',
    title: 'EXPOSE EVERYTHING',
    subtitle: 'The Ledger of Veyrapuram',
    thematicQuote: '“Truth is not a shield. It is a fire that burns the corrupt and scorches the one who strikes the match.”',
    epilogueSlides: [
      'At midnight inside the District Police Precinct, Aadi handed the encrypted ledger and customs manifestos directly to Inspector Raghav. Every bribe, every smuggling shipment through Berth 4, and the truth behind his father’s murder were documented in black and white.',
      'Within forty-eight hours, State Special Task Forces raided seven warehouses along the coastal highway. Devraj was arrested alongside twelve corrupt customs officials and politicians.',
      'Aadi refused the state informant reward. He agreed to testify under oath, knowing that his own past transgressions would come under scrutiny. He accepted a light probationary term with dignity.',
      'Sitting on the porch with a cup of black tea as dawn breaks over Veyrapuram, Aadi watches the morning papers headline the syndicate’s downfall. The cycle is broken. Justice was served not by the gun, but by the truth.',
    ],
    charactersFate: {
      'Meera': 'Stands beside Aadi during court proceedings, proud that he chose justice over blood.',
      'Diya': 'Grows up in a safer Veyrapuram, free from criminal syndicates and intimidation.',
      'Rahu': 'Arrested during the state raids; awaiting trial under heavy security.',
      'Devraj': 'Sentenced to life imprisonment at the central penitentiary with no chance of parole.',
      'Raghav': 'Promoted to Superintendent of Police for orchestrating the largest cartel takedown in state history.',
    },
  );

  static EndingResolutionData getEndingData(EndingType type) {
    switch (type) {
      case EndingType.walkAway:
        return endingWalkAway;
      case EndingType.revenge:
        return endingRevenge;
      case EndingType.exposeEverything:
        return endingExposeEverything;
    }
  }
}

/// Orchestrates the triggering, presentation, and post-game state of the 3 major endings.
class EndingManager extends ChangeNotifier {
  bool _isEndingActive = false;
  bool _isCreditsRolling = false;
  EndingResolutionData? _activeEnding;
  int _currentSlideIndex = 0;

  VoidCallback? onEndingTriggered;
  VoidCallback? onEndingCompleted;

  bool get isEndingActive => _isEndingActive;
  bool get isCreditsRolling => _isCreditsRolling;
  EndingResolutionData? get activeEnding => _activeEnding;
  int get currentSlideIndex => _currentSlideIndex;

  /// Evaluates which ending to trigger based on choices made in StoryChoiceSystem.
  EndingType evaluateEndingFromSystem(StoryChoiceSystem choiceSystem) {
    final predicted = choiceSystem.calculatePredictedEnding();
    switch (predicted) {
      case PredictedEnding.walkAway:
        return EndingType.walkAway;
      case PredictedEnding.revenge:
        return EndingType.revenge;
      case PredictedEnding.exposeEverything:
        return EndingType.exposeEverything;
    }
  }

  /// Triggers the specified ending sequence.
  void triggerEnding(EndingType type, GameState gameState) {
    _activeEnding = EndingDatabase.getEndingData(type);
    _isEndingActive = true;
    _isCreditsRolling = false;
    _currentSlideIndex = 0;

    // Record persistent completion flag
    gameState.setFlag('story_completed', true);
    gameState.setFlag('final_ending_type', type.name);
    gameState.setFlag('final_ending_title', _activeEnding!.title);

    notifyListeners();
    onEndingTriggered?.call();
  }

  /// Advances to the next epilogue slide. Returns true if more slides exist, false if end reached.
  bool advanceSlide() {
    if (_activeEnding == null) return false;
    if (_currentSlideIndex < _activeEnding!.epilogueSlides.length - 1) {
      _currentSlideIndex++;
      notifyListeners();
      return true;
    } else {
      // Reached final slide, transition to credits
      _isCreditsRolling = true;
      notifyListeners();
      return false;
    }
  }

  /// Steps backwards to review earlier epilogue slide.
  void previousSlide() {
    if (_currentSlideIndex > 0) {
      _currentSlideIndex--;
      notifyListeners();
    }
  }

  /// Starts the closing credits roll.
  void startCredits() {
    _isCreditsRolling = true;
    notifyListeners();
  }

  /// Concludes ending sequence and returns the player to open-world free-roam mode.
  void concludeEnding() {
    _isEndingActive = false;
    _isCreditsRolling = false;
    notifyListeners();
    onEndingCompleted?.call();
  }
}
