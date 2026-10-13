import 'package:flutter/material.dart';
import '../../game/missions/mission.dart';
import '../../game/missions/mission_manager.dart';
import '../../game/quests/side_quest.dart';
import '../../game/quests/side_quest_manager.dart';

/// Comprehensive mission log displaying active story objectives,
/// optional character side stories, rewards, and timeline progress.
class MissionsScreen extends StatelessWidget {
  final MissionManager missionManager;
  final SideQuestManager? sideQuestManager;
  final VoidCallback onClose;
  final ValueChanged<String>? onTrackSideQuest;

  const MissionsScreen({
    super.key,
    required this.missionManager,
    this.sideQuestManager,
    required this.onClose,
    this.onTrackSideQuest,
  });

  @override
  Widget build(BuildContext context) {
    final activeMission = missionManager.activeMission;
    final allMissions = missionManager.missions.values.toList();
    final activeSideQuest = sideQuestManager?.activeQuest;
    final allSideQuests = sideQuestManager?.quests ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C0F),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: Color(0xFFD97736), size: 22.0),
                      SizedBox(width: 10.0),
                      Text(
                        'MISSION DOSSIER & INVESTIGATION JOURNAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),

            // Missions List & Detail Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  // Active Main Story Mission Card
                  if (activeMission != null) ...[
                    const Text(
                      'ACTIVE MAIN STORY OBJECTIVE',
                      style: TextStyle(
                        color: Color(0xFFD97736),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildMissionCard(activeMission, isActive: true),
                    const SizedBox(height: 24.0),
                  ],

                  // Phase 28: Optional Character Side Stories
                  if (allSideQuests.isNotEmpty) ...[
                    const Text(
                      'CHARACTER SIDE STORIES (OPTIONAL)',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...allSideQuests.map((sq) {
                      final isCurrentSide = sq.id == activeSideQuest?.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildSideQuestCard(sq, isActive: isCurrentSide),
                      );
                    }),
                    const SizedBox(height: 24.0),
                  ],

                  const Text(
                    'STORY ARCHIVES & TIMELINE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Completed and Future Missions
                  ...allMissions.where((m) => m.id != activeMission?.id).map((m) {
                    final isDone = missionManager.completedMissions.contains(m.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildMissionCard(m, isCompleted: isDone),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideQuestCard(SideQuest sq, {bool isActive = false}) {
    final isDone = sq.isCompleted;
    final borderColor = isActive
        ? const Color(0xFF38BDF8)
        : (isDone ? const Color(0xFF10B981) : Colors.white12);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF101926)
            : const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : (isActive ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded),
                color: isDone ? const Color(0xFF10B981) : (isActive ? const Color(0xFF38BDF8) : Colors.white38),
                size: 18.0,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  sq.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  sq.characterName,
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            sq.description,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
          ),
          if (sq.currentStep != null && !isDone) ...[
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14.0, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6.0),
                  Expanded(
                    child: Text(
                      'Step ${sq.currentStepIndex + 1}/${sq.steps.length}: ${sq.currentStep!.instruction}',
                      style: const TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sq.rewardDescription,
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              if (!isDone && !isActive && onTrackSideQuest != null)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFF38BDF8),
                  ),
                  onPressed: () => onTrackSideQuest!(sq.id),
                  child: const Text('TRACK STORY', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
    Mission mission, {
    bool isActive = false,
    bool isCompleted = false,
  }) {
    final borderColor = isActive
        ? const Color(0xFFD97736)
        : (isCompleted ? const Color(0xFF10B981) : Colors.white12);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF141822)
            : (isCompleted ? const Color(0xFF0F1419) : const Color(0xFF12151C)),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: isActive ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : (isActive ? Icons.play_circle_fill_rounded : Icons.radio_button_unchecked_rounded),
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isActive ? const Color(0xFFD97736) : Colors.white38),
                    size: 18.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  isCompleted ? 'RESOLVED' : (isActive ? 'IN PROGRESS' : 'PENDING'),
                  style: TextStyle(
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : (isActive ? const Color(0xFFD97736) : Colors.white54),
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            mission.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.0,
              height: 1.4,
            ),
          ),
          if (isActive && mission.currentObjective != null) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFD97736).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.0),
                border: Border.all(color: const Color(0xFFD97736).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right_rounded, color: Color(0xFFD97736), size: 18.0),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      mission.currentObjective!.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
