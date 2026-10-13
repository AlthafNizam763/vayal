import '../../game/dialogue/dialogue.dart';

/// Predefined narrative dialogue trees for Veyrapuram characters.
class DialogueData {
  static final Map<String, DialogueTree> allTrees = {
    'meera_homecoming': _meeraHomecomingTree,
    'diya_encounter': _diyaEncounterTree,
    'balan_tea_stall': _balanTeaStallTree,
    'informant_warning': _informantWarningTree,
    'raghav_chat': _raghavChatTree,
    'rahu_confrontation': _rahuConfrontationTree,
    'devraj_showdown': _devrajShowdownTree,
  };

  static DialogueTree? getTree(String id) => allTrees[id];

  // 1. MEERA HOMECOMING TREE
  static final DialogueTree _meeraHomecomingTree = DialogueTree(
    id: 'meera_homecoming',
    initialNodeId: 'meera_1',
    nodes: {
      'meera_1': const DialogueNode(
        id: 'meera_1',
        speaker: 'Meera (Mother)',
        text: 'Aadi...? You are finally home. Look at you... three long years without a word.',
        emotion: 'Emotional / Relieved',
        choices: [
          DialogueChoice(
            id: 'apologize',
            text: '"I am sorry I stayed away for so long, Amma. I am here now."',
            tone: DialogueTone.friendly,
            nextNodeId: 'meera_regret',
            setFlags: {'aadi_remorseful': true},
            relationshipDeltas: {'meera': 10},
            consequencePreview: 'Meera Trust +10 • Family Loyalty +5',
          ),
          DialogueChoice(
            id: 'defensive',
            text: '"I had things to handle. But that life is behind me. I just want peace."',
            tone: DialogueTone.neutral,
            nextNodeId: 'meera_defensive',
            setFlags: {'aadi_guarded': true},
            relationshipDeltas: {'meera': 5},
            consequencePreview: 'Meera Trust +5',
          ),
          DialogueChoice(
            id: 'meera_silence',
            text: '[ Look down in heavy silence, overwhelmed by guilt ]',
            tone: DialogueTone.silence,
            nextNodeId: 'meera_regret',
            setFlags: {'aadi_silent_remorse': true},
            relationshipDeltas: {'meera': 5},
            consequencePreview: 'Stoic Remorse',
          ),
        ],
      ),
      'meera_regret': const DialogueNode(
        id: 'meera_regret',
        speaker: 'Meera (Mother)',
        text: 'Hearing you say that means everything to me. I prayed every evening at the lamp for your return.',
        emotion: 'Tearful',
        nextNodeId: 'meera_father_mention',
      ),
      'meera_defensive': const DialogueNode(
        id: 'meera_defensive',
        speaker: 'Meera (Mother)',
        text: 'I understand, son. I know you carry burdens you don\'t speak of. But you don\'t have to run anymore.',
        emotion: 'Understanding',
        nextNodeId: 'meera_father_mention',
      ),
      'meera_father_mention': const DialogueNode(
        id: 'meera_father_mention',
        speaker: 'Meera (Mother)',
        text: 'Your father... Ravi always believed you would find your way back. Ever since his accident, this house has been so quiet.',
        emotion: 'Somber',
        choices: [
          DialogueChoice(
            id: 'ask_father',
            text: '"Tell me about Father\'s accident. Did anyone investigate it properly?"',
            nextNodeId: 'meera_accident_detail',
            setFlags: {'suspects_father_death': true},
          ),
          DialogueChoice(
            id: 'comfort_mother',
            text: '"I am here now, Amma. We will take care of this house together."',
            nextNodeId: 'meera_comforted',
            relationshipDeltas: {'meera': 10},
          ),
        ],
      ),
      'meera_accident_detail': const DialogueNode(
        id: 'meera_accident_detail',
        speaker: 'Meera (Mother)',
        text: 'The police closed the case as a hit-and-run on the highway. But there were rumors of men in suits asking about him before that night.',
        emotion: 'Worried',
        nextNodeId: 'meera_enter_house',
      ),
      'meera_comforted': const DialogueNode(
        id: 'meera_comforted',
        speaker: 'Meera (Mother)',
        text: 'God bless you, Aadi. That is all a mother could ask for.',
        emotion: 'Comforted',
        nextNodeId: 'meera_enter_house',
      ),
      'meera_enter_house': const DialogueNode(
        id: 'meera_enter_house',
        speaker: 'Meera (Mother)',
        text: 'Come inside. The night chill is setting in, and you need a warm meal and rest.',
        emotion: 'Gentle',
        choices: [
          DialogueChoice(
            id: 'enter_door',
            text: '[ Enter the house with Meera ]',
            setFlags: {
              'mission_01_complete': true,
              'spoke_to_meera': true,
            },
            triggerMissionId: 'mission_01_done',
          ),
        ],
      ),
    },
  );

