import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../player/player_camera.dart';
import 'cinematic_track.dart';

/// Central runtime controller for playing, updating, and skipping in-engine cutscenes.
class CinematicManager extends ChangeNotifier {
  bool _isPlaying = false;
  CinematicSequence? _currentSequence;
  double _currentTime = 0.0;
  double _letterboxFactor = 0.0; // 0.0 = full screen, 1.0 = full 2.35:1 letterbox bars
  String? _currentSpeaker;
  String? _currentSubtitle;

  VoidCallback? onSequenceStarted;
  VoidCallback? onSequenceCompleted;
  void Function(CinematicSequence sequence)? onSequenceComplete;
  VoidCallback? _onCompletionCallback;

  bool get isPlaying => _isPlaying;
  CinematicSequence? get currentSequence => _currentSequence;
  double get currentTime => _currentTime;
  double get letterboxFactor => _letterboxFactor;
  String? get currentSpeaker => _currentSpeaker;
  String? get currentSubtitle => _currentSubtitle;
  bool get canSkip => _currentSequence?.canSkip ?? true;

  /// Starts playing a cutscene sequence.
  void playSequence(CinematicSequence sequence, {VoidCallback? onComplete}) {
    _currentSequence = sequence;
    _currentTime = 0.0;
    _isPlaying = true;
    _onCompletionCallback = onComplete;

    final initialTransform = sequence.evaluate(0.0);
    _currentSpeaker = initialTransform.speaker;
    _currentSubtitle = initialTransform.subtitle;

    notifyListeners();
    onSequenceStarted?.call();
  }

  /// Skips the currently playing cutscene.
  void skipSequence() {
    if (!_isPlaying) return;
    _endSequence();
  }

  /// Alias for skipSequence.
  void skip() => skipSequence();

  /// Per-frame animation tick updating the camera and letterbox transitions.
  void update(double dt, PlayerCamera camera) {
    // Animate letterbox black bars
    final targetLetterbox = _isPlaying ? 1.0 : 0.0;
    final letterboxSpeed = math.min(1.0, 6.0 * dt);
    _letterboxFactor += (targetLetterbox - _letterboxFactor) * letterboxSpeed;

    if (!_isPlaying || _currentSequence == null) return;

    _currentTime += dt;

    if (_currentTime >= _currentSequence!.duration) {
      _endSequence();
      return;
    }

    // Evaluate interpolated transform
    final transform = _currentSequence!.evaluate(_currentTime);
    _currentSpeaker = transform.speaker;
    _currentSubtitle = transform.subtitle;

    // Apply directly to 3D perspective camera
    camera.camera.position.setValues(
      transform.cameraPosition.x,
      transform.cameraPosition.y,
      transform.cameraPosition.z,
    );
    camera.camera.lookAt(transform.targetPosition);
    camera.camera.fov = transform.fov;
    camera.camera.updateProjectionMatrix();

    notifyListeners();
  }

  void _endSequence() {
    _isPlaying = false;
    _currentSpeaker = null;
    _currentSubtitle = null;
    final callback = _onCompletionCallback;
    _onCompletionCallback = null;
    final endedSeq = _currentSequence;
    _currentSequence = null;

    notifyListeners();
    onSequenceCompleted?.call();
    if (endedSeq != null) {
      onSequenceComplete?.call(endedSeq);
    }
    callback?.call();
  }
}
