import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import '../audio/audio_manager.dart';
import 'weather_state.dart';

/// Central weather controller managing atmospheric visibility,
/// scene fog, procedural rain streaks, road wetness, and environmental audio.
class WeatherManager extends ChangeNotifier {
  WeatherState _currentState = WeatherState.clear;
  WeatherState _targetState = WeatherState.clear;

  // Transition interpolation
  double _transitionProgress = 1.0;
  double _transitionDuration = 4.0; // seconds

  // Visual Rain Mesh System
  three.Group? _rainGroup;
  final List<three.Mesh> _rainDrops = [];
  static const int _rainParticleCount = 64; // Optimized for 60 FPS on mobile

  // Callback
  void Function(WeatherState oldWeather, WeatherState newWeather)? onWeatherChanged;

  WeatherManager({WeatherState initialWeather = WeatherState.clear})
      : _currentState = initialWeather,
        _targetState = initialWeather;

  WeatherState get currentWeather => _currentState;
  WeatherState get targetWeather => _targetState;
  bool get isTransitioning => _transitionProgress < 1.0;
  bool get isRaining => _currentState.isRaining;

  /// Road surface wetness factor (0.0 dry to 1.0 drenched reflections)
  double get roadWetness => _currentState.roadWetness;

  /// Initializes lightweight 3D rain streaks in the ThreeJS scene.
  void initializeScene(three.Scene scene) {
    _rainGroup = three.Group();
    _rainGroup!.visible = _currentState.isRaining;

    final dropMat = three.MeshBasicMaterial();
    dropMat.color = three.Color.fromHex32(0xaaccff);
    dropMat.transparent = true;
    dropMat.opacity = 0.45;

    final dropGeo = three.CylinderGeometry(0.015, 0.015, 0.8, 3);
    final random = math.Random(42);

    for (int i = 0; i < _rainParticleCount; i++) {
      final drop = three.Mesh(dropGeo, dropMat);
      drop.position.setValues(
        (random.nextDouble() - 0.5) * 32.0,
        random.nextDouble() * 18.0,
        (random.nextDouble() - 0.5) * 32.0,
      );
      _rainDrops.add(drop);
      _rainGroup!.add(drop);
    }

    scene.add(_rainGroup!);
  }

  /// Initiates a smooth transition to a new weather condition.
  void setWeather(
    WeatherState state, {
    double duration = 3.5,
    AudioManager? audioManager,
  }) {
    if (_currentState == state && _targetState == state) return;

    final old = _currentState;
    _targetState = state;
    _transitionDuration = duration;
    _transitionProgress = 0.0;

    // Trigger audio change
    if (audioManager != null) {
      audioManager.playAmbient(state.ambientSound);
    }

    onWeatherChanged?.call(old, state);
    notifyListeners();
  }

  /// Per-frame animation tick updating rain particles, scene fog, and transitions.
  void update({
    required double dt,
    required three.Scene scene,
    required three.Vector3 playerPosition,
  }) {
    // 1. Advance weather transition
    if (_transitionProgress < 1.0) {
      _transitionProgress = math.min(1.0, _transitionProgress + (dt / _transitionDuration));
      if (_transitionProgress >= 1.0) {
        _currentState = _targetState;
        notifyListeners();
      }
    }

    // 2. Modulate Scene Fog based on weather
    final currentDensity = _currentState.fogDensity;
    final targetDensity = _targetState.fogDensity;
    final blendedDensity = currentDensity + (targetDensity - currentDensity) * _transitionProgress;

    if (blendedDensity > 0.001) {
      scene.fog = three.FogExp2(0x19202a, blendedDensity);
    } else {
      scene.fog = null;
    }

    // 3. Update Visual Rain Particles
    if (_rainGroup != null) {
      final isNowRaining = _currentState.isRaining || _targetState.isRaining;
      _rainGroup!.visible = isNowRaining;

      if (isNowRaining) {
        // Keep rain localized around the player/camera
        _rainGroup!.position.setValues(playerPosition.x, 0.0, playerPosition.z);

        const fallSpeed = 26.0; // m/s downwards
        const horizontalWind = 4.0; // slanted monsoon rain

        for (final drop in _rainDrops) {
          drop.position.y -= fallSpeed * dt;
          drop.position.x += horizontalWind * dt;

          // Recycle when hitting the ground
          if (drop.position.y <= 0.0) {
            drop.position.y = 16.0 + (drop.id % 4);
            drop.position.x = ((drop.id * 17) % 32) - 16.0;
            drop.position.z = ((drop.id * 23) % 32) - 16.0;
          }
        }
      }
    }
  }
}
