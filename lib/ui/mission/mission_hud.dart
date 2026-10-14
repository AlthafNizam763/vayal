import 'package:flutter/material.dart';
import '../../game/missions/mission_manager.dart';

/// Cinematic HUD overlay displaying active mission status,
/// objective trackers, intro sequence card, and mission completion banner.
class MissionHud extends StatelessWidget {
  final MissionManager manager;
  final String? completedMissionNotification;
  final bool showIntroCard;

  const MissionHud({
    super.key,
    required this.manager,
    this.completedMissionNotification,
    this.showIntroCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = manager.activeMission;
    final objective = active?.currentObjective;

    return Stack(
      children: [
        // 1. Top-left Mission & Objective Tracker Card
        if (active != null && objective != null && !showIntroCard)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 46),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F131A).withAlpha(225),
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(
                    left: BorderSide(color: Color(0xFFD97736), width: 3.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MISSION: ${active.title}',
                          style: const TextStyle(
                            color: Color(0xFFD97736),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (manager.isCheckpointSaved)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2633),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'CHECKPOINT SAVED',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      objective.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Cinematic Mission Complete Banner
        if (completedMissionNotification != null)
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0E14).withAlpha(245),
                  border: Border.all(color: const Color(0xFFD97736), width: 2.0),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(230),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MISSION COMPLETE',
                      style: TextStyle(
                        color: Color(0xFFD97736),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedMissionNotification!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C26),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: const Color(0xFF2E3B4E)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 14),
                          const SizedBox(width: 8),
                          Text(
                            '+₹${active?.reward.money ?? 500}  •  +${active?.reward.reputation ?? 15} REP  •  CHECKPOINT SAVED',
                            style: const TextStyle(
                              color: Color(0xFFBAC7D5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 3. Cinematic Opening Title Card (Intro Scene)
        if (showIntroCard)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(180),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'V E Y R A P U R A M',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 10.0,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '"Can a man escape the person he used to be?"',
                    style: TextStyle(
                      color: Color(0xFFD97736),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aadithyan "Aadi" Menon arrives home after years in the underworld.',
                    style: TextStyle(
                      color: Color(0xFF909EB0),
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
