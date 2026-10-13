import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as three;
import '../npc/npc.dart';
import '../time/game_time_manager.dart';
import '../time/time_of_day_period.dart';

/// Opening and closing hours schedule for commercial world interactables.
class ShopSchedule {
  final String id;
  final String name;
  final double openHour; // e.g. 6.0 for 06:00 AM
  final double closeHour; // e.g. 22.0 for 10:00 PM

  const ShopSchedule({
    required this.id,
    required this.name,
    required this.openHour,
    required this.closeHour,
  });

  bool isOpen(double currentHour) {
    if (openHour <= closeHour) {
      return currentHour >= openHour && currentHour < closeHour;
    } else {
      // Overnight schedule
      return currentHour >= openHour || currentHour < closeHour;
    }
  }

  String getScheduleText() {
    final openH = openHour.toInt();
    final closeH = closeHour.toInt();
    final openStr = openH > 12 ? '${openH - 12}:00 PM' : '$openH:00 AM';
    final closeStr = closeH > 12 ? '${closeH - 12}:00 PM' : '$closeH:00 AM';
    return '$openStr - $closeStr';
  }
}

/// Lightweight AI-driven traffic vehicle navigating predefined road corridors.
class TrafficVehicle {
  final String id;
  final String modelName;
  final three.Group group;
  final List<three.Vector3> waypoints;
  int currentWaypointIndex = 0;

  double speed = 0.0;
  final double maxSpeed = 7.5; // ~27 km/h urban speed limit
  double rotationY = 0.0;

  late final three.Mesh bodyMesh;
  late final List<three.Mesh> wheels;

  TrafficVehicle({
    required this.id,
    required this.modelName,
    required this.waypoints,
    int bodyColorHex = 0x3d5a80,
  })  : currentWaypointIndex = waypoints.length > 1 ? 1 : 0,
        group = three.Group() {
    _buildMesh(bodyColorHex);
  }

  void _buildMesh(int colorHex) {
    final bodyMat = three.MeshStandardMaterial();
    bodyMat.color = three.Color.fromHex32(colorHex);
    bodyMat.roughness = 0.6;

    final cabinMat = three.MeshStandardMaterial();
    cabinMat.color = three.Color.fromHex32(0x192231);
    cabinMat.roughness = 0.3;

    final wheelMat = three.MeshStandardMaterial();
    wheelMat.color = three.Color.fromHex32(0x1a1a1a);

    // Chassis
    bodyMesh = three.Mesh(three.BoxGeometry(1.8, 0.7, 3.8), bodyMat);
    bodyMesh.position.setValues(0, 0.55, 0);
    group.add(bodyMesh);

    // Cabin
    final cabin = three.Mesh(three.BoxGeometry(1.6, 0.65, 2.0), cabinMat);
    cabin.position.setValues(0, 1.15, -0.2);
    group.add(cabin);

    // 4 Wheels
    wheels = [];
    final wheelGeo = three.CylinderGeometry(0.32, 0.32, 0.22, 8);
    final wheelOffsets = [
      three.Vector3(-0.95, 0.32, 1.2),
      three.Vector3(0.95, 0.32, 1.2),
      three.Vector3(-0.95, 0.32, -1.2),
      three.Vector3(0.95, 0.32, -1.2),
    ];

    for (final offset in wheelOffsets) {
      final w = three.Mesh(wheelGeo, wheelMat);
      w.rotation.z = math.pi / 2;
      w.position.setFrom(offset);
      wheels.add(w);
      group.add(w);
    }

    if (waypoints.isNotEmpty) {
      group.position.setFrom(waypoints.first);
    }
  }

  void update(double dt, three.Vector3 playerPos) {
    if (waypoints.isEmpty) return;

    final target = waypoints[currentWaypointIndex];
    final dx = target.x - group.position.x;
    final dz = target.z - group.position.z;
    final dist = math.sqrt(dx * dx + dz * dz);

    // Check distance to player to avoid collision
    final toPlayerX = playerPos.x - group.position.x;
    final toPlayerZ = playerPos.z - group.position.z;
    final distToPlayer = math.sqrt(toPlayerX * toPlayerX + toPlayerZ * toPlayerZ);

    if (distToPlayer < 4.5) {
      // Brake for player
      speed = math.max(0.0, speed - 12.0 * dt);
    } else {
      // Accelerate to cruising speed
      speed = math.min(maxSpeed, speed + 6.0 * dt);
    }

    if (dist < 1.0) {
      // Advance to next waypoint or loop
      currentWaypointIndex = (currentWaypointIndex + 1) % waypoints.length;
    } else {
      final dirX = dx / dist;
      final dirZ = dz / dist;

      group.position.x += dirX * speed * dt;
      group.position.z += dirZ * speed * dt;

      // Align heading smoothly
      final targetRot = math.atan2(dirX, dirZ);
      final diff = (targetRot - rotationY) % (math.pi * 2);
      final shortest = diff > math.pi ? diff - math.pi * 2 : (diff < -math.pi ? diff + math.pi * 2 : diff);
      rotationY += shortest * math.min(1.0, 5.0 * dt);
      group.rotation.y = rotationY;

      // Spin wheels
      final spin = (speed / 0.32) * dt;
      for (final w in wheels) {
        w.rotation.x += spin;
      }
    }
  }
}

