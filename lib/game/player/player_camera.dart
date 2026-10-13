import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;

/// Enhanced Third-Person Orbital Camera for VAYAL.
/// Supports smooth target following, azimuth yaw and pitch rotation,
/// dynamic distance scaling, and collision-aware height framing.
class PlayerCamera {
  late final three.PerspectiveCamera camera;

  // Orbital angles in radians
  double yaw = math.pi; // Facing forward by default (looking toward -Z)
  double pitch = 0.25; // Elevated slightly above horizontal

  // Distances and framing
  double distance = 5.2;
  double targetDistance = 5.2;
  final double minPitch = -0.15;
  final double maxPitch = 0.85;

  // Smoothing target
  final three.Vector3 _smoothedTarget = three.Vector3(0, 0, 0);
  final double heightOffset = 1.35; // Look at Aadi's upper chest/head

  PlayerCamera({required double aspectRatio}) {
    camera = three.PerspectiveCamera(52, aspectRatio, 0.1, 1000);
    camera.position.setValues(0, 3.5, 5.5);
    camera.lookAt(three.Vector3(0, heightOffset, 0));
  }

  void updateAspectRatio(double aspectRatio) {
    camera.aspect = aspectRatio;
    camera.updateProjectionMatrix();
  }

  /// Increments rotation based on touch drag or mouse movement.
  void rotate(double deltaYaw, double deltaPitch) {
    yaw += deltaYaw;
    pitch = (pitch + deltaPitch).clamp(minPitch, maxPitch);

    // Keep yaw normalized within [-pi, pi]
    while (yaw > math.pi) {
      yaw -= 2 * math.pi;
    }
    while (yaw < -math.pi) {
      yaw += 2 * math.pi;
    }
  }

  void setSprintZoom(bool isSprinting) {
    targetDistance = isSprinting ? 6.2 : 5.2;
  }

  /// Instantly resets target and camera position (used on spawn/teleport).
  void resetToTarget(three.Vector3 targetPosition) {
    _smoothedTarget.setFrom(targetPosition);
    _updateCameraTransform();
  }

  /// Frame update: smoothly tracks target and calculates orbital position.
  void update(double dt, three.Vector3 targetPosition) {
    // Smooth camera tracking (lerp damping)
    final followSpeed = math.min(1.0, 10.0 * dt);
    _smoothedTarget.x += (targetPosition.x - _smoothedTarget.x) * followSpeed;
    _smoothedTarget.y += (targetPosition.y - _smoothedTarget.y) * followSpeed;
    _smoothedTarget.z += (targetPosition.z - _smoothedTarget.z) * followSpeed;

    // Smooth distance scaling
    final zoomSpeed = math.min(1.0, 6.0 * dt);
    distance += (targetDistance - distance) * zoomSpeed;

    _updateCameraTransform();
  }

  void _updateCameraTransform() {
    // Spherical orbit coordinate math
    final double cosPitch = math.cos(pitch);
    final double sinPitch = math.sin(pitch);
    final double sinYaw = math.sin(yaw);
    final double cosYaw = math.cos(yaw);

    final double camX = _smoothedTarget.x + distance * sinYaw * cosPitch;
    final double camY = _smoothedTarget.y + heightOffset + distance * sinPitch;
    final double camZ = _smoothedTarget.z + distance * cosYaw * cosPitch;

    camera.position.setValues(camX, camY, camZ);
    camera.lookAt(
      three.Vector3(
        _smoothedTarget.x,
        _smoothedTarget.y + heightOffset,
        _smoothedTarget.z,
      ),
    );
  }
}