  // 2. DIYA ENCOUNTER TREE
  static final DialogueTree _diyaEncounterTree = DialogueTree(
    id: 'diya_encounter',
    initialNodeId: 'diya_1',
    nodes: {
      'diya_1': const DialogueNode(
        id: 'diya_1',
        speaker: 'Diya (Sister)',
        text: 'Aadi. You just walk back into town like you didn\'t leave us alone to deal with everything?',
        emotion: 'Guarded / Hurt',
        choices: [
          DialogueChoice(
            id: 'acknowledge_pain',
            text: '"You are right to be angry with me, Diya. I made mistakes I cannot undo."',
            tone: DialogueTone.friendly,
            nextNodeId: 'diya_softens',
            setFlags: {'diya_empathy': true},
            relationshipDeltas: {'diya': 10},
            consequencePreview: 'Diya Trust +10 • Family Loyalty +5',
          ),
          DialogueChoice(
            id: 'protect_explanation',
            text: '"I stayed away to keep you and Amma safe from dangerous people."',
            tone: DialogueTone.persuasion,
            nextNodeId: 'diya_skeptical',
            setFlags: {'diya_protective_truth': true},
            relationshipDeltas: {'diya': 5},
            consequencePreview: 'Persuasion • Diya Trust +5',
          ),
          DialogueChoice(
            id: 'diya_lie',
            text: '"I was just doing quiet contract work in the city. There was no danger."',
            tone: DialogueTone.lie,
            nextNodeId: 'diya_skeptical',
            setFlags: {'lied_to_diya': true},
            relationshipDeltas: {'diya': -5},
            consequencePreview: 'Deception • Diya Trust -5',
          ),
          DialogueChoice(
            id: 'diya_silence',
            text: '[ Withstand her glare in silence, unable to defend your past ]',
            tone: DialogueTone.silence,
            nextNodeId: 'diya_warning',
            setFlags: {'diya_silence_endured': true},
            consequencePreview: 'Stoic Silence',
          ),
        ],
      ),
      'diya_softens': const DialogueNode(
        id: 'diya_softens',
        speaker: 'Diya (Sister)',
        text: 'I\'m not just angry... I was scared we would get a call saying you were found in a ditch somewhere.',
        emotion: 'Vulnerable',
        nextNodeId: 'diya_warning',
      ),
      'diya_skeptical': const DialogueNode(
        id: 'diya_skeptical',
        speaker: 'Diya (Sister)',
        text: 'Safe? Those same people came around after Father died, asking about accounts and files you took!',
        emotion: 'Stern',
        nextNodeId: 'diya_warning',
      ),
      'diya_warning': const DialogueNode(
        id: 'diya_warning',
        speaker: 'Diya (Sister)',
        text: 'If you are staying, you better make sure whatever you were involved in doesn\'t follow you through our door.',
        emotion: 'Determined',
        choices: [
          DialogueChoice(
            id: 'promise_diya',
            text: '"I swear on Father\'s memory, Diya. No harm will come to this house."',
            setFlags: {'promised_diya_protection': true},
            relationshipDeltas: {'diya': 10},
          ),
        ],
      ),
    },
  );