/// Central manager orchestrating ambient city pedestrians, road traffic,
/// and shop operational schedules based on time of day and narrative progression.
class WorldLifeManager extends ChangeNotifier {
  // Predefined Veyrapuram Shop Schedules
  static final Map<String, ShopSchedule> defaultSchedules = {
    'tea_stall_counter': const ShopSchedule(
      id: 'tea_stall_counter',
      name: "Balan's Chai Stall",
      openHour: 5.5, // 05:30 AM
      closeHour: 22.5, // 10:30 PM
    ),
    'general_store_counter': const ShopSchedule(
      id: 'general_store_counter',
      name: "Menon Provisions",
      openHour: 7.0, // 07:00 AM
      closeHour: 20.0, // 08:00 PM
    ),
    'garage_counter': const ShopSchedule(
      id: 'garage_counter',
      name: "Auto Workshop",
      openHour: 8.5, // 08:30 AM
      closeHour: 19.5, // 07:30 PM
    ),
  };

  final List<TrafficVehicle> trafficVehicles = [];
  final List<NPC> ambientPedestrians = [];

  bool _isInitialized = false;

  /// Initializes ambient road traffic vehicles and pedestrian wanderers.
  void initialize(three.Scene scene) {
    if (_isInitialized) return;
    _isInitialized = true;

    trafficVehicles.clear();
    ambientPedestrians.clear();

    // 1. Traffic Car A: Village Main Street Corridor (North to South Loop)
    final carA = TrafficVehicle(
      id: 'traffic_sedan_1',
      modelName: 'Maruti 800 White',
      bodyColorHex: 0xe0e1dd,
      waypoints: [
        three.Vector3(1.8, 0.0, -32.0),
        three.Vector3(1.8, 0.0, 28.0),
        three.Vector3(-1.8, 0.0, 28.0),
        three.Vector3(-1.8, 0.0, -32.0),
      ],
    );
    trafficVehicles.add(carA);
    scene.add(carA.group);

    // 2. Traffic Car B: Crossroad Corridor to Old Town Bazaar
    final carB = TrafficVehicle(
      id: 'traffic_van_1',
      modelName: 'Matador Delivery Van',
      bodyColorHex: 0x2b2d42,
      waypoints: [
        three.Vector3(0.0, 0.0, 0.0),
        three.Vector3(-55.0, 0.0, 0.0),
        three.Vector3(-55.0, 0.0, 2.5),
        three.Vector3(0.0, 0.0, 2.5),
      ],
    );
    trafficVehicles.add(carB);
    scene.add(carB.group);

    // 3. Ambient Pedestrian: Village Elder on morning/evening sidewalk walk
    final elder = NPC(
      id: 'pedestrian_elder',
      name: 'Unni (Elder)',
      type: NpcType.civilian,
      initialPosition: three.Vector3(3.8, 0.0, -6.0),
    );
    ambientPedestrians.add(elder);
    scene.add(elder.group);

    // 4. Ambient Pedestrian: Street Worker with tea stall route
    final worker = NPC(
      id: 'pedestrian_worker',
      name: 'Manoj (Daily Laborer)',
      type: NpcType.civilian,
      initialPosition: three.Vector3(9.5, 0.0, 6.0),
    );
    ambientPedestrians.add(worker);
    scene.add(worker.group);
  }

  /// Evaluates whether a given shop is currently open for business.
  bool isShopOpen(String shopId, double timeOfDay) {
    final schedule = defaultSchedules[shopId];
    if (schedule == null) return true; // Default to open if no schedule
    return schedule.isOpen(timeOfDay);
  }

  /// Returns user-friendly status text for shop interaction prompt.
  String getShopPrompt(String shopId, String basePrompt, double timeOfDay) {
    final schedule = defaultSchedules[shopId];
    if (schedule == null) return basePrompt;

    if (schedule.isOpen(timeOfDay)) {
      return basePrompt;
    } else {
      return '[CLOSED] ${schedule.name} opens at ${schedule.getScheduleText()}';
    }
  }

  /// Per-frame simulation tick updating traffic AI and ambient pedestrians.
  void update({
    required double dt,
    required GameTimeManager timeManager,
    required three.Vector3 playerPosition,
  }) {
    // 1. Modulate traffic activity by active time-of-day density
    final density = timeManager.currentPeriod.trafficDensity;
    final activeVehicleCount = (trafficVehicles.length * density).ceil().clamp(1, trafficVehicles.length);

    for (int i = 0; i < trafficVehicles.length; i++) {
      final vehicle = trafficVehicles[i];
      if (i < activeVehicleCount) {
        vehicle.group.visible = true;
        vehicle.update(dt, playerPosition);
      } else {
        vehicle.group.visible = false;
      }
    }

    // 2. Update ambient pedestrians
    for (final ped in ambientPedestrians) {
      final dx = playerPosition.x - ped.position.x;
      final dz = playerPosition.z - ped.position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist <= 3.2) {
        ped.lookAtPosition(playerPosition);
        ped.updateRotation(dt);
        ped.updateAnimation(dt, 0.0);
      } else {
        ped.updateAnimation(dt, 0.0);
      }
    }
  }
}
