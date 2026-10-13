import '../audio/audio_event.dart';

/// The 5 lightweight, mobile-optimized weather states in Veyrapuram.
enum WeatherState {
  clear,
  cloudy,
  rain,
  heavyRain,
  fog,
}

/// Metadata and visual/environmental parameters for each weather condition.
extension WeatherStateExtension on WeatherState {
  String get displayName {
    switch (this) {
      case WeatherState.clear:
        return 'Clear';
      case WeatherState.cloudy:
        return 'Cloudy';
      case WeatherState.rain:
        return 'Monsoon Rain';
      case WeatherState.heavyRain:
        return 'Heavy Storm';
      case WeatherState.fog:
        return 'Dense Fog';
    }
  }

  String get shortCode {
    switch (this) {
      case WeatherState.clear:
        return 'CLEAR';
      case WeatherState.cloudy:
        return 'CLOUD';
      case WeatherState.rain:
        return 'RAIN';
      case WeatherState.heavyRain:
        return 'STORM';
      case WeatherState.fog:
        return 'FOG';
    }
  }

  /// Fog density for ThreeJS scene
  double get fogDensity {
    switch (this) {
      case WeatherState.clear:
        return 0.000;
      case WeatherState.cloudy:
        return 0.004;
      case WeatherState.rain:
        return 0.012;
      case WeatherState.heavyRain:
        return 0.024;
      case WeatherState.fog:
        return 0.040;
    }
  }

  /// Dimming factor applied to direct sunlight (1.0 = full sun, 0.2 = overcast)
  double get sunlightDimFactor {
    switch (this) {
      case WeatherState.clear:
        return 1.00;
      case WeatherState.cloudy:
        return 0.75;
      case WeatherState.rain:
        return 0.50;
      case WeatherState.heavyRain:
        return 0.25;
      case WeatherState.fog:
        return 0.40;
    }
  }

  /// Ground/road wetness factor (0.0 = bone dry, 1.0 = flooded reflections)
  double get roadWetness {
    switch (this) {
      case WeatherState.clear:
        return 0.0;
      case WeatherState.cloudy:
        return 0.1;
      case WeatherState.rain:
        return 0.7;
      case WeatherState.heavyRain:
        return 1.0;
      case WeatherState.fog:
        return 0.35;
    }
  }

  bool get isRaining => this == WeatherState.rain || this == WeatherState.heavyRain;

  /// Associated environmental ambient sound
  AudioEvent get ambientSound {
    switch (this) {
      case WeatherState.clear:
      case WeatherState.cloudy:
        return AudioEvent.ambientForestWind;
      case WeatherState.rain:
      case WeatherState.heavyRain:
        return AudioEvent.ambientVillageRain;
      case WeatherState.fog:
        return AudioEvent.ambientPortWaves;
    }
  }
}
