import 'package:flutter/material.dart';
import '../../game/stealth/stealth_system.dart';
import '../../game/combat/enemy_ai.dart';

/// HUD Overlay displaying stealth posture badge, awareness/detection meter,
/// and contextual prompt for silent takedowns.
class StealthHudOverlay extends StatelessWidget {
  final StealthSystem stealthSystem;
  final EnemyAI? takedownCandidate;
  final VoidCallback onExecuteTakedown;
  final VoidCallback onToggleCrouch;

  const StealthHudOverlay({
    super.key,
    required this.stealthSystem,
    this.takedownCandidate,
    required this.onExecuteTakedown,
    required this.onToggleCrouch,
  });

  @override
  Widget build(BuildContext context) {
    final highestAwareness = stealthSystem.highestAwareness;
    final isDetected = highestAwareness >= 1.0;
    final isSuspicious = highestAwareness > 0.1 && !isDetected;
    final isSneaking = stealthSystem.isCrouched;
    final isConcealed = stealthSystem.isConcealed;

    return Stack(
      children: [
        // 1. Hostile Awareness / Suspicion Threat Meter (Top Center below clock)
        if (highestAwareness > 0.05)
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDetected
                      ? const Color(0xDD3A0A0E)
                      : const Color(0xCC111822),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDetected
                        ? const Color(0xFFFF2233)
                        : (isSuspicious ? const Color(0xFFE3B341) : const Color(0xFF58A6FF)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDetected
                          ? const Color(0x66FF1A1A)
                          : const Color(0x33000000),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDetected
                          ? Icons.visibility
                          : (isSuspicious ? Icons.visibility_outlined : Icons.remove_red_eye_outlined),
                      color: isDetected
                          ? const Color(0xFFFF3344)
                          : (isSuspicious ? const Color(0xFFE3B341) : const Color(0xFF8B949E)),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isDetected
                          ? 'DETECTED!'
                          : (isSuspicious ? 'HOSTILES SUSPICIOUS' : 'CAUTION'),
                      style: TextStyle(
                        color: isDetected
                            ? const Color(0xFFFF4455)
                            : (isSuspicious ? const Color(0xFFE3B341) : const Color(0xFFC9D1D9)),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Awareness progress meter
                    SizedBox(
                      width: 60,
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: highestAwareness,
                          backgroundColor: const Color(0xFF21262D),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDetected
                                ? const Color(0xFFFF2233)
                                : (isSuspicious ? const Color(0xFFE3B341) : const Color(0xFF58A6FF)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Posture / Concealment Status Badge (Bottom Left above controls)
        Positioned(
          bottom: 120,
          left: 20,
          child: GestureDetector(
            onTap: onToggleCrouch,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isConcealed
                    ? const Color(0xDD0D2818) // Forest dark green
                    : (isSneaking ? const Color(0xCC1F242C) : const Color(0x99111822)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConcealed
                      ? const Color(0xFF2EA043)
                      : (isSneaking ? const Color(0xFF58A6FF) : const Color(0x448B949E)),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConcealed
                        ? Icons.grass_rounded
                        : (isSneaking ? Icons.airline_seat_recline_normal : Icons.accessibility_new),
                    color: isConcealed
                        ? const Color(0xFF3FB950)
                        : (isSneaking ? const Color(0xFF58A6FF) : const Color(0xFF8B949E)),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConcealed
                        ? 'CONCEALED (${stealthSystem.currentHidingSpot?.name.split(" ").first ?? "SHADOW"})'
                        : (isSneaking ? 'CROUCHING [C]' : 'STAND [C]'),
                    style: TextStyle(
                      color: isConcealed
                          ? const Color(0xFF3FB950)
                          : (isSneaking ? const Color(0xFF58A6FF) : const Color(0xFF8B949E)),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Contextual Silent Takedown Prompt
        if (takedownCandidate != null)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: onExecuteTakedown,
                icon: const Icon(Icons.flash_on, color: Color(0xFFFFAA00), size: 18),
                label: Text(
                  'STEALTH TAKEDOWN: ${takedownCandidate!.name.toUpperCase()} [E]',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xEE8A1818),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFFF4444), width: 1.5),
                  ),
                  elevation: 8,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
