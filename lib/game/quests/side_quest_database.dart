import 'package:three_js/three_js.dart' as three;
import 'side_quest.dart';

/// Database defining all 3 character side stories for VAYAL.
class SideQuestDatabase {
  static List<SideQuest> get allQuests => [
    // 1. Diya's Side Story: Sister's Dilemma
    SideQuest(
      id: 'sq_diya_dilemma',
      title: "Sister's Dilemma",
      characterId: 'diya',
      characterName: 'Diya (Sister)',
      description:
          'Local moneylender thugs working for the syndicate have been harassing Diya at the family coconut orchard, claiming father left an unpaid promissory note.',
      cashReward: 500,
      reputationReward: 15,
      rewardDescription: '₹500 Cash • +15 Village Respect • Family Promissory Bond Cleared',
      completionSummary:
          'You confronted the collectors at Balan’s tea stall crossroads, recovered the seized document, and returned it to Diya. The family land is safe.',
      status: SideQuestStatus.available,
      steps: [
        SideQuestStep(
          id: 'diya_step_1',
          instruction: 'Meet Diya at the Village Coconut Grove to hear what happened.',
          targetLocation: three.Vector3(-12.0, 0.0, -6.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'diya_step_2',
          instruction: 'Confront the loan shark enforcers at Balan’s Chai Crossroads.',
          targetLocation: three.Vector3(12.0, 0.0, 7.5),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'diya_step_3',
          instruction: 'Return the retrieved land promissory note to Diya at the orchard.',
          targetLocation: three.Vector3(-12.0, 0.0, -6.0),
          targetRadius: 7.0,
        ),
      ],
    ),

    // 2. Old Mechanic Kumaran's Side Story: The Stolen Premier
    SideQuest(
      id: 'sq_mechanic_premier',
      title: 'The Stolen Premier',
      characterId: 'kumaran',
      characterName: 'Kumaran (Old Mechanic)',
      description:
          'Kumaran’s beloved 1978 Premier Padmini was stolen overnight by petty scrap thieves operating out of the Old Town industrial yard.',
      cashReward: 750,
      reputationReward: 20,
      rewardDescription: '₹750 Cash • Vintage Premier Padmini Unlocked • Kumaran’s Gratitude',
      completionSummary:
          'You located the vintage Premier in the back alleys of the scrapyard, dealt with the thieves, and returned it to Kumaran’s garage in pristine order.',
      status: SideQuestStatus.available,
      steps: [
        SideQuestStep(
          id: 'kumaran_step_1',
          instruction: 'Visit Kumaran’s Garage in Old Town to assess the vehicle theft.',
          targetLocation: three.Vector3(-58.0, 0.0, 2.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'kumaran_step_2',
          instruction: 'Track down the hidden Premier Padmini at the Old Town Scrapyard.',
          targetLocation: three.Vector3(-75.0, 0.0, 15.0),
          targetRadius: 8.0,
        ),
        SideQuestStep(
          id: 'kumaran_step_3',
          instruction: 'Deliver the recovered vintage vehicle back to Kumaran’s Workshop.',
          targetLocation: three.Vector3(-58.0, 0.0, 2.0),
          targetRadius: 7.0,
        ),
      ],
    ),

    // 3. Dock Worker Mohan's Side Story: Midnight Cargo
    SideQuest(
      id: 'sq_harbour_cargo',
      title: 'Midnight Cargo',
      characterId: 'mohan',
      characterName: 'Mohan (Dock Worker)',
      description:
          'Mohan noticed suspicious night shipments marked "Agricultural Supplies" being loaded at Port Berth 4 under heavy armed guard without customs clearance.',
      cashReward: 1000,
      reputationReward: 25,
      rewardDescription: '₹1,000 Cash • Syndicate Munitions Shipping Manifest • Port Union Respect',
      completionSummary:
          'You infiltrated Berth 4, examined Container #409, and obtained a shipping manifest proving the syndicate is importing illicit weapons through Port Veyrapuram.',
      status: SideQuestStatus.available,
      steps: [
        SideQuestStep(
          id: 'mohan_step_1',
          instruction: 'Meet dock worker Mohan near Port Veyrapuram Gate 2.',
          targetLocation: three.Vector3(0.0, 0.0, -205.0),
          targetRadius: 8.0,
        ),
        SideQuestStep(
          id: 'mohan_step_2',
          instruction: 'Infiltrate Berth 4 shipping lane and inspect Container #409.',
          targetLocation: three.Vector3(20.0, 0.0, -225.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'mohan_step_3',
          instruction: 'Deliver the illicit shipping manifest copy back to Mohan.',
          targetLocation: three.Vector3(0.0, 0.0, -205.0),
          targetRadius: 8.0,
        ),
      ],
    ),

    // 4. Village Schoolteacher Sushila's Side Story: A Roof Worth Learning Under
    SideQuest(
      id: 'sq_school_roof',
      title: 'A Roof Worth Learning Under',
      characterId: 'sushila',
      characterName: 'Sushila (Village Schoolteacher)',
      description:
          'The monsoon tore open the village school roof and the education office has ignored three requisition letters. Sushila raised most of the funds herself, but the tile supplier refuses to release the consignment until someone personally vouches for the delivery.',
      cashReward: 600,
      reputationReward: 15,
      rewardDescription: '₹600 Cash • +15 Village Respect • Village Poor Fund Ledger',
      completionSummary:
          'You escorted the tile consignment from the agent at Balan’s crossroads to the schoolyard, and the parents’ repair ledger now names the Menon family as founding donors.',
      steps: [
        SideQuestStep(
          id: 'sushila_step_1',
          instruction: 'Meet Sushila outside the village school.',
          targetLocation: three.Vector3(18.0, 0.0, 5.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'sushila_step_2',
          instruction: 'Sign for the tile consignment with the supplier at Balan’s Chai Crossroads.',
          targetLocation: three.Vector3(12.0, 0.0, 7.5),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'sushila_step_3',
          instruction: 'Guide the tiles back to the schoolyard before the next shower.',
          targetLocation: three.Vector3(18.0, 0.0, 5.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 5. Ferryman Selvam's Side Story: The Salt-Stained Compass
    SideQuest(
      id: 'sq_ferry_compass',
      title: 'The Salt-Stained Compass',
      characterId: 'selvam',
      characterName: 'Selvam (Old Ferryman)',
      description:
          'The village river ferry’s brass compass tumbled overboard when syndicate runners shoved past boarding passengers last week. Selvam suspects it was done on purpose so the ferry would miss the officer patrol crossings.',
      cashReward: 450,
      reputationReward: 12,
      rewardDescription: '₹450 Cash • +12 Village Respect • Ferryman’s Trust',
      completionSummary:
          'You dredged the compass from the ferry landing shallows and noted which runners were aboard that morning. Selvam now has both the compass and a reason to watch the water twice.',
      steps: [
        SideQuestStep(
          id: 'selvam_step_1',
          instruction: 'Talk to Selvam at the ferry landing north of the village.',
          targetLocation: three.Vector3(2.0, 0.0, 28.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'selvam_step_2',
          instruction: 'Search the ferry landing shallows for the discarded compass.',
          targetLocation: three.Vector3(5.0, 0.0, 32.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'selvam_step_3',
          instruction: 'Return the compass to Selvam at the landing.',
          targetLocation: three.Vector3(2.0, 0.0, 28.0),
          targetRadius: 7.0,
        ),
      ],
    ),

    // 6. Pawnshop Broker Rehman's Side Story: Grandmother's Gold Chain
    SideQuest(
      id: 'sq_pawn_heirloom',
      title: 'Grandmother’s Gold Chain',
      characterId: 'informant',
      characterName: 'Rehman (Pawnshop Broker)',
      description:
          'A frightened village grandmother pawned her late husband’s gold chain in Rehman’s old town shop to pay syndicate “protection arrears”. She wants it back but dares not cross the shopfloor’s backroom creditors alone.',
      cashReward: 550,
      reputationReward: 18,
      rewardDescription: '₹550 Cash • +18 Village Respect • Syndicate Ledger Excerpt',
      completionSummary:
          'You negotiated with the pawn backroom, reclaimed the chain, and caught a glimpse of a creditor notebook listing weekly payments routed to a Devraj Enterprises shell account.',
      steps: [
        SideQuestStep(
          id: 'pawn_step_1',
          instruction: 'Speak with the grandmother on the shore road and hear the whole account.',
          targetLocation: three.Vector3(22.0, 0.0, -5.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'pawn_step_2',
          instruction: 'Find Rehman’s pawnshop in the Old Town Bazaar.',
          targetLocation: three.Vector3(-60.0, 0.0, 10.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'pawn_step_3',
          instruction: 'Buy back the gold chain and carry it back to the shore road.',
          targetLocation: three.Vector3(22.0, 0.0, -5.0),
          targetRadius: 7.0,
        ),
      ],
    ),

    // 7. Old Town Weaver Sujatha's Side Story: Festival Lights
    SideQuest(
      id: 'sq_bazaar_festival',
      title: 'Festival Lights',
      characterId: 'sujatha',
      characterName: 'Sujatha (Old Town Weaver)',
      description:
          'The Old Town bazaar’s festival arch lights were severed three nights in a row. Electricians blame weather; traders blame the syndicate squeezing festival stallholders into paid “security”.',
      cashReward: 700,
      reputationReward: 20,
      rewardDescription: '₹700 Cash • +20 Village Respect • Old Town Gratitude',
      completionSummary:
          'You traced the cut cables to a warehouse wall tap fitted after hours, photographed it, and warned the cutters off. The arch glowed on opening night, and the traders no longer fear the Protection Committee.',
      steps: [
        SideQuestStep(
          id: 'sujatha_step_1',
          instruction: 'Meet Sujatha beside the festival arch in the Old Town Bazaar.',
          targetLocation: three.Vector3(-58.0, 0.0, -20.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'sujatha_step_2',
          instruction: 'Trace the severed wire to the wall tap behind the bazaar godown.',
          targetLocation: three.Vector3(-72.0, 0.0, -5.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'sujatha_step_3',
          instruction: 'Report what you found to Sujatha at the arch.',
          targetLocation: three.Vector3(-58.0, 0.0, -20.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 8. Temple Priest Parameshwaran's Side Story: The Temple Pond Ledger
    SideQuest(
      id: 'sq_tempond_ledger',
      title: 'The Temple Pond Ledger',
      characterId: 'parameshwaran',
      characterName: 'Parameshwaran (Temple Priest)',
      description:
          'Old donation ledgers kept in the temple storeroom are said to record every offering the syndicate ever used to “return” dock-haul money. Parameshwaran believes clearing the flooded storeroom will show whose names cleaned stolen cash.',
      cashReward: 650,
      reputationReward: 22,
      rewardDescription: '₹650 Cash • Donation Ledger Excerpt • Temple Records Restored',
      completionSummary:
          'You rescued the water-damaged donation ledgers from the storeroom. Inside, one page tallies repeated “festival donations” from Devraj Enterprises in the exact weeks contraband ran through Berth 4.',
      steps: [
        SideQuestStep(
          id: 'parameshwaran_step_1',
          instruction: 'Reach the Old Town temple by the bazaar road.',
          targetLocation: three.Vector3(-70.0, 0.0, -8.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'parameshwaran_step_2',
          instruction: 'Wade into the flooded temple storeroom to retrieve the old donation ledgers.',
          targetLocation: three.Vector3(-72.0, 0.0, -12.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'parameshwaran_step_3',
          instruction: 'Bring the donation ledgers back to Parameshwaran.',
          targetLocation: three.Vector3(-70.0, 0.0, -8.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 9. Informant's Side Story: The Lookout Bench
    SideQuest(
      id: 'sq_lookout_bench',
      title: 'The Lookout Bench',
      characterId: 'informant',
      characterName: 'Rehman (Pawnshop Broker)',
      description:
          'The informant needs coded notes walked from an Old Town bench to a discreet drop in the industrial district — nobody trustworthy crosses that boundary on foot anymore.',
      cashReward: 800,
      reputationReward: 20,
      rewardDescription: '₹800 Cash • Syndicate Duty Roster Tear • +18 Village Respect',
      completionSummary:
          'You delivered the coded notes to the drop point past the cargo carriageway. In return you glimpsed a torn roster page noting “R. Menon — berth duty — no release”, a chilling echo of your father’s fate.',
      steps: [
        SideQuestStep(
          id: 'lookout_step_1',
          instruction: 'Collect the coded notes from the lookout bench in Old Town.',
          targetLocation: three.Vector3(-55.0, 0.0, -5.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'lookout_step_2',
          instruction: 'Carry the notes into the Industrial District without being stopped.',
          targetLocation: three.Vector3(48.0, 0.0, -2.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'lookout_step_3',
          instruction: 'Slip the notes under the scrap bin at the drop point and slip away.',
          targetLocation: three.Vector3(55.0, 0.0, 5.0),
          targetRadius: 5.0,
        ),
      ],
    ),

    // 10. Industrial Canteen Matron Lakshmi's Side Story: Sick Coolies, Sick Money
    SideQuest(
      id: 'sq_coolie_medicine',
      title: 'Sick Coolies, Sick Money',
      characterId: 'lakshmi',
      characterName: 'Lakshmi (Depot Canteen Matron)',
      description:
          'Dock coolies unloading syndicate freight at the industrial depot are falling ill from substandard cement bags, and the company doctor has stopped visiting. Lakshmi is collecting canteen money for a private chemist run.',
      cashReward: 900,
      reputationReward: 20,
      rewardDescription: '₹900 Cash • +18 Village Respect • Chemist’s Receipt',
      completionSummary:
          'You gathered the canteen collections and personally bought the medicine from the industrial chemist. Lakshmi’s coolies now owe you, and one whispered that sick leave was being scrubbed from the duty roster.',
      steps: [
        SideQuestStep(
          id: 'lakshmi_step_1',
          instruction: 'Meet Lakshmi at the depot canteen in the Industrial District.',
          targetLocation: three.Vector3(55.0, 0.0, -10.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'lakshmi_step_2',
          instruction: 'Collect the medicine batch from the industrial chemist counter.',
          targetLocation: three.Vector3(65.0, 0.0, 2.5),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'lakshmi_step_3',
          instruction: 'Return with the medicine to the canteen.',
          targetLocation: three.Vector3(55.0, 0.0, -10.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 11. Forest Ranger Bharath's Side Story: Trap Lines in Teak
    SideQuest(
      id: 'sq_teak_snares',
      title: 'Trap Lines in Teak',
      characterId: 'bharath',
      characterName: 'Bharath (Forest Watcher)',
      description:
          'Illegal snares have appeared along the northern teak forest path, and poachers now patrol it at night. Bharath wants the trap lines collected so the wildlife inspector has evidence for the district report.',
      cashReward: 500,
      reputationReward: 18,
      rewardDescription: '₹500 Cash • +18 Village Respect • Snare Evidence Bundle',
      completionSummary:
          'You walked the forest round and dismantled the snare traps into an evidence bundle. Bharath’s warden report names the syndicate’s northward timber contract as the source.',
      steps: [
        SideQuestStep(
          id: 'bharath_step_1',
          instruction: 'Find Bharath at the forest watcher’s hut in the Northern Teak Forest.',
          targetLocation: three.Vector3(-6.0, 0.0, 66.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'bharath_step_2',
          instruction: 'Follow the path deeper into the teak and pull the first snare.',
          targetLocation: three.Vector3(6.0, 0.0, 74.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'bharath_step_3',
          instruction: 'Follow the second snare trail and collect the last snare wires.',
          targetLocation: three.Vector3(12.0, 0.0, 80.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'bharath_step_4',
          instruction: 'Return the evidence bundle to Bharath at the hut.',
          targetLocation: three.Vector3(-6.0, 0.0, 66.0),
          targetRadius: 7.0,
        ),
      ],
    ),

    // 12. Highway Shopkeeper Gopal's Side Story: The Mango Cart Shortcut
    SideQuest(
      id: 'sq_mango_cart',
      title: 'The Mango Cart Shortcut',
      characterId: 'gopal',
      characterName: 'Gopal (Highway Shopkeeper)',
      description:
          'Gopal’s cart driver vanished taking a forest shortcut to the highway shops. Gopal fears the syndicate decided his fruit trade no longer suits the corridor toll.',
      cashReward: 720,
      reputationReward: 18,
      rewardDescription: '₹720 Cash • +16 Village Respect • Salvaged Cart Wheels',
      completionSummary:
          'You found the overturned cart along the forest shortcut, righted it, and walked it back to Gopal’s shop. He now says he would rather lose a season of mangoes than pay the toll again.',
      steps: [
        SideQuestStep(
          id: 'gopal_step_1',
          instruction: 'Meet Gopal at his roadside shop on the Coastal Highway.',
          targetLocation: three.Vector3(5.0, 0.0, -132.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'gopal_step_2',
          instruction: 'Track the abandoned mango cart along the forest shortcut.',
          targetLocation: three.Vector3(-4.0, 0.0, 70.0),
          targetRadius: 7.0,
        ),
        SideQuestStep(
          id: 'gopal_step_3',
          instruction: 'Bring word of the recovered cart back to Gopal’s shop.',
          targetLocation: three.Vector3(5.0, 0.0, -132.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 13. Central Avenue Tailor Pradeep's Side Story: The Tailor's Deadline
    SideQuest(
      id: 'sq_tailor_deadline',
      title: 'The Tailor’s Deadline',
      characterId: 'pradeep',
      characterName: 'Pradeep (Central Avenue Tailor)',
      description:
          'Pradeep promised a police precinct a retirement uniform for tomorrow morning’s ceremony, but his fabric consignment was “impounded” by an Industrial District gate guard demanding a right-of-passage fee.',
      cashReward: 850,
      reputationReward: 22,
      rewardDescription: '₹850 Cash • +20 Village Respect • Precinct Trust',
      completionSummary:
          'You retrieved the impounded fabric from the industrial gate without paying the toll. Pradeep stitched the retirement uniform through the night — and put your family name on the inside label.',
      steps: [
        SideQuestStep(
          id: 'pradeep_step_1',
          instruction: 'Speak with Pradeep at his tailor shop on Central Avenue.',
          targetLocation: three.Vector3(-8.0, 0.0, -68.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'pradeep_step_2',
          instruction: 'Collect the impounded fabric consignment from the Industrial District gate.',
          targetLocation: three.Vector3(58.0, 0.0, 6.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'pradeep_step_3',
          instruction: 'Deliver the fabric to Pradeep before the precinct ceremony.',
          targetLocation: three.Vector3(-8.0, 0.0, -68.0),
          targetRadius: 5.0,
        ),
      ],
    ),

    // 14. City Bus Conductor Suresh's Side Story: Late Shift, Wrong Bus
    SideQuest(
      id: 'sq_route7_cashbox',
      title: 'Late Shift, Wrong Bus',
      characterId: 'suresh',
      characterName: 'Suresh (City Bus Conductor)',
      description:
          'The last Central Avenue city bus was diverted off its route by four “passengers” and the conductor’s cash box disappeared. Police logged the incident as a fare dispute. Suresh remembers every face.',
      cashReward: 750,
      reputationReward: 20,
      rewardDescription: '₹750 Cash • +20 Village Respect • Route 7 Gratitude',
      completionSummary:
          'You traced the diverted bus route through city lanes and pressed the fare-collector crew into returning the cash box before the blotter closed the case without a word.',
      steps: [
        SideQuestStep(
          id: 'suresh_step_1',
          instruction: 'Meet Suresh at the last route-7 bus stop on Central Avenue.',
          targetLocation: three.Vector3(10.0, 0.0, -72.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'suresh_step_2',
          instruction: 'Trace the diverted route where four “passengers” forced the bus off.',
          targetLocation: three.Vector3(0.0, 0.0, -88.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'suresh_step_3',
          instruction: 'Confront the crew at the fish depot and get the cash box back to Suresh.',
          targetLocation: three.Vector3(10.0, 0.0, -72.0),
          targetRadius: 5.0,
        ),
      ],
    ),

    // 15. Lighthouse Keeper's Wife Annamma's Side Story: Letters to the Lighthouse
    SideQuest(
      id: 'sq_lighthouse_letters',
      title: 'Letters to the Lighthouse',
      characterId: 'annamma',
      characterName: 'Annamma (Lighthouse Keeper’s Wife)',
      description:
          'Annamma writes weekly letters to her husband at the coastlight cottage, but the carriers refuse the light road and one bundle after another has gone unanswered. She asks you to walk the light road and hand them over personally.',
      cashReward: 500,
      reputationReward: 15,
      rewardDescription: '₹500 Cash • +15 Village Respect • Lighthouse Lantern Charm',
      completionSummary:
          'You carried Annamma’s letters up the harbour light road. At the cottage the keeper read each aloud, pausing on one line about “boats arriving without lights”. He pressed his spare lantern charm into your hand.',
      steps: [
        SideQuestStep(
          id: 'annamma_step_1',
          instruction: 'Collect the letter bundle from Annamma near the Port Veyrapuram gates.',
          targetLocation: three.Vector3(-10.0, 0.0, -198.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'annamma_step_2',
          instruction: 'Walk the light road out to the coastlight cottage.',
          targetLocation: three.Vector3(14.0, 0.0, -192.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'annamma_step_3',
          instruction: 'Return word of the delivered letters to Annamma by the gates.',
          targetLocation: three.Vector3(-10.0, 0.0, -198.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 16. Highway Shrine Caretaker Otthakkar's Side Story: Totem on the Coastline
    SideQuest(
      id: 'sq_shrine_totem',
      title: 'Totem on the Coastline',
      characterId: 'otthakkar',
      characterName: 'Otthakkar (Highway Shrine Caretaker)',
      description:
          'A truck accident knocked the shrine’s protecting stone totem into the sea-side scrub, and traffickers now use the unprotected stretch as a quiet handover point. Otthakkar wants the totem raised before another convoy passes.',
      cashReward: 600,
      reputationReward: 20,
      rewardDescription: '₹600 Cash • +20 Village Respect • Shrine Bell Charm',
      completionSummary:
          'You brought the coastline totem back to its stone plinth and rang the shrine bell twice at dusk. Otthakkar says the smell of rain near the shrine finally feels honest again.',
      steps: [
        SideQuestStep(
          id: 'otthakkar_step_1',
          instruction: 'Meet Otthakkar at the small roadside shrine on the Coastal Highway.',
          targetLocation: three.Vector3(-5.0, 0.0, -145.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'otthakkar_step_2',
          instruction: 'Search the sea-side scrub where the stone totem rolled.',
          targetLocation: three.Vector3(-12.0, 0.0, -152.0),
          targetRadius: 6.0,
        ),
        SideQuestStep(
          id: 'otthakkar_step_3',
          instruction: 'Carry the stone totem back to the shrine plinth.',
          targetLocation: three.Vector3(-5.0, 0.0, -145.0),
          targetRadius: 6.0,
        ),
      ],
    ),

    // 17. Village Widower Ashokan's Side Story: The Chess Bench of Ravi Menon
    SideQuest(
      id: 'sq_chess_bench',
      title: 'The Chess Bench of Ravi Menon',
      characterId: 'ashokan',
      characterName: 'Ashokan (Village Widower)',
      description:
          'Ashokan and your late father played chess every evening on the same village bench. The municipal renumbering erased the plaque marking that bench. Ashokan wants it re-carved and reinstalled exactly where the games were played.',
      cashReward: 400,
      reputationReward: 25,
      rewardDescription: '₹400 Cash • +25 Village Respect • Father’s Carved Chess Knight',
      completionSummary:
          'You helped Ashokan re-carve the missing plaque and reinstall it at the bench. Under the paint he carved a small chess knight — the same shape your father used for middle-game attacks.',
      steps: [
        SideQuestStep(
          id: 'ashokan_step_1',
          instruction: 'Sit with Ashokan at the old chess bench in the village.',
          targetLocation: three.Vector3(14.0, 0.0, -3.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'ashokan_step_2',
          instruction: 'Visit the municipal post office in the main city to have the plaque re-carved.',
          targetLocation: three.Vector3(-2.0, 0.0, -72.0),
          targetRadius: 5.0,
        ),
        SideQuestStep(
          id: 'ashokan_step_3',
          instruction: 'Return the plaque to Ashokan and fix it back onto the bench.',
          targetLocation: three.Vector3(14.0, 0.0, -3.0),
          targetRadius: 5.0,
        ),
      ],
    ),
  ];
}
