import 'package:flutter/material.dart';
import '../../game/cinematics/cinematic_manager.dart';

/// Cinematic overlay rendering 2.35:1 letterbox bars, timed dialogue subtitles,
/// and cutscene skip controls.
class CinematicOverlay extends StatelessWidget {
  final CinematicManager cinematicManager;
  final VoidCallback? onSkip;

  const CinematicOverlay({
    super.key,
    required this.cinematicManager,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cinematicManager,
      builder: (context, _) {
        final factor = cinematicManager.letterboxFactor;
        if (factor <= 0.001) return const SizedBox.shrink();

        final screenHeight = MediaQuery.of(context).size.height;
        final barHeight = (screenHeight * 0.12) * factor;

        final speaker = cinematicManager.currentSpeaker;
        final subtitle = cinematicManager.currentSubtitle;
        final sequence = cinematicManager.currentSequence;

        return Stack(
          children: [
            // Top Letterbox Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: barHeight,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                alignment: Alignment.centerLeft,
                child: sequence != null && factor > 0.8
                    ? Text(
                        sequence.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                        ),
                      )
                    : null,
              ),
            ),

            // Bottom Letterbox Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: barHeight,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                alignment: Alignment.centerRight,
                child: cinematicManager.isPlaying && cinematicManager.canSkip && factor > 0.8
                    ? TextButton.icon(
                        onPressed: onSkip ?? cinematicManager.skipSequence,
                        icon: const Icon(Icons.fast_forward, size: 14.0, color: Colors.white54),
                        label: const Text(
                          'SKIP [ESC]',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11.0,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // Subtitle Container (Floats smoothly above the bottom letterbox bar)
            if (subtitle != null && subtitle.isNotEmpty)
              Positioned(
                bottom: barHeight + 16.0,
                left: 32.0,
                right: 32.0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (speaker != null) ...[
                          Text(
                            speaker.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFD97736), // Amber/Crimson noir accent
                              fontSize: 11.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                        ],
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
