import 'package:flutter/foundation.dart';

/// Represents a historical change event recorded when a story flag is modified.
class StoryFlagChangeEvent {
  final DateTime timestamp;
  final String key;
  final dynamic oldValue;
  final dynamic newValue;
  final String? source;

  StoryFlagChangeEvent({
    required this.key,
    required this.oldValue,
    required this.newValue,
    this.source,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() =>
      'StoryFlagChangeEvent($key: $oldValue -> $newValue [source: $source])';
}

/// Phase 42: Central persistent story-state manager for VAYAL.
/// Tracks all major campaign decisions, faction allegiances, criminal records,
/// and narrative breakthroughs with change tracking and persistence.
class StoryFlagManager extends ChangeNotifier {
  // Predefined core campaign flag constants
  static const String metRahu = 'met_rahu';
  static const String helpedImran = 'helped_imran';
  static const String betrayedGang = 'betrayed_gang';
  static const String fatherTruthFound = 'father_truth_found';
  static const String fatherTruthDiscovered = 'father_truth_discovered';
  static const String policeTrust = 'police_trust';
  static const String criminalReputation = 'criminal_reputation';
  static const String familyLoyalty = 'family_loyalty';
  static const String meeraTrust = 'meera_trust';
  static const String diyaForgiveness = 'diya_forgiveness';
  static const String balanTrust = 'balan_trust';
  static const String truthVideoDiscovered = 'truth_video_discovered';
  static const String harbourAccessGranted = 'harbour_access_granted';
  static const String berth4Infiltrated = 'berth4_infiltrated';
  static const String veluConfronted = 'velu_confronted';
  static const String devrajConfronted = 'devraj_confronted';
  static const String informantSpared = 'informant_spared';
  static const String evidenceHandedToRaghav = 'evidence_handed_to_raghav';

  final Map<String, dynamic> _flags = {};
  final List<StoryFlagChangeEvent> _history = [];
  final Map<String, List<void Function(dynamic newVal, dynamic oldVal)>> _watchers = {};

  void Function(String key, dynamic newValue, dynamic oldValue)? onFlagChanged;

  StoryFlagManager({Map<String, dynamic>? initialFlags}) {
    _initDefaults();
    if (initialFlags != null) {
      _flags.addAll(initialFlags);
    }
  }

  void _initDefaults() {
    _flags[metRahu] = false;
    _flags[helpedImran] = false;
    _flags[betrayedGang] = false;
    _flags[fatherTruthFound] = false;
    _flags[fatherTruthDiscovered] = false;
    _flags[policeTrust] = 15;
    _flags[criminalReputation] = 40;
    _flags[familyLoyalty] = 50;
    _flags[meeraTrust] = 60;
    _flags[diyaForgiveness] = 35;
    _flags[balanTrust] = 50;
    _flags[truthVideoDiscovered] = false;
    _flags[harbourAccessGranted] = false;
    _flags[berth4Infiltrated] = false;
    _flags[veluConfronted] = false;
    _flags[devrajConfronted] = false;
    _flags[informantSpared] = false;
    _flags[evidenceHandedToRaghav] = false;
  }

  /// History of recorded flag modifications.
  List<StoryFlagChangeEvent> get history => List.unmodifiable(_history);

  /// Total active flags count.
  int get flagCount => _flags.length;

  /// Retrieves an unmodifiable copy of all active flags.
  Map<String, dynamic> getAllFlags() => Map.unmodifiable(_flags);

  /// Checks if a key exists in story state.
  bool hasFlag(String key) => _flags.containsKey(key);

  /// Sets or updates a story flag and notifies watchers.
  void setFlag(String key, dynamic value, {String? source}) {
    final oldVal = _flags[key];
    if (oldVal == value) return;

    _flags[key] = value;
    final event = StoryFlagChangeEvent(
      key: key,
      oldValue: oldVal,
      newValue: value,
      source: source,
    );
    _history.add(event);

    onFlagChanged?.call(key, value, oldVal);

    // Trigger individual key watchers
    final watchers = _watchers[key];
    if (watchers != null) {
      for (final watcher in List.from(watchers)) {
        watcher(value, oldVal);
      }
    }

    notifyListeners();
  }

  /// Convenience setter for boolean flags.
  void setBool(String key, bool value, {String? source}) =>
      setFlag(key, value, source: source);

  /// Convenience setter for integer scores.
  void setInt(String key, int value, {String? source}) =>
      setFlag(key, value, source: source);

  /// Reads a boolean flag. Returns [defaultValue] if flag is absent or not a bool.
  bool getBool(String key, [bool defaultValue = false]) {
    final val = _flags[key];
    if (val is bool) return val;
    return defaultValue;
  }

  /// Reads an integer flag (e.g. alignment scores, trust meters).
  int getInt(String key, [int defaultValue = 0]) {
    final val = _flags[key];
    if (val is int) return val;
    if (val is num) return val.toInt();
    return defaultValue;
  }

  /// Reads a string flag (e.g. final choice identifier).
  String getString(String key, [String defaultValue = '']) {
    final val = _flags[key];
    if (val is String) return val;
    return defaultValue;
  }

  /// Reads a double flag.
  double getDouble(String key, [double defaultValue = 0.0]) {
    final val = _flags[key];
    if (val is double) return val;
    if (val is num) return val.toDouble();
    return defaultValue;
  }

  /// Modifies an integer score by [delta] within [min] and [max].
  void modifyInt(String key, int delta, {int min = 0, int max = 100, String? source}) {
    final current = getInt(key, min);
    final clamped = (current + delta).clamp(min, max);
    setFlag(key, clamped, source: source);
  }

  /// Toggles a boolean flag.
  void toggle(String key, {String? source}) {
    final current = getBool(key, false);
    setFlag(key, !current, source: source);
  }

  /// Removes a flag from the story state.
  bool removeFlag(String key) {
    if (_flags.containsKey(key)) {
      final oldVal = _flags.remove(key);
      notifyListeners();
      onFlagChanged?.call(key, null, oldVal);
      return true;
    }
    return false;
  }

  /// Evaluates whether a map of required flag conditions is met.
  bool evaluate(Map<String, dynamic> conditions) {
    for (final entry in conditions.entries) {
      final val = _flags[entry.key];
      if (val != entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Registers a watcher callback for a specific flag key.
  void addFlagWatcher(String key, void Function(dynamic newVal, dynamic oldVal) callback) {
    _watchers.putIfAbsent(key, () => []).add(callback);
  }

  /// Unregisters a watcher callback.
  void removeFlagWatcher(String key, void Function(dynamic newVal, dynamic oldVal) callback) {
    _watchers[key]?.remove(callback);
  }

  /// Serializes all story flags to JSON for offline game saving.
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(_flags);

  /// Restores story flags from save data.
  void restoreFromJson(Map<String, dynamic> json) {
    _flags.clear();
    _initDefaults();
    _flags.addAll(json);
    notifyListeners();
  }

  /// Resets state to campaign initial defaults.
  void reset() {
    _flags.clear();
    _history.clear();
    _initDefaults();
    notifyListeners();
  }
}
