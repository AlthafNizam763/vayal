import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import 'time_of_day_period.dart';

/// Scalable in-game clock and day/night atmospheric lighting manager.
/// Drives the gradual progression of time across 24 in-game hours, triggers
/// period transitions (sunrise, morning, afternoon, sunset, night), and
/// smoothly blends sky, directional sun, and ambient illumination.
class GameTimeManager extends ChangeNotifier {
  // Current time in fractional hours (0.0 to 24.0)
  double _timeOfDay;

  // Rate of time progression: hours progressed per real second
  // 0.05 = ~24 real seconds for 1 game hour (~9.6 minutes for a full day)
  double timeSpeed;

  bool isPaused = false;

  // Cached state for change events
  late TimePeriod _currentPeriod;
  int _lastHourInt = -1;

  // Event Callbacks
  void Function(TimePeriod oldPeriod, TimePeriod newPeriod)? onPeriodChanged;
  void Function(int hour)? onHourChanged;

  GameTimeManager({
    double initialTime = 18.0, // Default to VAYAL's signature dusk/sunset
    this.timeSpeed = 0.04,
  }) : _timeOfDay = initialTime % 24.0 {
    _currentPeriod = calculatePeriod(_timeOfDay);
    _lastHourInt = _timeOfDay.floor();
  }

  double get timeOfDay => _timeOfDay;
  TimePeriod get currentPeriod => _currentPeriod;
  int get hour => _timeOfDay.floor() % 24;
  int get minute => ((_timeOfDay - _timeOfDay.floor()) * 60).floor() % 60;
  String get formattedTime => formattedTime24;
  bool get isNight => _currentPeriod == TimePeriod.night;
  bool get isDay => !isNight;

  /// Sets the in-game clock directly (0.0 to 24.0).
  void setTime(double newTime) {
    _timeOfDay = newTime % 24.0;
    _evaluatePeriodAndHour();
    notifyListeners();
  }

  /// Calculates the time period corresponding to any given hour.
  static TimePeriod calculatePeriod(double time) {
    final t = time % 24.0;
    if (t >= 5.0 && t < 8.0) {
      return TimePeriod.sunrise;
    } else if (t >= 8.0 && t < 12.0) {
      return TimePeriod.morning;
    } else if (t >= 12.0 && t < 17.0) {
      return TimePeriod.afternoon;
    } else if (t >= 17.0 && t < 19.5) {
      return TimePeriod.sunset;
    } else {
      return TimePeriod.night;
    }
  }

  /// Per-frame clock update and atmospheric lighting tick.
  void update({
    required double dt,
    required three.Scene scene,
    required three.DirectionalLight sun,
    required three.AmbientLight ambient,
  }) {
    if (!isPaused && dt > 0.0) {
      _timeOfDay = (_timeOfDay + dt * timeSpeed) % 24.0;
      _evaluatePeriodAndHour();
    }

    _applyAtmosphericLighting(scene, sun, ambient);
  }

  void _evaluatePeriodAndHour() {
    final newPeriod = calculatePeriod(_timeOfDay);
    if (newPeriod != _currentPeriod) {
      final old = _currentPeriod;
      _currentPeriod = newPeriod;
      onPeriodChanged?.call(old, newPeriod);
      notifyListeners();
    }

    final curHour = hour;
    if (curHour != _lastHourInt) {
      _lastHourInt = curHour;
      onHourChanged?.call(curHour);
    }
  }

  /// Modulates the sun position arc and blends colors dynamically.
  void _applyAtmosphericLighting(
    three.Scene scene,
    three.DirectionalLight sun,
    three.AmbientLight ambient,
  ) {
    // 1. Sun orbital coordinates (6.0 = East rise, 12.0 = Zenith, 18.0 = West set)
    final sunAngle = ((_timeOfDay - 6.0) / 12.0) * math.pi;
    final sunY = math.sin(sunAngle) * 35.0;
    final sunX = math.cos(sunAngle) * 35.0;

    sun.position.setValues(sunX, math.max(-2.0, sunY), 20.0);

    // 2. Interpolate lighting characteristics across period boundaries
    final period = _currentPeriod;
    scene.background = period.skyColor;
    sun.color = period.sunColor;
    sun.intensity = period.sunIntensity;
    ambient.color = period.ambientColor;
    ambient.intensity = period.ambientIntensity;
  }

  /// Returns 12-hour formatted time string, e.g. "06:45 AM" or "08:15 PM".
  String get formattedClock {
    final h24 = hour;
    final m = minute;
    final isPm = h24 >= 12;
    final h12 = h24 == 0 ? 12 : (h24 > 12 ? h24 - 12 : h24);
    final mStr = m.toString().padLeft(2, '0');
    final amPm = isPm ? 'PM' : 'AM';
    return '$h12:$mStr $amPm';
  }

  /// Returns 24-hour military formatted time string, e.g. "18:30".
  String get formattedTime24 {
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    return '$hStr:$mStr';
  }
}
