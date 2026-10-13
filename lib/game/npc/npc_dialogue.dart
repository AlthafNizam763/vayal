/// Single dialogue line spoken by a character.
class NpcDialogueLine {
  final String speakerName;
  final String text;
  final String? emotionHint;

  const NpcDialogueLine({
    required this.speakerName,
    required this.text,
    this.emotionHint,
  });
}

/// Dialogue database providing context-aware remarks for Veyrapuram NPCs.
class NpcDialogueRegistry {
  static final Map<String, List<NpcDialogueLine>> _npcDialogues = {
    'meera': [
      const NpcDialogueLine(
        speakerName: 'Meera (Mother)',
        text: 'Aadi...? Is that really you? You look exhausted, son.',
        emotionHint: 'relieved',
      ),
      const NpcDialogueLine(
        speakerName: 'Aadi',
        text: 'I am home, Amma. The past is behind me.',
      ),
      const NpcDialogueLine(
        speakerName: 'Meera (Mother)',
        text: 'Come inside. The night wind is growing cold.',
      ),
    ],
    'diya': [
      const NpcDialogueLine(
        speakerName: 'Diya (Sister)',
        text: 'Three years without a single phone call, Aadi. And you just walk in?',
        emotionHint: 'guarded',
      ),
      const NpcDialogueLine(
        speakerName: 'Aadi',
        text: 'I know. I will make things right, Diya.',
      ),
    ],
    'balan': [
      const NpcDialogueLine(
        speakerName: 'Balan (Tea Stall)',
        text: 'Menon! Heard you were back in Veyrapuram. Tea is fresh and steaming hot.',
      ),
      const NpcDialogueLine(
        speakerName: 'Balan (Tea Stall)',
        text: 'Keep your head low. Strange vehicles have been driving past after dark.',
        emotionHint: 'warning',
      ),
    ],
    'raghav': [
      const NpcDialogueLine(
        speakerName: 'Raghav (Civilian)',
        text: 'Evening. Quiet evening in town today, isn\'t it?',
      ),
    ],
    'informant': [
      const NpcDialogueLine(
        speakerName: 'Hooded Contact',
        text: 'Welcome back to Veyrapuram, Aadi. Someone left something for you on the doorstep.',
        emotionHint: 'whisper',
      ),
    ],
  };

  static List<NpcDialogueLine> getDialogue(String npcId) {
    return _npcDialogues[npcId] ??
        [
          NpcDialogueLine(
            speakerName: 'Resident',
            text: 'Hello there. Stay safe tonight.',
          ),
        ];
  }
}
