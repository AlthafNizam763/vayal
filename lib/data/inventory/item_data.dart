import '../../game/inventory/item.dart';

/// Predefined inventory items tailored to the VAYAL crime thriller narrative.
class ItemData {
  static const Item oldPhotograph = Item(
    id: 'old_photograph',
    name: 'Weathered Photograph',
    description:
        'A faded photograph of Aadi, Rahu, and old gang members outside the harbour. On the back, handwritten ink reads: "You left us once. Don\'t do it again."',
    category: ItemCategory.document,
    maxStack: 1,
    value: 0,
    metadata: {'clue': true},
  );

  static const Item houseKey = Item(
    id: 'house_key',
    name: 'Brass House Key',
    description:
        'The front entrance door key to the Menon family residence in Veyrapuram.',
    category: ItemCategory.keyItem,
    maxStack: 1,
    value: 0,
  );

  static const Item fathersWatch = Item(
    id: 'fathers_watch',
    name: 'Ravi\'s Mechanical Watch',
    description:
        'A classic HMT mechanical wristwatch belonging to Ravi Menon. The crystal face is cracked, stopped at 11:42 PM.',
    category: ItemCategory.collectible,
    maxStack: 1,
    value: 1500,
  );

  static const Item gingerChai = Item(
    id: 'ginger_chai',
    name: 'Steaming Ginger Chai',
    description:
        'Spiced hot black tea from Balan\'s stall. Restores stamina and sharpens focus.',
    category: ItemCategory.consumable,
    maxStack: 5,
    value: 15,
    isUsable: true,
    effect: ItemEffect(
      healthRestore: 15.0,
      staminaRestore: 45.0,
      description: 'Restores 15 HP and 45 Stamina',
    ),
  );

  static const Item firstAidKit = Item(
    id: 'first_aid_kit',
    name: 'Emergency Medical Kit',
    description:
        'Sterile compression bandages, antiseptic tincture, and coagulant ointment. Heals severe wounds.',
    category: ItemCategory.consumable,
    maxStack: 3,
    value: 280,
    isUsable: true,
    effect: ItemEffect(
      healthRestore: 75.0,
      staminaRestore: 20.0,
      description: 'Heals 75 HP and 20 Stamina',
    ),
  );

  static const Item ayurvedicBalm = Item(
    id: 'ayurvedic_balm',
    name: 'Herbal Pain Balm',
    description:
        'Potent camphor and eucalyptus balm for soothing bruised muscles and restoring endurance.',
    category: ItemCategory.consumable,
    maxStack: 5,
    value: 65,
    isUsable: true,
    effect: ItemEffect(
      healthRestore: 25.0,
      staminaRestore: 60.0,
      description: 'Restores 25 HP and 60 Stamina',
    ),
  );

  static const Item docksMasterKey = Item(
    id: 'docks_master_key',
    name: 'Harbour Master Key',
    description:
        'Heavy brass master key stamped with Berth 4 insignia. Grants access to restricted cargo gates.',
    category: ItemCategory.keyItem,
    maxStack: 1,
    value: 0,
  );

  static const Item fathersDiary = Item(
    id: 'fathers_diary',
    name: 'Ravi\'s Pocket Ledger',
    description:
        'Handwritten notes detailing extortion payoffs and coded phone numbers linking the syndicate to municipal police.',
    category: ItemCategory.collectible,
    maxStack: 1,
    value: 2000,
    metadata: {'clue': true},
  );

  static const Item policeRadioReceiver = Item(
    id: 'police_radio_receiver',
    name: 'Veyrapuram Police Scanner',
    description:
        'Modified shortwave radio transceiver tuning into active police dispatcher frequencies.',
    category: ItemCategory.missionItem,
    maxStack: 1,
    value: 500,
    metadata: {'mission': true},
  );

  static const Item shippingLedger = Item(
    id: 'shipping_ledger',
    name: 'Torn Shipping Manifest',
    description:
        'Water-damaged manifest mentioning night cargo containers dispatched to Devraj Enterprises Harbour Berth 4.',
    category: ItemCategory.document,
    maxStack: 1,
    value: 0,
    metadata: {'clue': true},
  );

  static const Item pocketKnife = Item(
    id: 'pocket_knife',
    name: 'Folding Utility Knife',
    description:
        'Sharp utility blade with a blackened steel grip. Practical for cutting ropes or self-defense.',
    category: ItemCategory.weapon,
    maxStack: 1,
    value: 250,
  );

  static const Item lockpicks = Item(
    id: 'lockpicks',
    name: 'Tension Lockpicks',
    description:
        'Set of slim torsion wrenches and tempered spring-steel lockpicks for bypassing tumbler locks silently.',
    category: ItemCategory.consumable,
    maxStack: 10,
    value: 50,
  );

  static final Map<String, Item> allItems = {
    oldPhotograph.id: oldPhotograph,
    houseKey.id: houseKey,
    fathersWatch.id: fathersWatch,
    gingerChai.id: gingerChai,
    firstAidKit.id: firstAidKit,
    ayurvedicBalm.id: ayurvedicBalm,
    docksMasterKey.id: docksMasterKey,
    fathersDiary.id: fathersDiary,
    policeRadioReceiver.id: policeRadioReceiver,
    shippingLedger.id: shippingLedger,
    pocketKnife.id: pocketKnife,
    lockpicks.id: lockpicks,
  };

  static Item? getItem(String id) => allItems[id];
}
