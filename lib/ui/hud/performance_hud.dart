import 'package:flutter/material.dart';
import '../../game/performance/performance_manager.dart';

/// Lightweight, minimal real-time performance telemetry badge.
class PerformanceHud extends StatelessWidget {
  final PerformanceManager performanceManager;
  final int visibleChunks;
  final int totalChunks;
  final int activeNpcs;
  final int totalNpcs;

  const PerformanceHud({
    super.key,
    required this.performanceManager,
    required this.visibleChunks,
    required this.totalChunks,
    required this.activeNpcs,
    required this.totalNpcs,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: performanceManager,
      builder: (context, _) {
        final metrics = performanceManager.getMetrics(
          visibleChunks: visibleChunks,
          totalChunks: totalChunks,
          activeNpcs: activeNpcs,
          totalNpcs: totalNpcs,
        );

        final fps = metrics.currentFps.round();
        final ms = metrics.frameTimeMs.toStringAsFixed(1);

        Color fpsColor = const Color(0xFF10B981); // Green
        if (fps < 30) {
          fpsColor = const Color(0xFFEF4444); // Red
        } else if (fps < 50) {
          fpsColor = const Color(0xFFF59E0B); // Amber
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FPS: $fps',
                style: TextStyle(
                  color: fpsColor,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                '($ms ms) • ${metrics.preset.name.toUpperCase()} • Chunks: $visibleChunks/$totalChunks • NPCs: $activeNpcs/$totalNpcs',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 9.0,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
