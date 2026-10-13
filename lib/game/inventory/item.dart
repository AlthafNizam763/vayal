/// Supported item classifications in VAYAL.
enum ItemCategory {
  keyItem,
  document,
  consumable,
  weapon,
  missionItem,
  collectible,
}

/// Immediate physiological or tactical benefits applied when an item is consumed.
class ItemEffect {
  final double healthRestore;
  final double staminaRestore;
  final int reputationBonus;
  final String? description;

  const ItemEffect({
    this.healthRestore = 0.0,
    this.staminaRestore = 0.0,
    this.reputationBonus = 0,
    this.description,
  });
}

/// Represents an item entity in the game.
class Item {
  final String id;
  final String name;
  final String description;
  final ItemCategory category;
  final int maxStack;
  final int value; // monetary value in ₹
  final bool isUsable;
  final bool isDroppable;
  final ItemEffect? effect;
  final Map<String, dynamic>? metadata;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.maxStack = 1,
    this.value = 0,
    this.isUsable = false,
    this.isDroppable = false,
    this.effect,
    this.metadata,
  });
}

/// An inventory container slot storing an item reference and its quantity.
class InventorySlot {
  final Item item;
  int quantity;

  InventorySlot({
    required this.item,
    this.quantity = 1,
  });

  bool get isFull => quantity >= item.maxStack;
  int get remainingSpace => item.maxStack - quantity;

  Map<String, dynamic> toJson() => {
    'itemId': item.id,
    'quantity': quantity,
  };

  static InventorySlot? fromJson(
    Map<String, dynamic> json,
    Map<String, Item> catalog,
  ) {
    final id = (json['itemId'] ?? json['id']) as String?;
    final count = (json['quantity'] ?? json['count']) as int? ?? 1;
    if (id == null || !catalog.containsKey(id)) return null;
    return InventorySlot(item: catalog[id]!, quantity: count);
  }
}