  // 3. BALAN TEA STALL TREE
  static final DialogueTree _balanTeaStallTree = DialogueTree(
    id: 'balan_tea_stall',
    initialNodeId: 'balan_1',
    nodes: {
      'balan_1': const DialogueNode(
        id: 'balan_1',
        speaker: 'Balan (Tea Stall)',
        text: 'Aadithyan Menon! Word travels fast in Veyrapuram. Have a glass of steaming ginger chai.',
        emotion: 'Welcoming',
        choices: [
          DialogueChoice(
            id: 'ask_town_news',
            text: '"Thanks, Balan. What is the latest word in town?"',
            nextNodeId: 'balan_news',
          ),
          DialogueChoice(
            id: 'ask_about_devraj',
            text: '"Has Devraj\'s company expanded around here recently?"',
            nextNodeId: 'balan_devraj',
            setFlags: {'inquired_devraj_early': true},
          ),
        ],
      ),
      'balan_news': const DialogueNode(
        id: 'balan_news',
        speaker: 'Balan (Tea Stall)',
        text: 'Town isn\'t what it used to be. New money pouring in from the harbour, but with it come heavy tinted SUVs at midnight.',
        emotion: 'Cautious',
        nextNodeId: 'balan_parting',
      ),
      'balan_devraj': const DialogueNode(
        id: 'balan_devraj',
        speaker: 'Balan (Tea Stall)',
        text: 'Devraj Enterprises bought the old warehouse district by the railway tracks. Keep your voice down when saying that name, Aadi.',
        emotion: 'Whispering',
        nextNodeId: 'balan_parting',
      ),
      'balan_parting': const DialogueNode(
        id: 'balan_parting',
        speaker: 'Balan (Tea Stall)',
        text: 'Stay on the straight path, son. Veyrapuram remembers who you were, but people want to see who you\'ve become.',
        emotion: 'Sincere',
        choices: [
          DialogueChoice(
            id: 'thank_balan',
            text: '"Good advice, Balan. See you around."',
            relationshipDeltas: {'balan': 5},
          ),
        ],
      ),
    },
  );

  // 4. INFORMANT WARNING TREE
  static final DialogueTree _informantWarningTree = DialogueTree(
    id: 'informant_warning',
    initialNodeId: 'informant_1',
    nodes: {
      'informant_1': const DialogueNode(
        id: 'informant_1',
        speaker: 'Hooded Contact',
        text: 'You shouldn\'t have come back, Aadi.',
        emotion: 'Ominous',
        choices: [
          DialogueChoice(
            id: 'informant_neutral',
            text: '"Who sent you? Is Rahu looking for me?"',
            tone: DialogueTone.neutral,
            nextNodeId: 'informant_rahu',
            consequencePreview: 'Seek Intel',
          ),
          DialogueChoice(
            id: 'informant_threat',
            text: '"Step back before I break your collarbone. You know what I did in Bangalore."',
            tone: DialogueTone.threat,
            nextNodeId: 'informant_rahu',
            setFlags: {'threatened_informant': true},
            reputationDelta: 5,
            criminalRepDelta: 10,
            consequencePreview: 'Intimidation • Street Rep +5 • Criminal Rep +10',
          ),
          DialogueChoice(
            id: 'informant_persuade',
            text: '"Whoever paid you to deliver this will abandon you if things get hot. Tell me whose orders you follow."',
            tone: DialogueTone.persuasion,
            nextNodeId: 'informant_rahu',
            setFlags: {'persuaded_informant': true},
            consequencePreview: 'Persuasion • Seek Alliance',
          ),
          DialogueChoice(
            id: 'informant_lie',
            text: '"You have the wrong man. I just arrived from Calicut on transport business."',
            tone: DialogueTone.lie,
            nextNodeId: 'informant_photo_hint',
            setFlags: {'lied_to_informant': true},
            consequencePreview: 'Deception • Conceal Identity',
          ),
          DialogueChoice(
            id: 'informant_friendly',
            text: '"Listen, friend. I came back for family, not old syndicate grudges. No need for hostility."',
            tone: DialogueTone.friendly,
            nextNodeId: 'informant_photo_hint',
            setFlags: {'friendly_informant': true},
            consequencePreview: 'Diplomacy • De-escalate',
          ),
          DialogueChoice(
            id: 'informant_silence',
            text: '[ Step into his shadow in stone-cold silence, staring him down ]',
            tone: DialogueTone.silence,
            nextNodeId: 'informant_photo_hint',
            setFlags: {'silent_stare_informant': true},
            consequencePreview: 'Predatory Silence',
          ),
        ],
      ),
      'informant_rahu': const DialogueNode(
        id: 'informant_rahu',
        speaker: 'Hooded Contact',
        text: 'Rahu never stopped looking. He thinks you took the fall and ran with everything.',
        emotion: 'Quiet',
        nextNodeId: 'informant_photo_hint',
      ),
      'informant_photo_hint': const DialogueNode(
        id: 'informant_photo_hint',
        speaker: 'Hooded Contact',
        text: 'Check your doorstep soon. An old memory is waiting for you. "You left us once. Don\'t do it again."',
        emotion: 'Chilling',
        choices: [
          DialogueChoice(
            id: 'stranger_departs',
            text: '[ Watch the stranger disappear into the shadows ]',
            setFlags: {'forewarned_photograph': true},
          ),
        ],
      ),
    },
  );

