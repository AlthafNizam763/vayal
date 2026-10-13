import '../combat/combat_system.dart';
import 'item.dart';

/// Complete offline inventory container managing player slots,
/// stacking mechanics, consumable usage effects, equipment slots,
/// and local storage serialization.
class Inventory {
  final int capacity;
  final List<InventorySlot> slots = [];

  // Phase 38: Equipment slots
  String? equippedWeaponId;
  String? equippedAttireId;

  // Callbacks
  void Function(Item item, ItemEffect? effect)? onItemUsed;
  void Function(String itemId, bool isEquipped)? onEquipmentChanged;

  Inventory({this.capacity = 16});

  int get slotCount => slots.length;
  bool get isFull => slots.length >= capacity;

  /// Adds an item to the inventory, stacking where permissible.
  bool addItem(Item item, {int quantity = 1}) {
    if (quantity <= 0) return true;

    int remainingToAdd = quantity;

    // 1. Fill existing non-full slots first if item is stackable
    if (item.maxStack > 1) {
      for (final slot in slots) {
        if (slot.item.id == item.id && !slot.isFull) {
          final space = slot.remainingSpace;
          final addCount = remainingToAdd > space ? space : remainingToAdd;
          slot.quantity += addCount;
          remainingToAdd -= addCount;
          if (remainingToAdd == 0) return true;
        }
      }
    }

    // 2. Add into new slots
    while (remainingToAdd > 0) {
      if (slots.length >= capacity) {
        return false; // Inventory full
      }

      final addCount = remainingToAdd > item.maxStack ? item.maxStack : remainingToAdd;
      slots.add(InventorySlot(item: item, quantity: addCount));
      remainingToAdd -= addCount;
    }

    return true;
  }

  /// Removes a quantity of an item by ID.
  bool removeItem(String itemId, {int quantity = 1}) {
    if (!hasItem(itemId, quantity: quantity)) return false;

    int remainingToRemove = quantity;

    for (int i = slots.length - 1; i >= 0; i--) {
      final slot = slots[i];
      if (slot.item.id == itemId) {
        if (slot.quantity <= remainingToRemove) {
          remainingToRemove -= slot.quantity;
          slots.removeAt(i);
        } else {
          slot.quantity -= remainingToRemove;
          remainingToRemove = 0;
        }

        if (remainingToRemove == 0) break;
      }
    }

    // Auto-unequip if no units remain
    if (!hasItem(itemId)) {
      if (equippedWeaponId == itemId) {
        equippedWeaponId = null;
        onEquipmentChanged?.call(itemId, false);
      }
      if (equippedAttireId == itemId) {
        equippedAttireId = null;
        onEquipmentChanged?.call(itemId, false);
      }
    }

    return true;
  }

  /// Consumes 1 unit of a usable item, applying physiological/tactical effects.
  ItemEffect? useItem(String itemId, {CombatSystem? combatSystem}) {
    final slotIndex = slots.indexWhere((s) => s.item.id == itemId);
    if (slotIndex == -1) return null;

    final item = slots[slotIndex].item;
    if (!item.isUsable) return null;

    final effect = item.effect;

    // Apply effects to live combat system if provided
    if (combatSystem != null && effect != null) {
      if (effect.healthRestore > 0) {
        combatSystem.healPlayer(effect.healthRestore);
      }
      if (effect.staminaRestore > 0) {
        combatSystem.restoreStamina(effect.staminaRestore);
      }
    }

    // Deduct 1 unit from inventory
    removeItem(itemId, quantity: 1);

    onItemUsed?.call(item, effect);
    return effect;
  }

  /// Equips an item into the appropriate equipment slot.
  bool equipItem(String itemId) {
    final slot = slots.firstWhere(
      (s) => s.item.id == itemId,
      orElse: () => InventorySlot(item: const Item(id: '', name: '', description: '', category: ItemCategory.collectible)),
    );
    if (slot.item.id.isEmpty) return false;

    if (slot.item.category == ItemCategory.weapon) {
      equippedWeaponId = itemId;
      onEquipmentChanged?.call(itemId, true);
      return true;
    } else if (slot.item.category == ItemCategory.collectible ||
        slot.item.category == ItemCategory.keyItem) {
      equippedAttireId = itemId;
      onEquipmentChanged?.call(itemId, true);
      return true;
    }

    return false;
  }

  /// Unequips active item in specified category.
  bool unequipItem(ItemCategory category) {
    if (category == ItemCategory.weapon && equippedWeaponId != null) {
      final old = equippedWeaponId!;
      equippedWeaponId = null;
      onEquipmentChanged?.call(old, false);
      return true;
    } else if (equippedAttireId != null) {
      final old = equippedAttireId!;
      equippedAttireId = null;
      onEquipmentChanged?.call(old, false);
      return true;
    }
    return false;
  }

  /// Checks if an item is currently equipped.
  bool isItemEquipped(String itemId) {
    return equippedWeaponId == itemId || equippedAttireId == itemId;
  }

  /// Verifies if a given quantity of an item exists in the inventory.
  bool hasItem(String itemId, {int quantity = 1}) {
    return getItemQuantity(itemId) >= quantity;
  }

  /// Counts total units of an item across all slots.
  int getItemQuantity(String itemId) {
    int total = 0;
    for (final slot in slots) {
      if (slot.item.id == itemId) {
        total += slot.quantity;
      }
    }
    return total;
  }

  /// Returns slots filtered by a specific category, or all slots if null.
  List<InventorySlot> getSlotsByCategory(ItemCategory? category) {
    if (category == null) return List.unmodifiable(slots);
    return slots.where((s) => s.item.category == category).toList();
  }

  void clear() {
    slots.clear();
    equippedWeaponId = null;
    equippedAttireId = null;
  }

  /// Serializes inventory state for offline persistence.
  Map<String, dynamic> toJson() => {
        'capacity': capacity,
        'slots': slots.map((s) => s.toJson()).toList(),
        'equippedWeaponId': equippedWeaponId,
        'equippedAttireId': equippedAttireId,
      };

  /// Restores inventory state from JSON and item database catalog.
  static Inventory fromJson(
    Map<String, dynamic> json,
    Map<String, Item> catalog,
  ) {
    final cap = (json['capacity'] as int?) ?? 16;
    final inventory = Inventory(capacity: cap);

    final rawSlots = json['slots'] as List? ?? [];
    for (final slotJson in rawSlots) {
      if (slotJson is Map) {
        final slot = InventorySlot.fromJson(
          Map<String, dynamic>.from(slotJson),
          catalog,
        );
        if (slot != null) {
          inventory.slots.add(slot);
        }
      }
    }

    inventory.equippedWeaponId = json['equippedWeaponId'] as String?;
    inventory.equippedAttireId = json['equippedAttireId'] as String?;

    return inventory;
  }
}
