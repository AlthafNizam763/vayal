import '../inventory/inventory.dart';
import '../../data/inventory/item_data.dart';
import 'event_system.dart';
import '../cinematics/cutscene_trigger.dart';
import '../story/story_flag_manager.dart';
import '../story/story_reveal_manager.dart';

/// Central state profile managing player money, reputation, inventory,
/// narrative story progression act, and character relationships.
class GameState {
  int money;
  int reputation;
  int storyAct; // 1: HOME, 2: GHOSTS, 3: BLOOD, 4: THE TRUTH, 5: VAYAL

  final Inventory inventory;
  final EventSystem events;

  final Map<String, int> characterRelationships = {
    'meera': 60,
    'diya': 35,
    'balan': 50,
    'rahu': 20,
    'devraj': 0,
  };

  final Map<String, dynamic> persistentFlags = {};
  late final StoryFlagManager storyFlagManager;
  late final StoryRevealManager storyRevealManager;
  late final CutsceneTriggerSystem cutsceneTriggers;

  GameState({
    this.money = 500,
    this.reputation = 15,
    this.storyAct = 1,
    Inventory? customInventory,
    EventSystem? customEvents,
    StoryFlagManager? customStoryFlagManager,
  })  : inventory = customInventory ?? Inventory(capacity: 16),
        events = customEvents ?? EventSystem() {
    storyFlagManager = customStoryFlagManager ?? StoryFlagManager(initialFlags: persistentFlags);
    storyRevealManager = StoryRevealManager();
    cutsceneTriggers = CutsceneTriggerSystem();

    persistentFlags.addAll(storyFlagManager.getAllFlags());

    storyFlagManager.onFlagChanged = (k, v, old) {
      if (v == null) {
        persistentFlags.remove(k);
      } else {
        persistentFlags[k] = v;
      }
      // Phase 44: evaluate reveals whenever a flag changes
      storyRevealManager.evaluateReveals(storyFlagManager);
      // Phase 43: check if any cutscene should fire on flag set
      cutsceneTriggers.checkFlagChanged(k, v);
    };

    _initializeDefaultState();
  }

  void _initializeDefaultState() {
    // Add default starting belongings to Aadi's inventory
    inventory.addItem(ItemData.fathersWatch);
    inventory.addItem(ItemData.houseKey);
    inventory.addItem(ItemData.lockpicks);
  }

  /// Attempts to spend currency. Returns false if funds are insufficient.
  bool spendMoney(int amount) {
    if (amount < 0 || money < amount) return false;
    money -= amount;
    events.emit(MoneyChangedEvent(money, -amount));
    return true;
  }

  /// Grants currency to the player.
  void earnMoney(int amount) {
    if (amount <= 0) return;
    money += amount;
    events.emit(MoneyChangedEvent(money, amount));
  }

  /// Convenience alias for earnMoney.
  void addMoney(int amount) => earnMoney(amount);

  /// Modifies street reputation score (clamped between 0 and 100).
  void addReputation(int delta) {
    final oldRep = reputation;
    reputation = (reputation + delta).clamp(0, 100);
    final actualDelta = reputation - oldRep;
    if (actualDelta != 0) {
      events.emit(ReputationChangedEvent(reputation, actualDelta));
    }
  }

  /// Adjusts character affinity score (0 to 100).
  void modifyRelationship(String characterId, int delta) {
    final current = characterRelationships[characterId] ?? 50;
    characterRelationships[characterId] = (current + delta).clamp(0, 100);
  }

  int getRelationship(String characterId) {
    return characterRelationships[characterId] ?? 50;
  }

  void setFlag(String key, dynamic value) {
    persistentFlags[key] = value;
    storyFlagManager.setFlag(key, value);
  }

  bool getFlag(String key, {bool defaultValue = false}) {
    return storyFlagManager.getBool(key, defaultValue);
  }

  dynamic getFlagValue(String key) {
    return persistentFlags[key];
  }

  int getIntFlag(String key, {int defaultValue = 0}) {
    return storyFlagManager.getInt(key, defaultValue);
  }
}
