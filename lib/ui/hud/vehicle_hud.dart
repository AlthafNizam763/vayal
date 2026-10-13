import 'package:flutter/material.dart';
import '../../game/vehicles/vehicle.dart';
import '../../game/vehicles/vehicle_radio.dart';
import '../../game/vehicles/police_pursuit_manager.dart';

/// Comprehensive Driving HUD displaying analog/digital speedometer,
/// engine integrity, 4-wheel tire blowout status, FM radio station tuner,
/// and pursuit PIT maneuver collision alerts.
class VehicleHud extends StatelessWidget {
  final Vehicle vehicle;
  final VehicleRadio radio;
  final PolicePursuitManager pursuitManager;
  final VoidCallback? onCycleRadio;

  const VehicleHud({
    super.key,
    required this.vehicle,
    required this.radio,
    required this.pursuitManager,
    this.onCycleRadio,
  });

  @override
  Widget build(BuildContext context) {
    final speedKmH = (vehicle.speed.abs() * 3.6).toInt();
    final isReverse = vehicle.speed < -0.2;
    final gear = vehicle.speed.abs() < 0.2 ? 'P' : (isReverse ? 'R' : 'D');
    final healthRatio = (vehicle.health / vehicle.maxHealth).clamp(0.0, 1.0);

    return Stack(
      children: [
        // 1. PIT Maneuver Threat Alert Banner (Top Center)
        if (pursuitManager.isPitImminent)
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xEE8A0000),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF2233), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66FF1111), blurRadius: 12),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'PIT MANEUVER IMMINENT — COUNTER STEER!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Main Vehicle Instrument Cluster (Bottom Right)
        Positioned(
          bottom: 24,
          right: 20,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xDD0D1117), // Slate noir
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: vehicle.isEngineOnFire
                    ? const Color(0xFFFF2233)
                    : (vehicle.isEngineSmoking ? const Color(0xFFE3B341) : const Color(0xFF30363D)),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 16),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Speedometer & Gear Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$speedKmH',
                          style: TextStyle(
                            color: vehicle.hasBlownTire
                                ? const Color(0xFFE3B341)
                                : const Color(0xFFE6EDF3),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'KM/H',
                          style: TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF388BFD), width: 1.2),
                      ),
                      child: Text(
                        gear,
                        style: const TextStyle(
                          color: Color(0xFF58A6FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Health Bar & Engine Condition Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicle.isEngineOnFire
                              ? 'ENGINE FIRE!'
                              : (vehicle.isEngineSmoking ? 'ENGINE SMOKING' : 'CHASSIS'),
                          style: TextStyle(
                            color: vehicle.isEngineOnFire
                                ? const Color(0xFFFF3344)
                                : (vehicle.isEngineSmoking ? const Color(0xFFE3B341) : const Color(0xFF8B949E)),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '${vehicle.health.toInt()}%',
                          style: const TextStyle(color: Color(0xFFC9D1D9), fontSize: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: healthRatio,
                        minHeight: 5,
                        backgroundColor: const Color(0xFF21262D),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          vehicle.isEngineOnFire
                              ? const Color(0xFFFF2233)
                              : (vehicle.isEngineSmoking ? const Color(0xFFE3B341) : const Color(0xFF2EA043)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 4-Wheel Tire Diagram
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTireIndicator('FL', vehicle.tiresBlown[0]),
                    _buildTireIndicator('FR', vehicle.tiresBlown[1]),
                    _buildTireIndicator('RL', vehicle.tiresBlown[2]),
                    _buildTireIndicator('RR', vehicle.tiresBlown[3]),
                  ],
                ),
                const SizedBox(height: 8),

                // In-Car FM Radio Station Bar
                GestureDetector(
                  onTap: onCycleRadio,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF30363D), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radio, size: 12, color: Color(0xFFD4AF37)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            radio.currentStationName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          '[R]',
                          style: TextStyle(color: Color(0xFF8B949E), fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTireIndicator(String label, bool isBlown) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isBlown ? const Color(0x44FF0000) : const Color(0x332EA043),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isBlown ? const Color(0xFFFF2233) : const Color(0xFF2EA043),
            width: 1.0,
          ),
        ),
        child: Text(
          '$label ${isBlown ? "✕" : "✓"}',
          style: TextStyle(
            color: isBlown ? const Color(0xFFFF4455) : const Color(0xFF3FB950),
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
