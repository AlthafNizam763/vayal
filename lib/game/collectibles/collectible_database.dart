import 'package:three_js/three_js.dart' as three;
import 'collectible.dart';

/// Catalog of all hidden collectibles scattered across the coastal noir terrain.
class CollectibleDatabase {
  static List<Collectible> createDefaultCollectibles() => [
        // 1. Photograph
        Collectible(
          id: 'photo_harbor_1996',
          title: 'The Harbour Brotherhood (1996)',
          subtitle: 'Black & white photograph',
          type: CollectibleType.photograph,
          description:
              'A moisture-damaged photograph showing young Aadi, Rahu, and old shipyard dockers leaning against the rusted salt cranes.',
          memoryText:
              'Aadi recalls: "We thought the harbour belonged to us back then. Before Devraj built his warehouses, before the money started smelling like blood."',
          worldPosition: three.Vector3(2.5, 0.0, -9.0),
          locationName: 'Safehouse Attic',
          clueId: 'clue_harbor_photo_1996',
        ),

        // 2. Hidden Letter
        Collectible(
          id: 'letter_unsent_ravi',
          title: 'Ravi\'s Unsent Confession',
          subtitle: 'Folded inland aerogramme',
          type: CollectibleType.hiddenLetter,
          description:
              'A handwritten letter addressed to Aadi in Bangalore that was never posted. Blue ink smeared with rainwater drops.',
          memoryText:
              'Aadi recalls: "Father knew they were closing in on him. He wrote that staying away was the only way I would survive."',
          worldPosition: three.Vector3(14.0, 0.0, 22.0),
          locationName: 'Menon Family Residence',
          clueId: 'clue_unsent_letter',
        ),

        // 3. Document
        Collectible(
          id: 'doc_berth4_cargo',
          title: 'Night Manifest 04-B',
          subtitle: 'Carbon paper customs copy',
          type: CollectibleType.document,
          description:
              'Unregistered container shipment records marked with an ominous double-anchor stamp from Devraj Timber Yard.',
          memoryText:
              'Aadi recalls: "Customs inspectors never touched these crates. Everything stamped with double-anchors vanished into the night lorries."',
          worldPosition: three.Vector3(88.0, 0.0, -145.0),
          locationName: 'Harbour Berth 4',
          clueId: 'clue_berth4_manifest',
        ),

        // 4. Memory
        Collectible(
          id: 'memory_balan_bench',
          title: 'Memory: The Monsoon Rain of 2012',
          subtitle: 'Wooden tea stall bench',
          type: CollectibleType.memory,
          description:
              'A weathered teakwood bench outside Balan\'s stall where Aadi and Rahu drank hot ginger chai on rainy evenings.',
          memoryText:
              'Aadi recalls: "Balan used to warn us: \'Fast money has fast ghosts behind it, boys.\' We laughed back then. None of us are laughing now."',
          worldPosition: three.Vector3(-18.0, 0.0, 42.0),
          locationName: 'Balan\'s Tea Stall',
          clueId: 'clue_balan_memory',
        ),

        // 5. Story Clue
        Collectible(
          id: 'clue_brass_lighter',
          title: 'Engraved Brass Zippo',
          subtitle: 'Heavy brass lighter',
          type: CollectibleType.storyClue,
          description:
              'Scratched brass lighter engraved with the initials "D.E." found discarded near the harbour loading docks.',
          memoryText:
              'Aadi recalls: "Devraj gave these only to his inner circle enforcers. Captain Velu carried one identical to this."',
          worldPosition: three.Vector3(75.0, 0.0, -130.0),
          locationName: 'Harbour Security Office',
          clueId: 'clue_brass_lighter',
        ),

        // 6. Document
        Collectible(
          id: 'doc_police_memo_98',
          title: 'Veyrapuram Station Memo #409',
          subtitle: 'Stenciled confidential memorandum',
          type: CollectibleType.document,
          description:
              'Official inquiry closing the investigation into Ravi Menon\'s drowning as an "unfortunate coastal boating mishap."',
          memoryText:
              'Aadi recalls: "Case closed within thirty-six hours without an autopsy. Someone high up signed the clearance order."',
          worldPosition: three.Vector3(5.0, 0.0, 95.0),
          locationName: 'Police Station Alley',
          clueId: 'clue_police_memo_98',
        ),

        // 7. Photograph
        Collectible(
          id: 'photo_cracked_portrait',
          title: 'The Menon Family Portrait',
          subtitle: 'Framed black & white print',
          type: CollectibleType.photograph,
          description:
              'Framed portrait of Ravi Menon, young Aadi, and his mother before the family fell apart in the early 2000s.',
          memoryText:
              'Aadi recalls: "The last festival we spent together as a family before the debts started piling up."',
          worldPosition: three.Vector3(12.0, 0.0, 20.0),
          locationName: 'Menon Family Residence',
          clueId: 'clue_family_portrait',
        ),

        // 8. Hidden Letter
        Collectible(
          id: 'letter_blackmail_scrap',
          title: 'Charred Blackmail Threat',
          subtitle: 'Torn scorched paper scrap',
          type: CollectibleType.hiddenLetter,
          description:
              'Recovered from a metal oil drum: "Tell your son to stay away from the coastal timber or neither of you will see Onam."',
          memoryText:
              'Aadi recalls: "They were threatening father because he refused to sign over the old dock warehouse deed to Devraj."',
          worldPosition: three.Vector3(-45.0, 0.0, 78.0),
          locationName: 'Fish Market Warehouse',
          clueId: 'clue_blackmail_scrap',
        ),

        // 9. Memory
        Collectible(
          id: 'memory_railway_pier',
          title: 'Memory: The Night Rahu Ran',
          subtitle: 'Abandoned railway pier',
          type: CollectibleType.memory,
          description:
              'The abandoned pier where Aadi and Rahu agreed to meet the night before everything went up in flames.',
          memoryText:
              'Aadi recalls: "Rahu never showed up at the pier. For five years I thought he took the money. Now I know he was warned."',
          worldPosition: three.Vector3(110.0, 0.0, -180.0),
          locationName: 'Old Railway Pier',
          clueId: 'clue_railway_pier_memory',
        ),

        // 10. Story Clue
        Collectible(
          id: 'clue_syndicate_token',
          title: 'Devraj Steel Stamping Token',
          subtitle: 'Numbered coin-sized steel token',
          type: CollectibleType.storyClue,
          description:
              'Numbered shipping token #074 carried by drivers authorized to bypass the southern checkpost barricades.',
          memoryText:
              'Aadi recalls: "Show this coin at the southern highway barrier, and the guards wouldn\'t even ask to check your cargo."',
          worldPosition: three.Vector3(-60.0, 0.0, -110.0),
          locationName: 'Forest Hideout Shelter',
          clueId: 'clue_syndicate_token',
        ),
      ];
}
