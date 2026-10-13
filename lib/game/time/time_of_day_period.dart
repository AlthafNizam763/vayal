import 'package:three_js/three_js.dart' as three;
import '../audio/audio_event.dart';

/// The 5 discrete atmospheric time-of-day periods across Veyrapuram.
enum TimePeriod {
  sunrise,
  morning,
  afternoon,
  sunset,
  night,
}

/// Metadata and atmospheric lighting properties for each time-of-day phase.
extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.sunrise:
        return 'Sunrise';
      case TimePeriod.morning:
        return 'Morning';
      case TimePeriod.afternoon:
        return 'Afternoon';
      case TimePeriod.sunset:
        return 'Sunset';
      case TimePeriod.night:
        return 'Night';
    }
  }

  String get shortCode {
    switch (this) {
      case TimePeriod.sunrise:
        return 'DAWN';
      case TimePeriod.morning:
        return 'MORN';
      case TimePeriod.afternoon:
        return 'NOON';
      case TimePeriod.sunset:
        return 'DUSK';
      case TimePeriod.night:
        return 'NITE';
    }
  }

  bool get isNight => this == TimePeriod.night;

  bool get isDay => !isNight;

  /// Multiplier for traffic frequency (0.0 to 1.0)
  double get trafficDensity {
    switch (this) {
      case TimePeriod.sunrise:
        return 0.35;
      case TimePeriod.morning:
        return 0.85;
      case TimePeriod.afternoon:
        return 0.65;
      case TimePeriod.sunset:
        return 1.00; // Peak evening rush
      case TimePeriod.night:
        return 0.20; // Sparse night driving
    }
  }

  /// Pedestrian population multiplier
  double get pedestrianDensity {
    switch (this) {
      case TimePeriod.sunrise:
        return 0.40;
      case TimePeriod.morning:
        return 0.90;
      case TimePeriod.afternoon:
        return 0.70;
      case TimePeriod.sunset:
        return 1.00;
      case TimePeriod.night:
        return 0.25;
    }
  }

  /// Ambient soundscape event associated with this period
  AudioEvent get ambientSound {
    switch (this) {
      case TimePeriod.sunrise:
      case TimePeriod.morning:
      case TimePeriod.afternoon:
        return AudioEvent.ambientForestWind;
      case TimePeriod.sunset:
      case TimePeriod.night:
        return AudioEvent.ambientVillageRain;
    }
  }

  // --- Lighting Color Presets (Hex values) ---
  int get skyColorHex {
    switch (this) {
      case TimePeriod.sunrise:
        return 0x2b2230; // Soft peach twilight
      case TimePeriod.morning:
        return 0x222d3d; // Clear deep blue
      case TimePeriod.afternoon:
        return 0x1f2733; // High tropical sky
      case TimePeriod.sunset:
        return 0x24141d; // Crimson-violet dusk
      case TimePeriod.night:
        return 0x0a0c10; // Dark noir midnight
    }
  }

  int get sunColorHex {
    switch (this) {
      case TimePeriod.sunrise:
        return 0xffb37a; // Warm amber sunrise
      case TimePeriod.morning:
        return 0xffeedb; // Crisp sunlight
      case TimePeriod.afternoon:
        return 0xffffff; // Intense midday
      case TimePeriod.sunset:
        return 0xeb7b42; // Deep fiery orange
      case TimePeriod.night:
        return 0x2f4260; // Pale moonlit beam
    }
  }

  double get sunIntensity {
    switch (this) {
      case TimePeriod.sunrise:
        return 0.85;
      case TimePeriod.morning:
        return 1.25;
      case TimePeriod.afternoon:
        return 1.35;
      case TimePeriod.sunset:
        return 1.10;
      case TimePeriod.night:
        return 0.22;
    }
  }

  int get ambientColorHex {
    switch (this) {
      case TimePeriod.sunrise:
        return 0x6e6578;
      case TimePeriod.morning:
        return 0xa6b2c2;
      case TimePeriod.afternoon:
        return 0x909caa;
      case TimePeriod.sunset:
        return 0x5e4f5a;
      case TimePeriod.night:
        return 0x1c2432;
    }
  }

  double get ambientIntensity {
    switch (this) {
      case TimePeriod.sunrise:
        return 0.45;
      case TimePeriod.morning:
        return 0.65;
      case TimePeriod.afternoon:
        return 0.60;
      case TimePeriod.sunset:
        return 0.50;
      case TimePeriod.night:
        return 0.32;
    }
  }

  /// ThreeJS color instances
  three.Color get skyColor => three.Color.fromHex32(skyColorHex);
  three.Color get sunColor => three.Color.fromHex32(sunColorHex);
  three.Color get ambientColor => three.Color.fromHex32(ambientColorHex);
}
