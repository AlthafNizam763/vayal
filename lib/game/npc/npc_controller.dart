import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'npc.dart';

/// Manages AI behaviors, waypoint patrols, player awareness,
/// and lifecycle for all active NPCs in Veyrapuram.
class NpcController {
  final List<NPC> npcs = [];
  final Map<String, List<three.Vector3>> _patrolWaypoints = {};
  final Map<String, int> _currentWaypointIndex = {};

  void initializeWorldNpcs() {
    npcs.clear();
    _patrolWaypoints.clear();
    _currentWaypointIndex.clear();

    // 1. Meera (Aadi's Mother) - Outside house on veranda
    final meera = NPC(
      id: 'meera',
      name: 'Meera (Mother)',
      type: NpcType.familyMember,
      initialPosition: three.Vector3(-15.0, 0.0, -8.5),
      initialRotation: 0.0, // Facing south toward gate
    );
    npcs.add(meera);

    // 2. Diya (Aadi's Sister) - Near garden gate
    final diya = NPC(
      id: 'diya',
      name: 'Diya (Sister)',
      type: NpcType.familyMember,
      initialPosition: three.Vector3(-12.0, 0.0, -6.0),
      initialRotation: 0.3,
    );
    npcs.add(diya);

    // 3. Balan (Shopkeeper) - At the tea stall counter
    final balan = NPC(
      id: 'balan',
      name: 'Balan (Tea Stall)',
      type: NpcType.shopkeeper,
      initialPosition: three.Vector3(12.0, 0.0, 7.5),
      initialRotation: -math.pi / 2, // Facing west toward the street
    );
    npcs.add(balan);

    // 4. Raghav (Civilian) - Patrolling East Sidewalk
    final raghav = NPC(
      id: 'raghav',
      name: 'Raghav (Civilian)',
      type: NpcType.civilian,
      initialPosition: three.Vector3(4.2, 0.0, -14.0),
      initialRotation: math.pi,
    );
    npcs.add(raghav);
    _patrolWaypoints['raghav'] = [
      three.Vector3(4.2, 0.0, -14.0),
      three.Vector3(4.2, 0.0, 16.0),
    ];
    _currentWaypointIndex['raghav'] = 1;

    // 5. Hooded Contact / Informant - In town park
    final informant = NPC(
      id: 'informant',
      name: 'Hooded Contact',
      type: NpcType.criminal,
      initialPosition: three.Vector3(-14.0, 0.0, 7.5),
      initialRotation: math.pi / 4,
    );
    npcs.add(informant);

    // 6. Rahu (Former Partner) - On Coastal Highway Corridor (Act IV)
    final rahu = NPC(
      id: 'rahu',
      name: 'Rahu (Old Partner)',
      type: NpcType.friend,
      initialPosition: three.Vector3(0.0, 0.5, -136.0),
      initialRotation: 0.0,
    );
    npcs.add(rahu);

    // 7. Devraj (Crime Lord) - At Port Veyrapuram Berth 4 (Act V)
    final devraj = NPC(
      id: 'devraj',
      name: 'Devraj (Syndicate Boss)',
      type: NpcType.criminal,
      initialPosition: three.Vector3(0.0, 1.5, -212.0),
      initialRotation: 0.0,
    );
    npcs.add(devraj);
  }

  /// Updates NPC animations, awareness, and waypoint patrolling.
  void update(double dt, three.Vector3 playerPosition) {
    for (final npc in npcs) {
      final dx = playerPosition.x - npc.position.x;
      final dz = playerPosition.z - npc.position.z;
      final distToPlayer = math.sqrt(dx * dx + dz * dz);

      // Player Proximity Reaction
      final bool isPlayerNear = distToPlayer <= 3.8;

      if (isPlayerNear) {
        // Look at player and engage in conversation focus
        npc.lookAtPosition(playerPosition);
        npc.updateRotation(dt);
        npc.updateAnimation(dt, 0.0); // Idle breathing facing player
        npc.state = distToPlayer <= npc.interactionRadius ? NpcState.talking : NpcState.idle;
      } else {
        // Regular behavioral schedule
        final waypoints = _patrolWaypoints[npc.id];
        if (waypoints != null && waypoints.isNotEmpty) {
          _updatePatrol(npc, waypoints, dt);
        } else {
          npc.updateRotation(dt);
          npc.updateAnimation(dt, 0.0);
          npc.state = NpcState.idle;
        }
      }
    }
  }

  void _updatePatrol(NPC npc, List<three.Vector3> waypoints, double dt) {
    final targetIdx = _currentWaypointIndex[npc.id] ?? 0;
    final target = waypoints[targetIdx];

    final dx = target.x - npc.position.x;
    final dz = target.z - npc.position.z;
    final dist = math.sqrt(dx * dx + dz * dz);

    if (dist < 0.4) {
      // Reached waypoint: advance to next
      final nextIdx = (targetIdx + 1) % waypoints.length;
      _currentWaypointIndex[npc.id] = nextIdx;
      npc.updateAnimation(dt, 0.0);
    } else {
      // Walk toward waypoint
      const walkSpeed = 1.6;
      final dirX = dx / dist;
      final dirZ = dz / dist;

      final newX = npc.position.x + dirX * walkSpeed * dt;
      final newZ = npc.position.z + dirZ * walkSpeed * dt;

      npc.setPosition(newX, 0.0, newZ);
      npc.targetRotationY = math.atan2(dirX, dirZ);
      npc.updateRotation(dt);
      npc.updateAnimation(dt, walkSpeed);
      npc.state = NpcState.walking;
    }
  }

  /// Locates the nearest NPC within interactive reach.
  NPC? getNpcNearby(three.Vector3 playerPosition) {
    NPC? closest;
    double minDistance = double.infinity;

    for (final npc in npcs) {
      final dx = playerPosition.x - npc.position.x;
      final dz = playerPosition.z - npc.position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist <= npc.interactionRadius && dist < minDistance) {
        minDistance = dist;
        closest = npc;
      }
    }

    return closest;
  }
}
