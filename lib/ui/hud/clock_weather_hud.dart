import 'package:flutter/material.dart';
import '../../game/time/game_time_manager.dart';
import '../../game/time/time_of_day_period.dart';
import '../../game/weather/weather_manager.dart';
import '../../game/weather/weather_state.dart';

/// Minimal noir HUD widget displaying real-time in-game clock,
/// diurnal period badge (DAWN / NOON / DUSK / NITE), and dynamic weather indicator.
class ClockWeatherHud extends StatelessWidget {
  final GameTimeManager timeManager;
  final WeatherManager weatherManager;
  final VoidCallback? onTap;

  const ClockWeatherHud({
    super.key,
    required this.timeManager,
    required this.weatherManager,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([timeManager, weatherManager]),
      builder: (context, _) {
        final period = timeManager.currentPeriod;
        final weather = weatherManager.currentWeather;

        Color periodColor;
        switch (period) {
          case TimePeriod.sunrise:
            periodColor = const Color(0xFFFFB74D); // Amber
            break;
          case TimePeriod.morning:
            periodColor = const Color(0xFF64B5F6); // Sky blue
            break;
          case TimePeriod.afternoon:
            periodColor = const Color(0xFFFFD54F); // Bright gold
            break;
          case TimePeriod.sunset:
            periodColor = const Color(0xFFE57373); // Crimson dusk
            break;
          case TimePeriod.night:
            periodColor = const Color(0xFF90A4AE); // Blue grey
            break;
        }

        IconData weatherIcon;
        Color weatherColor = const Color(0xFFB0BEC5);
        switch (weather) {
          case WeatherState.clear:
            weatherIcon = period.isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined;
            weatherColor = period.isNight ? const Color(0xFF90CAF9) : const Color(0xFFFFCA28);
            break;
          case WeatherState.cloudy:
            weatherIcon = Icons.cloud_outlined;
            weatherColor = const Color(0xFFB0BEC5);
            break;
          case WeatherState.rain:
            weatherIcon = Icons.grain;
            weatherColor = const Color(0xFF4FC3F7);
            break;
          case WeatherState.heavyRain:
            weatherIcon = Icons.thunderstorm_outlined;
            weatherColor = const Color(0xFF29B6F6);
            break;
          case WeatherState.fog:
            weatherIcon = Icons.blur_on;
            weatherColor = const Color(0xFFCFD8DC);
            break;
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFF14181E).withAlpha(220),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: const Color(0xFF2C3540)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clock Time
                Text(
                  timeManager.formattedClock,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8.0),

                // Period Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: periodColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(color: periodColor.withAlpha(140), width: 0.8),
                  ),
                  child: Text(
                    period.shortCode,
                    style: TextStyle(
                      color: periodColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Weather Icon & Short Code
                Icon(weatherIcon, size: 12.0, color: weatherColor),
                const SizedBox(width: 3.0),
                Text(
                  weather.shortCode,
                  style: TextStyle(
                    color: weatherColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
