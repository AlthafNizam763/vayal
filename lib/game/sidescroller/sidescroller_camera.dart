import 'dart:math' as math;

/// Smooth 2D Side-Scrolling Camera with boundary clamping and deadzone easing.
class SideScrollingCamera {
  double x = 0.0;
  double y = 0.0;

  double targetX = 0.0;
  double targetY = 0.0;

  double zoom = 1.0;
  double targetZoom = 1.0;

  // Level boundaries in world units
  double minWorldX = -30.0;
  double maxWorldX = 60.0;

  // Smoothing stiffness
  double followSpeed = 5.0;

  SideScrollingCamera({
    double initialX = 0.0,
    this.minWorldX = -30.0,
    this.maxWorldX = 60.0,
  }) {
    x = initialX;
    targetX = initialX;
  }

  void snapTo(double worldX, {double worldY = 0.0}) {
    x = worldX.clamp(minWorldX, maxWorldX);
    y = worldY;
    targetX = x;
    targetY = y;
  }

  void setTarget(double worldX, {double worldY = 0.0}) {
    targetX = worldX.clamp(minWorldX, maxWorldX);
    targetY = worldY;
  }

  void update(double dt) {
    final t = 1.0 - math.exp(-followSpeed * dt);
    x += (targetX - x) * t;
    y += (targetY - y) * t;
    zoom += (targetZoom - zoom) * t;
  }
}
