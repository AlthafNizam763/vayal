import 'package:three_js/three_js.dart' as three;

/// A single keyframe in a scripted cinematic camera track.
class CinematicKeyframe {
  final double time; // Timestamp in seconds within the sequence
  final three.Vector3 cameraPosition;
  final three.Vector3 targetPosition; // Point the camera looks at
  final double fov;
  final String? subtitleSpeaker;
  final String? subtitleText;

  const CinematicKeyframe({
    required this.time,
    required this.cameraPosition,
    required this.targetPosition,
    this.fov = 50.0,
    this.subtitleSpeaker,
    this.subtitleText,
  });
}

/// Evaluated camera state at a specific point in time during a cutscene.
class CinematicTransform {
  final three.Vector3 cameraPosition;
  final three.Vector3 targetPosition;
  final double fov;
  final String? speaker;
  final String? subtitle;

  const CinematicTransform({
    required this.cameraPosition,
    required this.targetPosition,
    required this.fov,
    this.speaker,
    this.subtitle,
  });
}

/// A complete cutscene sequence consisting of timed keyframes,
/// narrative subtitles, and smooth camera motion.
class CinematicSequence {
  final String id;
  final String title;
  final double duration; // Total length in seconds
  final bool canSkip;
  final List<CinematicKeyframe> keyframes;

  const CinematicSequence({
    required this.id,
    required this.title,
    required this.duration,
    this.canSkip = true,
    required this.keyframes,
  });

  /// Evaluates camera position and subtitle with smooth interpolation at given sequence time.
  CinematicTransform evaluate(double time) {
    if (keyframes.isEmpty) {
      return CinematicTransform(
        cameraPosition: three.Vector3(0, 3, 5),
        targetPosition: three.Vector3(0, 1, 0),
        fov: 50.0,
      );
    }

    final clampedTime = time.clamp(0.0, duration);

    // If before first keyframe
    if (clampedTime <= keyframes.first.time) {
      final k = keyframes.first;
      return CinematicTransform(
        cameraPosition: three.Vector3(k.cameraPosition.x, k.cameraPosition.y, k.cameraPosition.z),
        targetPosition: three.Vector3(k.targetPosition.x, k.targetPosition.y, k.targetPosition.z),
        fov: k.fov,
        speaker: k.subtitleSpeaker,
        subtitle: k.subtitleText,
      );
    }

    // If after last keyframe
    if (clampedTime >= keyframes.last.time) {
      final k = keyframes.last;
      return CinematicTransform(
        cameraPosition: three.Vector3(k.cameraPosition.x, k.cameraPosition.y, k.cameraPosition.z),
        targetPosition: three.Vector3(k.targetPosition.x, k.targetPosition.y, k.targetPosition.z),
        fov: k.fov,
        speaker: k.subtitleSpeaker,
        subtitle: k.subtitleText,
      );
    }

    // Find bounding keyframe interval [k0, k1]
    int idx = 0;
    while (idx < keyframes.length - 1 && keyframes[idx + 1].time < clampedTime) {
      idx++;
    }

    final k0 = keyframes[idx];
    final k1 = keyframes[idx + 1];

    final span = k1.time - k0.time;
    final rawFactor = span > 0.0001 ? (clampedTime - k0.time) / span : 0.0;
    // Cubic smoothstep easing (S-curve) for fluid cinematic panning
    final factor = rawFactor * rawFactor * (3.0 - 2.0 * rawFactor);

    final camPos = three.Vector3(
      k0.cameraPosition.x + (k1.cameraPosition.x - k0.cameraPosition.x) * factor,
      k0.cameraPosition.y + (k1.cameraPosition.y - k0.cameraPosition.y) * factor,
      k0.cameraPosition.z + (k1.cameraPosition.z - k0.cameraPosition.z) * factor,
    );

    final targetPos = three.Vector3(
      k0.targetPosition.x + (k1.targetPosition.x - k0.targetPosition.x) * factor,
      k0.targetPosition.y + (k1.targetPosition.y - k0.targetPosition.y) * factor,
      k0.targetPosition.z + (k1.targetPosition.z - k0.targetPosition.z) * factor,
    );

    final fov = k0.fov + (k1.fov - k0.fov) * factor;

    // Subtitle displays whichever keyframe is currently active
    final speaker = k0.subtitleSpeaker;
    final subtitle = k0.subtitleText;

    return CinematicTransform(
      cameraPosition: camPos,
      targetPosition: targetPos,
      fov: fov,
      speaker: speaker,
      subtitle: subtitle,
    );
  }
}
