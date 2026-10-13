import 'package:flutter/material.dart';
import '../../game/combat/combat_system.dart';
import '../../game/inventory/item.dart';
import '../../game/story/story_act_manager.dart';
import '../../game/story/story_choice_system.dart';
import '../../game/systems/game_state.dart';

/// Minimal cinematic inventory dialog showcasing items,
/// documents, category filtering, consumable item usage,
/// equipment slots, and currency/reputation balance.
class InventorySheet extends StatefulWidget {
  final GameState gameState;
  final CombatSystem? combatSystem;
  final StoryChoiceSystem? storyChoiceSystem;
  final StoryActManager? storyActManager;
  final VoidCallback onClose;

  const InventorySheet({
    super.key,
    required this.gameState,
    this.combatSystem,
    this.storyChoiceSystem,
    this.storyActManager,
    required this.onClose,
  });

  @override
  State<InventorySheet> createState() => _InventorySheetState();
}

class _InventorySheetState extends State<InventorySheet> {
  ItemCategory? _selectedCategory;
  InventorySlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final slots = widget.gameState.inventory.getSlotsByCategory(_selectedCategory);

    return SafeArea(
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 520),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0F14).withAlpha(250),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF2C3542), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(220),
                blurRadius: 30,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Bar: Title, Money, Reputation, and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INVENTORY // AADI\'S GEAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SLOTS: ${widget.gameState.inventory.slotCount} / ${widget.gameState.inventory.capacity}',
                        style: const TextStyle(
                          color: Color(0xFF7A8799),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Money pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E28),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF2E3D4F)),
                        ),
                        child: Text(
                          '₹${widget.gameState.money}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Reputation pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E28),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF2E3D4F)),
                        ),
                        child: Text(
                          'REP: ${widget.gameState.reputation}',
                          style: const TextStyle(
                            color: Color(0xFFD97736),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Close button
                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2633),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(Icons.close, color: Colors.white70, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Category Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryTab(null, 'ALL'),
                    _buildCategoryTab(ItemCategory.document, 'DOCUMENTS'),
                    _buildCategoryTab(ItemCategory.keyItem, 'KEYS'),
                    _buildCategoryTab(ItemCategory.consumable, 'CONSUMABLES'),
                    _buildCategoryTab(ItemCategory.collectible, 'VALUABLES'),
                    _buildCategoryTab(ItemCategory.weapon, 'WEAPONS'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Narrative Act & Story Choice Alignment Strip
              if (widget.storyChoiceSystem != null || widget.storyActManager != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131822),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF222B38)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.storyActManager != null)
                        Text(
                          '${widget.storyActManager!.currentActData.romanTitle}: ${widget.storyActManager!.currentActData.title}',
                          style: const TextStyle(
                            color: Color(0xFFD97736),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      if (widget.storyChoiceSystem != null)
                        Row(
                          children: [
                            Text(
                              'POLICE: ${widget.storyChoiceSystem!.policeTrust}%  |  ',
                              style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'UNDERWORLD: ${widget.storyChoiceSystem!.criminalReputation}%  |  ',
                              style: const TextStyle(color: Color(0xFFEF5350), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'FAMILY: ${widget.storyChoiceSystem!.familyLoyalty}%',
                              style: const TextStyle(color: Color(0xFF81C784), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              const Divider(color: Color(0xFF1E2633), height: 1),
              const SizedBox(height: 14),

              // 3. Main Content: Grid & Inspector
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slots Grid
                    Expanded(
                      flex: 3,
                      child: slots.isEmpty
                          ? const Center(
                              child: Text(
                                'No items in this category.',
                                style: TextStyle(color: Color(0xFF6B7787), fontSize: 12),
                              ),
                            )
                          : GridView.builder(
                              itemCount: slots.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemBuilder: (context, index) {
                                final slot = slots[index];
                                final isSelected = _selectedSlot == slot;
                                final isEquipped = widget.gameState.inventory.isItemEquipped(slot.item.id);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSlot = slot;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF263345)
                                          : (isEquipped
                                              ? const Color(0xFF1E2835)
                                              : const Color(0xFF131720)),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFD97736)
                                            : (isEquipped
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF26303E)),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Icon(
                                            _getCategoryIcon(slot.item.category),
                                            color: isSelected
                                                ? Colors.white
                                                : (isEquipped
                                                    ? const Color(0xFF38BDF8)
                                                    : const Color(0xFF8694A6)),
                                            size: 24,
                                          ),
                                        ),
                                        if (isEquipped)
                                          Positioned(
                                            left: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF38BDF8).withAlpha(200),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: const Text(
                                                'EQ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (slot.quantity > 1)
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(200),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Text(
                                                'x${slot.quantity}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(width: 14),

                    // Item Inspector Details Pane
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF11151E),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF222B38)),
                        ),
                        child: _selectedSlot == null
                            ? const Center(
                                child: Text(
                                  'Select an item to inspect details.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF637082),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedSlot!.item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _selectedSlot!.item.category.name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFFD97736),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      if (widget.gameState.inventory
                                          .isItemEquipped(_selectedSlot!.item.id)) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF38BDF8).withAlpha(180),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: const Text(
                                            'EQUIPPED',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Item Effect Pills
                                  if (_selectedSlot!.item.effect != null) ...[
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        if (_selectedSlot!.item.effect!.healthRestore > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF16321F),
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: const Color(0xFF2E7D32)),
                                            ),
                                            child: Text(
                                              '+${_selectedSlot!.item.effect!.healthRestore.toInt()} HP',
                                              style: const TextStyle(
                                                color: Color(0xFF81C784),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (_selectedSlot!.item.effect!.staminaRestore > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10283A),
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: const Color(0xFF0288D1)),
                                            ),
                                            child: Text(
                                              '+${_selectedSlot!.item.effect!.staminaRestore.toInt()} STM',
                                              style: const TextStyle(
                                                color: Color(0xFF4FC3F7),
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _selectedSlot!.item.description,
                                        style: const TextStyle(
                                          color: Color(0xFFB1BAC7),
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Action Buttons: USE ITEM or EQUIP WEAPON
                                  if (_selectedSlot!.item.isUsable) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD97736),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () {
                                          final itemId = _selectedSlot!.item.id;
                                          widget.gameState.inventory.useItem(
                                            itemId,
                                            combatSystem: widget.combatSystem,
                                          );
                                          setState(() {
                                            if (!widget.gameState.inventory.hasItem(itemId)) {
                                              _selectedSlot = null;
                                            }
                                          });
                                        },
                                        child: const Text(
                                          'USE ITEM',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  if (_selectedSlot!.item.category == ItemCategory.weapon) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: widget.gameState.inventory
                                                    .isItemEquipped(_selectedSlot!.item.id)
                                                ? const Color(0xFFEF5350)
                                                : const Color(0xFF38BDF8),
                                          ),
                                          foregroundColor: widget.gameState.inventory
                                                  .isItemEquipped(_selectedSlot!.item.id)
                                              ? const Color(0xFFEF5350)
                                              : const Color(0xFF38BDF8),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (widget.gameState.inventory
                                                .isItemEquipped(_selectedSlot!.item.id)) {
                                              widget.gameState.inventory
                                                  .unequipItem(ItemCategory.weapon);
                                            } else {
                                              widget.gameState.inventory
                                                  .equipItem(_selectedSlot!.item.id);
                                            }
                                          });
                                        },
                                        child: Text(
                                          widget.gameState.inventory
                                                  .isItemEquipped(_selectedSlot!.item.id)
                                              ? 'UNEQUIP'
                                              : 'EQUIP WEAPON',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(ItemCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _selectedSlot = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD97736) : const Color(0xFF141922),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF2B3647),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8B9BB0),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ItemCategory cat) {
    switch (cat) {
      case ItemCategory.document:
        return Icons.description_outlined;
      case ItemCategory.keyItem:
        return Icons.vpn_key_outlined;
      case ItemCategory.consumable:
        return Icons.local_cafe_outlined;
      case ItemCategory.collectible:
        return Icons.watch_outlined;
      case ItemCategory.weapon:
        return Icons.shield_outlined;
      case ItemCategory.missionItem:
        return Icons.folder_special_outlined;
    }
  }
}