  // 5. RAGHAV CIVILIAN TREE
  static final DialogueTree _raghavChatTree = DialogueTree(
    id: 'raghav_chat',
    initialNodeId: 'raghav_1',
    nodes: {
      'raghav_1': const DialogueNode(
        id: 'raghav_1',
        speaker: 'Raghav (Civilian)',
        text: 'Good evening. You must be Menon\'s son. Welcome back to Veyrapuram.',
        emotion: 'Polite',
        choices: [
          DialogueChoice(
            id: 'polite_reply',
            text: '"Thank you, Raghav. Good evening."',
          ),
        ],
      ),
    },
  );

  // 6. ACT IV: RAHU CONFRONTATION TREE (Highway Bridge)
  static final DialogueTree _rahuConfrontationTree = DialogueTree(
    id: 'rahu_confrontation',
    initialNodeId: 'rahu_1',
    nodes: {
      'rahu_1': const DialogueNode(
        id: 'rahu_1',
        speaker: 'Rahu',
        text: 'Aadi... Look at you. Playing the obedient son. Did you really think you could vanish after what happened at the docks?',
        emotion: 'Bitter / Smirking',
        choices: [
          DialogueChoice(
            id: 'confront_betrayal',
            text: '"You took Devraj\'s payoff, Rahu. You sold out my father and let me take the heat."',
            tone: DialogueTone.threat,
            nextNodeId: 'rahu_confession',
            setFlags: {'rahu_confronted_truth': true},
            relationshipDeltas: {'rahu': -20},
            criminalRepDelta: 10,
            consequencePreview: 'Threat • Rahu -20 • Criminal Rep +10',
          ),
          DialogueChoice(
            id: 'appeal_to_past',
            text: '"We were like brothers once, Rahu. Help me end Devraj\'s hold on this town."',
            tone: DialogueTone.persuasion,
            nextNodeId: 'rahu_alliance_offer',
            setFlags: {'helped_rahu': true},
            relationshipDeltas: {'rahu': 25},
            consequencePreview: 'Persuasion • Rahu +25',
          ),
          DialogueChoice(
            id: 'rahu_lie',
            text: '"I came back to hand over the ledger and leave forever. I don\'t care about Berth 4."',
            tone: DialogueTone.lie,
            nextNodeId: 'rahu_alliance_offer',
            setFlags: {'lied_to_rahu': true},
            consequencePreview: 'Deception • Conceal Motives',
          ),
          DialogueChoice(
            id: 'rahu_friendly',
            text: '"We both survived this long. Put the guns away before Devraj buries us both."',
            tone: DialogueTone.friendly,
            nextNodeId: 'rahu_alliance_offer',
            relationshipDeltas: {'rahu': 15},
            consequencePreview: 'Friendly • De-escalate',
          ),
          DialogueChoice(
            id: 'rahu_silence',
            text: '[ Say nothing. Let the silence of Father\'s memory weigh on him ]',
            tone: DialogueTone.silence,
            nextNodeId: 'rahu_confession',
            relationshipDeltas: {'rahu': -10},
            setFlags: {'silent_with_rahu': true},
            consequencePreview: 'Cold Silence • Rahu -10',
          ),
        ],
      ),
      'rahu_confession': const DialogueNode(
        id: 'rahu_confession',
        speaker: 'Rahu',
        text: 'Devraj owns everyone in Veyrapuram. Your father wouldn\'t sign off on Berth 4. He dug his own grave, Aadi.',
        emotion: 'Cold',
        choices: [
          DialogueChoice(
            id: 'warn_rahu',
            text: '"Stay out of my way, or you answer for his blood too."',
            nextNodeId: 'rahu_end_hostile',
            setFlags: {'betrayed_rahu': true},
          ),
        ],
      ),
      'rahu_alliance_offer': const DialogueNode(
        id: 'rahu_alliance_offer',
        speaker: 'Rahu',
        text: 'Devraj never trusted either of us. The ledger at Berth 4 has the account numbers. If you take him down... we split the empire.',
        emotion: 'Calculating',
        choices: [
          DialogueChoice(
            id: 'tentative_deal',
            text: '"First we finish Devraj. Then we see who walks away."',
            nextNodeId: 'rahu_end_neutral',
            setFlags: {'rahu_alliance': true},
          ),
        ],
      ),
      'rahu_end_hostile': const DialogueNode(
        id: 'rahu_end_hostile',
        speaker: 'Rahu',
        text: 'Good luck at Berth 4, Menon. You won\'t walk out alive.',
        emotion: 'Threatening',
      ),
      'rahu_end_neutral': const DialogueNode(
        id: 'rahu_end_neutral',
        speaker: 'Rahu',
        text: 'Meet me at the Berth 4 perimeter tonight. Don\'t be late.',
        emotion: 'Grim',
      ),
    },
  );

