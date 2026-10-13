import '../world/world_region.dart';

/// The 5 narrative acts of VAYAL.
enum StoryAct {
  act1Home,
  act2Ghosts,
  act3Blood,
  act4TheTruth,
  act5Vayal,
}

/// Metadata and literary framing for each act of VAYAL.
class StoryActData {
  final StoryAct act;
  final int actNumber;
  final String romanTitle;
  final String title;
  final String tagline;
  final String synopsis;
  final WorldRegion primaryRegion;

  const StoryActData({
    required this.act,
    required this.actNumber,
    required this.romanTitle,
    required this.title,
    required this.tagline,
    required this.synopsis,
    required this.primaryRegion,
  });

  static const Map<StoryAct, StoryActData> allActs = {
    StoryAct.act1Home: StoryActData(
      act: StoryAct.act1Home,
      actNumber: 1,
      romanTitle: 'ACT I',
      title: 'HOME',
      tagline: 'Can a man escape the person he used to be?',
      synopsis:
          'Aadithyan "Aadi" Menon arrives in Veyrapuram after years away. He reunites with his mother Meera and sister Diya, seeking an honest life and peace.',
      primaryRegion: WorldRegion.village,
    ),
    StoryAct.act2Ghosts: StoryActData(
      act: StoryAct.act2Ghosts,
      actNumber: 2,
      romanTitle: 'ACT II',
      title: 'GHOSTS',
      tagline: 'The shadows don\'t forget your face.',
      synopsis:
          'A weathered photograph arrives with an ominous warning. Syndicate enforcers are spotted in the Old Town bazaar. The past refuses to stay buried.',
      primaryRegion: WorldRegion.oldTown,
    ),
    StoryAct.act3Blood: StoryActData(
      act: StoryAct.act3Blood,
      actNumber: 3,
      romanTitle: 'ACT III',
      title: 'BLOOD',
      tagline: 'Accidents always leave paper trails.',
      synopsis:
          'New clues emerge regarding the fatal "dock accident" of Aadi\'s father, Ravi Menon. Evidence leads directly into Devraj Enterprises\' Industrial Depot.',
      primaryRegion: WorldRegion.industrial,
    ),
    StoryAct.act4TheTruth: StoryActData(
      act: StoryAct.act4TheTruth,
      actNumber: 4,
      romanTitle: 'ACT IV',
      title: 'THE TRUTH',
      tagline: 'Brothers in the dark, strangers in the light.',
      synopsis:
          'Rahu, Aadi\'s former partner, returns to Veyrapuram. Decades of deceit, police collusion, and gang loyalties unravel on the coastal highway.',
      primaryRegion: WorldRegion.highway,
    ),
    StoryAct.act5Vayal: StoryActData(
      act: StoryAct.act5Vayal,
      actNumber: 5,
      romanTitle: 'ACT V',
      title: 'VAYAL',
      tagline: 'The reaping.',
      synopsis:
          'The final confrontation at Port Veyrapuram Berth 4 against crime lord Devraj. Aadi faces the ultimate choice that determines his fate.',
      primaryRegion: WorldRegion.harbour,
    ),
  };
}
