import 'package:three_js/three_js.dart' as three;
import '../systems/interaction_system.dart';
import 'vehicle.dart';

/// Saved snapshot of a world vehicle for persistence.
class VehicleSnapshot {
  final String id;
  final double x;
  final double y;
  final double z;
  final double rotationY;
  final double health;
  final List<bool> tiresBlown;
  final bool isOwnedByPlayer;
  final bool isStolen;

  const VehicleSnapshot({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    required this.rotationY,
    required this.health,
    required this.tiresBlown,
    required this.isOwnedByPlayer,
    required this.isStolen,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'x': x,
        'y': y,
        'z': z,
        'rotationY': rotationY,
        'health': health,
        'tiresBlown': tiresBlown,
        'isOwnedByPlayer': isOwnedByPlayer,
        'isStolen': isStolen,
      };

  factory VehicleSnapshot.fromJson(Map<String, dynamic> json) => VehicleSnapshot(
        id: json['id'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
        rotationY: (json['rotationY'] as num).toDouble(),
        health: (json['health'] as num).toDouble(),
        tiresBlown: (json['tiresBlown'] as List).map((e) => e as bool).toList(),
        isOwnedByPlayer: json['isOwnedByPlayer'] as bool? ?? false,
        isStolen: json['isStolen'] as bool? ?? false,
      );
}

/// World Vehicle Manager for VAYAL.
/// Manages open-world placement of various vehicle archetypes (cars, bikes, vans, trucks, cruisers),
/// handles entry/exit interaction detection, state persistence, and distance-based LOD culling.
class VehicleWorldManager {
  final List<Vehicle> vehicles = [];
  final double cullingDistance = 55.0; // Mobile distance budgeting

  VehicleWorldManager() {
    _seedWorldVehicles();
  }

  void _seedWorldVehicles() {
    // 1. Premier Padmini Sedan (Player Starter Car) at South Arrival Road
    vehicles.add(
      Vehicle.car(
        id: 'premier_sedan',
        name: 'Premier Padmini Vintage Sedan',
        initialPosition: three.Vector3(1.8, 0.0, -8.0),
        rotationY: 0.0,
        isOwnedByPlayer: true,
      ),
    );

    // 2. Royal Enfield Bullet 350 at Balan's Tea Stall
    vehicles.add(
      Vehicle.bike(
        id: 'bike_bullet',
        name: 'Royal Enfield Bullet 350',
        initialPosition: three.Vector3(4.5, 0.0, -14.0),
        rotationY: 1.2,
        isOwnedByPlayer: false,
      ),
    );

    // 3. Maruti Omni Cargo Van in Dock Berth 4 Loading Alley
    vehicles.add(
      Vehicle.van(
        id: 'van_omni',
        name: 'Maruti Omni Cargo Van',
        initialPosition: three.Vector3(-18.0, 0.0, 24.0),
        rotationY: -0.4,
        isOwnedByPlayer: false,
      ),
    );

    // 4. Tata 1210SE Heavy Timber Lorry at Timber Depot / Highway
    vehicles.add(
      Vehicle.truck(
        id: 'truck_tata',
        name: 'Tata 1210SE Heavy Timber Lorry',
        initialPosition: three.Vector3(24.0, 0.0, -18.0),
        rotationY: 3.14,
        isOwnedByPlayer: false,
      ),
    );

    // 5. Kerala Police Interceptor Cruiser parked at Police Post
    vehicles.add(
      Vehicle.police(
        id: 'cruiser_station',
        name: 'Kerala Police Cruiser #07',
        initialPosition: three.Vector3(9.0, 0.0, 2.0),
        rotationY: 1.57,
        isOwnedByPlayer: false,
      ),
    );
  }

  /// Spawns vehicle meshes into the ThreeJS scene and registers them with the InteractionSystem.
  void initialize(three.Scene scene, InteractionSystem interactionSystem) {
    for (final v in vehicles) {
      scene.add(v.group);
      interactionSystem.register(v);
    }
  }

  /// Finds the closest vehicle available for mounting/driving within interaction radius.
  Vehicle? findNearbyVehicle(three.Vector3 playerPos, {double maxRadius = 3.8}) {
    Vehicle? closest;
    double closestDistSq = maxRadius * maxRadius;

    for (final v in vehicles) {
      if (v.isDead) continue;
      final dx = v.position.x - playerPos.x;
      final dz = v.position.z - playerPos.z;
      final distSq = dx * dx + dz * dz;

      final radius = v.interactionRadius;
      if (distSq <= radius * radius && distSq < closestDistSq) {
        closestDistSq = distSq;
        closest = v;
      }
    }

    return closest;
  }

  /// Updates distance-based visibility culling to ensure smooth 60 FPS mobile performance.
  void update(double dt, three.Vector3 playerPos) {
    final cullingDistSq = cullingDistance * cullingDistance;

    for (final v in vehicles) {
      if (v.isOccupied) {
        v.group.visible = true;
        continue;
      }

      final dx = v.position.x - playerPos.x;
      final dz = v.position.z - playerPos.z;
      final distSq = dx * dx + dz * dz;

      // Cull distant vehicles out of rendering scope
      v.group.visible = distSq <= cullingDistSq;
    }
  }

  /// Serializes all vehicle states into snapshots for offline game saving.
  List<Map<String, dynamic>> saveSnapshots() {
    return vehicles
        .map((v) => VehicleSnapshot(
              id: v.id,
              x: v.position.x,
              y: v.position.y,
              z: v.position.z,
              rotationY: v.rotationY,
              health: v.health,
              tiresBlown: List<bool>.from(v.tiresBlown),
              isOwnedByPlayer: v.isOwnedByPlayer,
              isStolen: v.isStolen,
            ).toJson())
        .toList();
  }

  /// Restores vehicle states from saved snapshots.
  void restoreSnapshots(List<Map<String, dynamic>> snapshotsJson) {
    for (final item in snapshotsJson) {
      final snap = VehicleSnapshot.fromJson(item);
      final match = vehicles.firstWhere(
        (v) => v.id == snap.id,
        orElse: () => vehicles.first,
      );

      if (match.id == snap.id) {
        match.position.setValues(snap.x, snap.y, snap.z);
        match.rotationY = snap.rotationY;
        match.health = snap.health;
        for (int i = 0; i < snap.tiresBlown.length && i < match.tiresBlown.length; i++) {
          match.tiresBlown[i] = snap.tiresBlown[i];
        }
        match.isOwnedByPlayer = snap.isOwnedByPlayer;
        match.isStolen = snap.isStolen;
        match.group.position.setFrom(match.position);
        match.group.rotation.y = match.rotationY;
      }
    }
  }
}