  // 7. ACT V: DEVRAJ FINAL CLIMAX TREE (Port Veyrapuram Berth 4)
  static final DialogueTree _devrajShowdownTree = DialogueTree(
    id: 'devraj_showdown',
    initialNodeId: 'devraj_1',
    nodes: {
      'devraj_1': const DialogueNode(
        id: 'devraj_1',
        speaker: 'Devraj',
        text: 'Aadithyan. Just like your father... you never knew when to fold your cards. Look around you. Everything that arrives in this port belongs to me.',
        emotion: 'Commanding / Arrogant',
        choices: [
          DialogueChoice(
            id: 'choice_walk_away',
            text: '[ ENDING A: WALK AWAY ] "I came to tell you I am taking my family and leaving. Keep your blood money."',
            tone: DialogueTone.friendly,
            nextNodeId: 'devraj_ending_a',
            setFlags: {'ending_walk_away': true, 'final_decision': 'walk_away'},
            consequencePreview: 'Ending A • Fresh Start for Family',
          ),
          DialogueChoice(
            id: 'choice_revenge',
            text: '[ ENDING B: REVENGE ] "You killed Ravi Menon. And now you pay for it in blood."',
            tone: DialogueTone.threat,
            nextNodeId: 'devraj_ending_b',
            setFlags: {'ending_revenge': true, 'final_decision': 'revenge'},
            consequencePreview: 'Ending B • Blood Vengeance',
          ),
          DialogueChoice(
            id: 'choice_expose',
            text: '[ ENDING C: EXPOSE EVERYTHING ] "Raghav and the state department have your Berth 4 shipping logs. It\'s over, Devraj."',
            tone: DialogueTone.persuasion,
            nextNodeId: 'devraj_ending_c',
            setFlags: {'ending_expose': true, 'final_decision': 'expose'},
            consequencePreview: 'Ending C • Legal Justice for Ravi',
          ),
          DialogueChoice(
            id: 'devraj_silence',
            text: '[ Say nothing. Place Father\'s shattered watch on the desk in cold defiance ]',
            tone: DialogueTone.silence,
            nextNodeId: 'devraj_ending_b',
            setFlags: {'silent_stare_devraj': true},
            consequencePreview: 'Silent Defiance',
          ),
        ],
      ),
      'devraj_ending_a': const DialogueNode(
        id: 'devraj_ending_a',
        speaker: 'Devraj',
        text: 'You\'re smarter than your old man, Aadi. Take them and never set foot in Veyrapuram again.',
        emotion: 'Mocking',
      ),
      'devraj_ending_b': const DialogueNode(
        id: 'devraj_ending_b',
        speaker: 'Devraj',
        text: 'Then let us see if your hands are as quick as your tongue, ex-convict!',
        emotion: 'Furious',
      ),
      'devraj_ending_c': const DialogueNode(
        id: 'devraj_ending_c',
        speaker: 'Devraj',
        text: 'Police sirens in the distance?! You brought the law to my port?! You fool...!',
        emotion: 'Shocked / Panicked',
      ),
    },
  );
}

