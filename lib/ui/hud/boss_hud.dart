import 'package:flutter/material.dart';
import '../../game/combat/boss_encounter.dart';

/// Cinematic Boss Health Bar Overlay displayed during syndicate boss encounters.
/// Renders animated health meter, phase indicator, and boss status banner.
class BossHudOverlay extends StatelessWidget {
  final BossEncounter encounter;

  const BossHudOverlay({
    super.key,
    required this.encounter,
  });

  @override
  Widget build(BuildContext context) {
    if (encounter.isDefeated) return const SizedBox.shrink();

    final boss = encounter.boss;
    final healthRatio = (boss.health / boss.maxHealth).clamp(0.0, 1.0);
    final isPhaseTwo = encounter.currentPhase == 2;

    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xCC0D1117), // Rich dark slate
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPhaseTwo
                  ? const Color(0xFFFF3344)
                  : const Color(0xFFD4AF37), // Crimson in phase 2, Gold in phase 1
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPhaseTwo
                    ? const Color(0x66FF1A1A)
                    : const Color(0x44D4AF37),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Boss Header with Title and Phase Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPhaseTwo ? Icons.warning_amber_rounded : Icons.shield_outlined,
                        color: isPhaseTwo ? const Color(0xFFFF3344) : const Color(0xFFD4AF37),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        encounter.title,
                        style: TextStyle(
                          color: isPhaseTwo ? const Color(0xFFFF4455) : const Color(0xFFE6EDF3),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPhaseTwo
                          ? const Color(0x44FF0000)
                          : const Color(0x33D4AF37),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isPhaseTwo
                            ? const Color(0xFFFF3344)
                            : const Color(0xFFD4AF37),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isPhaseTwo ? 'PHASE 2 - ENRAGED' : 'PHASE 1',
                      style: TextStyle(
                        color: isPhaseTwo
                            ? const Color(0xFFFF4455)
                            : const Color(0xFFD4AF37),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // Subtitle
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  encounter.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Boss Health Bar with Phase 2 threshold marker at 50%
              Stack(
                children: [
                  // Background trough
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Filled health bar
                  FractionallySizedBox(
                    widthFactor: healthRatio,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPhaseTwo
                              ? [const Color(0xFF880011), const Color(0xFFFF2233)]
                              : [const Color(0xFF992222), const Color(0xFFD4AF37)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  // Phase threshold notch at 50%
                  Positioned(
                    left: 220 - 16, // Near midpoint
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Numerical HP & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    boss.isBlocking ? 'BLOCKING DEFENSE' : (boss.isKnockedDown ? 'KNOCKED DOWN' : 'HOSTILE'),
                    style: TextStyle(
                      color: boss.isBlocking
                          ? const Color(0xFF58A6FF)
                          : (boss.isKnockedDown ? const Color(0xFFE3B341) : const Color(0xFF8B949E)),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${boss.health.toInt()} / ${boss.maxHealth.toInt()} HP',
                    style: const TextStyle(
                      color: Color(0xFFC9D1D9),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
