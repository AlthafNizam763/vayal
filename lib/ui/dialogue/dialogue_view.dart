import 'package:flutter/material.dart';
import '../../game/dialogue/dialogue.dart';
import '../../game/dialogue/dialogue_manager.dart';

/// Cinematic dialogue interface displaying character dialogue lines,
/// emotion indicators, and interactive choice cards.
class DialogueView extends StatelessWidget {
  final DialogueManager manager;
  final VoidCallback onAdvance;
  final ValueChanged<DialogueChoice> onSelectChoice;

  const DialogueView({
    super.key,
    required this.manager,
    required this.onAdvance,
    required this.onSelectChoice,
  });

  @override
  Widget build(BuildContext context) {
    final node = manager.currentNode;
    if (node == null) return const SizedBox.shrink();

    final choices = manager.getAvailableChoices();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1016).withAlpha(248),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF2C3747),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(220),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Speaker Banner & Emotion Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97736),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          node.speaker.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    if (node.emotion != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A222F),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF323F52)),
                        ),
                        child: Text(
                          node.emotion!.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF9EACBF),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Main Dialogue Text
                GestureDetector(
                  onTap: choices.isEmpty ? onAdvance : null,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    '"${node.text}"',
                    style: const TextStyle(
                      color: Color(0xFFECEFF4),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Interactive Choices List OR Tap to Continue Prompt
                if (choices.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(color: Color(0xFF1E2532), height: 1),
                      const SizedBox(height: 12),
                      ...choices.asMap().entries.map((entry) {
                        final index = entry.key;
                        final choice = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => onSelectChoice(choice),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141922),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF2E394A),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97736).withAlpha(40),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: const Color(0xFFD97736)),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFFD97736),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Phase 41: Tone Badge Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: choice.tone.color.withAlpha(30),
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: choice.tone.color.withAlpha(180), width: 1.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(choice.tone.icon, color: choice.tone.color, size: 10),
                                        const SizedBox(width: 4),
                                        Text(
                                          choice.tone.displayName.toUpperCase(),
                                          style: TextStyle(
                                            color: choice.tone.color,
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          choice.text,
                                          style: TextStyle(
                                            color: choice.tone == DialogueTone.silence
                                                ? const Color(0xFF90A4AE)
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: choice.tone == DialogueTone.silence
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        if (choice.consequencePreview != null) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            choice.consequencePreview!,
                                            style: TextStyle(
                                              color: choice.tone.color.withAlpha(200),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF78879B),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onAdvance,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A23),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: const Color(0xFF2B3647)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CONTINUE',
                              style: TextStyle(
                                color: Color(0xFF8B9BB0),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, color: Color(0xFF8B9BB0), size: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
