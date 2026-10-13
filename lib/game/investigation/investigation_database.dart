import 'clue.dart';
import 'investigation_lead.dart';

/// Database seeding evidentiary clues and deductive case leads
/// for the Veyrapuram crime mystery narrative.
class InvestigationDatabase {
  static List<Clue> createDefaultClues() => [
        Clue(
          id: 'clue_fathers_watch',
          title: 'Shattered Mechanical Watch',
          description:
              'Ravi Menon\'s watch stopped at 11:42 PM. The impact fractures on the crystal indicate blunt external force rather than water pressure.',
          category: ClueCategory.physical,
          source: 'Ravi\'s Mechanical Watch',
          tags: ['ravi', 'murder', 'watch', 'time'],
          associatedItemId: 'fathers_watch',
        ),
        Clue(
          id: 'clue_shipping_ledger',
          title: 'Torn Shipping Manifest',
          description:
              'Water-damaged manifest mentioning unregistered night cargo containers dispatched to Devraj Enterprises Harbour Berth 4.',
          category: ClueCategory.document,
          source: 'Torn Shipping Manifest',
          tags: ['berth4', 'devraj', 'smuggling', 'cargo'],
          associatedItemId: 'shipping_ledger',
        ),
        Clue(
          id: 'clue_harbor_photo_1996',
          title: 'Harbour Brotherhood Photograph',
          description:
              'Old photograph showing Aadi, Rahu, and old shipyard dockers before Devraj monopolized the port facilities.',
          category: ClueCategory.photograph,
          source: 'Safehouse Attic',
          tags: ['rahu', 'aadi', 'harbour', 'brotherhood'],
          associatedCollectibleId: 'photo_harbor_1996',
        ),
        Clue(
          id: 'clue_unsent_letter',
          title: 'Ravi\'s Unsent Confession Letter',
          description:
              'Handwritten letter from Ravi warning Aadi to never return to Veyrapuram because Devraj was closing in on their warehouse deed.',
          category: ClueCategory.document,
          source: 'Menon Family Residence',
          tags: ['ravi', 'letter', 'devraj', 'threat'],
          associatedCollectibleId: 'letter_unsent_ravi',
        ),
        Clue(
          id: 'clue_berth4_manifest',
          title: 'Night Manifest 04-B',
          description:
              'Customs carbon slip showing timber containers bypassing checkpost inspections under Devraj\'s special corporate clearance.',
          category: ClueCategory.document,
          source: 'Harbour Berth 4',
          tags: ['berth4', 'manifest', 'smuggling', 'customs'],
          associatedCollectibleId: 'doc_berth4_cargo',
        ),
        Clue(
          id: 'clue_brass_lighter',
          title: 'Devraj Engraved Brass Zippo',
          subtitle: 'Heavy brass lighter with D.E. crest',
          description:
              'Scratched lighter with syndicate initials "D.E." dropped near the restricted container yard where Ravi was last seen.',
          category: ClueCategory.physical,
          source: 'Harbour Security Office',
          tags: ['devraj', 'lighter', 'velu', 'syndicate'],
          associatedCollectibleId: 'clue_brass_lighter',
        ),
        Clue(
          id: 'clue_police_memo_98',
          title: 'Police Case Closure Memo #409',
          description:
              'Confidential document signed by corrupt town inspector closing Ravi Menon\'s drowning as an accident without formal autopsy.',
          category: ClueCategory.forensics,
          source: 'Police Station Alley',
          tags: ['police', 'coverup', 'ravi', 'memo'],
          associatedCollectibleId: 'doc_police_memo_98',
        ),
        Clue(
          id: 'clue_blackmail_scrap',
          title: 'Charred Blackmail Threat',
          description:
              'Scorched note ordering Ravi to forfeit the dock warehouse deed or his family would face lethal consequences.',
          category: ClueCategory.document,
          source: 'Fish Market Warehouse',
          tags: ['blackmail', 'threat', 'rahu', 'warehouse'],
          associatedCollectibleId: 'letter_blackmail_scrap',
        ),
        Clue(
          id: 'clue_railway_pier_memory',
          title: 'Rahu\'s Disappearance at Pier',
          description:
              'Recollection of Rahu fleeing into the night after discovering that Devraj had planted police informants inside the old crew.',
          category: ClueCategory.testimony,
          source: 'Old Railway Pier',
          tags: ['rahu', 'pier', 'betrayal', 'truth'],
          associatedCollectibleId: 'memory_railway_pier',
        ),
        Clue(
          id: 'clue_syndicate_token',
          title: 'Numbered Highway Transit Token',
          description:
              'Stamped metal token #074 carried by syndicate lorry drivers to clear south checkposts without paperwork.',
          category: ClueCategory.physical,
          source: 'Forest Hideout Shelter',
          tags: ['syndicate', 'token', 'checkpost', 'highway'],
          associatedCollectibleId: 'clue_syndicate_token',
        ),
      ];

  static List<InvestigationLead> createDefaultLeads() => [
        InvestigationLead(
          id: 'lead_father_suspicious_death',
          title: 'The Truth of Ravi Menon\'s Death',
          hypothesis:
              'Did Ravi Menon die in a boating accident, or was his drowning staged by the syndicate?',
          requiredClueIds: {
            'clue_fathers_watch',
            'clue_police_memo_98',
            'clue_unsent_letter',
          },
          breakthroughTitle: 'Ravi Menon Was Murdered at Berth 4',
          breakthroughDescription:
              'The shattered watch crystals at 11:42 PM prove a violent altercation. Ravi\'s unsent letter confirms Devraj was threatening him over the dock deed, and corrupt police immediately fabricated a closed accidental drowning report to bury the murder.',
          storyFlagKey: 'father_truth_discovered',
        ),
        InvestigationLead(
          id: 'lead_harbour_smuggling_network',
          title: 'The Harbour Berth 4 Contraband Pipeline',
          hypothesis:
              'What illegal operations are moving through Berth 4 under Devraj Enterprises\' corporate shield?',
          requiredClueIds: {
            'clue_shipping_ledger',
            'clue_brass_lighter',
            'clue_berth4_manifest',
          },
          breakthroughTitle: 'Devraj\'s Secret Night Timber Smuggling Route',
          breakthroughDescription:
              'The torn ledger, the carbon night manifest, and the inner-circle brass lighter prove that Devraj Enterprises uses double-anchor timber shipments to traffic untaxed contraband through Berth 4 with municipal protection.',
          storyFlagKey: 'berth4_smuggling_unmasked',
        ),
        InvestigationLead(
          id: 'lead_rahu_disappearance',
          title: 'The Rahu "Betrayal" Conspiracy',
          hypothesis:
              'Did Rahu steal the gang funds and abandon Aadi, or was he forced into exile to save them?',
          requiredClueIds: {
            'clue_harbor_photo_1996',
            'clue_blackmail_scrap',
            'clue_railway_pier_memory',
          },
          breakthroughTitle: 'Rahu Never Betrayed the Gang',
          breakthroughDescription:
              'The charred threats and pier memories prove Rahu discovered the syndicate\'s plot to ambush Aadi. Rather than betraying the crew, Rahu severed all ties and went into deep exile to draw Devraj\'s gunmen away from Aadi.',
          storyFlagKey: 'rahu_innocence_proven',
        ),
      ];
}
