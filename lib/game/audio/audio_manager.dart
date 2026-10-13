import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import 'audio_event.dart';

/// Telemetry record for a triggered audio playback event.
class AudioPlaybackRecord {
  final AudioEvent event;
  final AudioCategory category;
  final double effectiveVolume;
  final double pitch;
  final bool isLooping;
  final three.Vector3? emitterPosition;
  final DateTime timestamp;

  AudioPlaybackRecord({
    required this.event,
    required this.category,
    required this.effectiveVolume,
    this.pitch = 1.0,
    this.isLooping = false,
    this.emitterPosition,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Central audio management engine supporting volume buses, crossfading,
/// 3D distance-based spatial audio attenuation, and audio event dispatching.
class AudioManager extends ChangeNotifier {
  double _masterVolume = 1.0;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.85;
  double _ambientVolume = 0.6;
  bool _isMuted = false;

  AudioEvent? _currentMusic;
  AudioEvent? _currentAmbient;

  final three.Vector3 _listenerPosition = three.Vector3(0, 1.7, 0);

  final List<AudioPlaybackRecord> _playbackHistory = [];

  // Callbacks
  void Function(AudioEvent? musicEvent)? onMusicChanged;
  void Function(AudioEvent sfxEvent, double volume)? onSfxTriggered;

  AudioManager({
    double masterVolume = 1.0,
    double musicVolume = 0.7,
    double sfxVolume = 0.85,
    double ambientVolume = 0.6,
  })  : _masterVolume = masterVolume,
        _musicVolume = musicVolume,
        _sfxVolume = sfxVolume,
        _ambientVolume = ambientVolume;

  // --- Getters & Setters ---

  double get masterVolume => _masterVolume;
  set masterVolume(double val) {
    _masterVolume = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  double get musicVolume => _musicVolume;
  set musicVolume(double val) {
    _musicVolume = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  double get sfxVolume => _sfxVolume;
  set sfxVolume(double val) {
    _sfxVolume = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  double get ambientVolume => _ambientVolume;
  set ambientVolume(double val) {
    _ambientVolume = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  bool get isMuted => _isMuted;
  set isMuted(bool val) {
    _isMuted = val;
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  AudioEvent? get currentMusic => _currentMusic;
  AudioEvent? get currentAmbient => _currentAmbient;
  three.Vector3 get listenerPosition => _listenerPosition;
  List<AudioPlaybackRecord> get playbackHistory => List.unmodifiable(_playbackHistory);

  /// Updates 3D listener position (called from player/camera update cycle).
  void updateListenerPosition(three.Vector3 position) {
    _listenerPosition.setFrom(position);
  }

  /// Calculates 3D distance attenuation gain for a spatial sound emitter.
  double calculateSpatialGain(AudioCue cue, three.Vector3 emitterPosition) {
    final dist = _listenerPosition.distanceTo(emitterPosition);
    if (dist <= cue.spatialMinDistance) return 1.0;
    if (dist >= cue.spatialMaxDistance) return 0.0;

    // Linear roll-off with cubic ease for natural acoustic falloff
    final factor = (dist - cue.spatialMinDistance) / (cue.spatialMaxDistance - cue.spatialMinDistance);
    return math.max(0.0, (1.0 - factor) * (1.0 - factor));
  }

  /// Plays background music track.
  void playMusic(AudioEvent event, {bool loop = true}) {
    final cue = AudioRegistry.getCue(event);
    _currentMusic = event;

    final vol = _isMuted ? 0.0 : _masterVolume * _musicVolume * cue.defaultVolume;
    _recordPlayback(AudioPlaybackRecord(
      event: event,
      category: AudioCategory.music,
      effectiveVolume: vol,
      isLooping: loop,
    ));

    onMusicChanged?.call(event);
    notifyListeners();
  }

  /// Stops current music.
  void stopMusic() {
    _currentMusic = null;
    onMusicChanged?.call(null);
    notifyListeners();
  }

  /// Plays ambient environmental track.
  void playAmbient(AudioEvent event) {
    final cue = AudioRegistry.getCue(event);
    _currentAmbient = event;

    final vol = _isMuted ? 0.0 : _masterVolume * _ambientVolume * cue.defaultVolume;
    _recordPlayback(AudioPlaybackRecord(
      event: event,
      category: AudioCategory.ambient,
      effectiveVolume: vol,
      isLooping: true,
    ));
    notifyListeners();
  }

  /// Stops ambient environmental sound.
  void stopAmbient() {
    _currentAmbient = null;
    notifyListeners();
  }

  /// Triggers a sound effect (supports optional 3D spatial emitter).
  void playSfx(
    AudioEvent event, {
    three.Vector3? position,
    double volumeScale = 1.0,
    double pitch = 1.0,
  }) {
    if (_isMuted) return;

    final cue = AudioRegistry.getCue(event);
    double spatialGain = 1.0;
    if (position != null) {
      spatialGain = calculateSpatialGain(cue, position);
      if (spatialGain <= 0.001) return; // Completely inaudible, cull playback
    }

    final categoryVol = cue.category == AudioCategory.ambient ? _ambientVolume : _sfxVolume;
    final effectiveVolume = (_masterVolume * categoryVol * cue.defaultVolume * volumeScale * spatialGain).clamp(0.0, 1.0);

    final record = AudioPlaybackRecord(
      event: event,
      category: cue.category,
      effectiveVolume: effectiveVolume,
      pitch: pitch * cue.basePitch,
      emitterPosition: position != null ? three.Vector3(position.x, position.y, position.z) : null,
    );

    _recordPlayback(record);
    onSfxTriggered?.call(event, effectiveVolume);
  }

  /// Plays combat impact SFX with subtle randomized pitch variation.
  void playCombatSfx(AudioEvent event, {three.Vector3? position}) {
    // 0.95 to 1.05 pitch variation for organic impact variety
    final randomPitch = 0.95 + (math.Random().nextDouble() * 0.1);
    playSfx(event, position: position, pitch: randomPitch);
  }

  /// Plays vehicle SFX.
  void playVehicleSfx(AudioEvent event, {three.Vector3? position, double volumeScale = 1.0}) {
    playSfx(event, position: position, volumeScale: volumeScale);
  }

  /// Plays footstep audio with appropriate cadence based on sprint state.
  void playFootstep({required bool isSprinting, three.Vector3? position}) {
    final event = isSprinting ? AudioEvent.footstepSprint : AudioEvent.footstepWalk;
    final pitch = 0.9 + (math.Random().nextDouble() * 0.2);
    playSfx(event, position: position, pitch: pitch);
  }

  /// Plays tactile UI / narrative sound.
  void playUi(AudioEvent event) {
    playSfx(event);
  }

  void _recordPlayback(AudioPlaybackRecord record) {
    _playbackHistory.add(record);
    if (_playbackHistory.length > 50) {
      _playbackHistory.removeAt(0);
    }
  }

  /// Clears recent telemetry history (useful for test isolation).
  void clearHistory() {
    _playbackHistory.clear();
  }
}
