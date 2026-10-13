import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/combat_system.dart';
import '../combat/damage_system.dart';
import '../systems/wanted_system.dart';
import '../characters/humanoid_builder.dart';

/// Dynamic behavioral state of an active Police Officer.
enum PoliceState {
  patrol, // Walking beat or standing watch peacefully
  respondToIncident, // Running to location of reported crime or gunshot
  chase, // Actively pursuing player with line of sight
  search, // Searching last known location after losing sight
  returnToPatrol, // Returning to post after search cooldown
  arresting, // Cornering and arresting player at low wanted level
}

/// Kerala Police Officer rank.
enum PoliceRank {
  constable,
  subInspector,
  inspector,
}

/// 3D Police Officer AI agent equipped with field-of-view detection,
/// crime incident response, tactical foot pursuits, search routines,
/// and wanted-level dependent combat escalation.
class PoliceOfficerAI extends CombatTarget {
  final String badgeNumber;
  final PoliceRank rank;
  final three.Vector3 homePosition;
  final double homeRotationY;
  final List<three.Vector3> patrolWaypoints;
  int currentWaypointIndex = 0;

  PoliceState state = PoliceState.patrol;
  double stateTimer = 0.0;
  double searchTimer = 0.0;
  final double maxSearchDuration = 14.0;
  double attackCooldownTimer = 0.0;

  // Spatial awareness
  double rotationY = 0.0;
  double currentSpeed = 0.0;
  final double walkSpeed = 1.9;
  final double runSpeed = 4.2;
  final double sprintSpeed = 5.2;

  final double detectionRange = 22.0;
  final double visionConeAngle = 1.3; // ~75 degrees FOV
  final double arrestRange = 2.4;
  double arrestHoldTimer = 0.0;

  three.Vector3? lastKnownPlayerPosition;
  three.Vector3? incidentLocation;
  String? currentShout;
  double shoutTimer = 0.0;

  // 3D Procedural Mesh
  late final three.Group group;
  late final three.Mesh torsoMesh;
  late final three.Mesh headMesh;
  late final three.Mesh capMesh;
  late final three.Mesh leftArm;
  late final three.Mesh rightArm;
  late final three.Mesh leftLeg;
  late final three.Mesh rightLeg;
  late final three.Mesh batonMesh;
  double _animTime = 0.0;

  // Callbacks
  void Function(PoliceOfficerAI officer, String shout)? onPoliceShout;
  void Function(PoliceOfficerAI officer)? onPlayerArrested;

  PoliceOfficerAI({
    required super.id,
    required super.name,
    required super.position,
    required this.badgeNumber,
    this.rank = PoliceRank.constable,
    this.patrolWaypoints = const [],
    this.homeRotationY = 0.0,
    super.health = 130.0,
    super.maxHealth = 130.0,
  }) : homePosition = position.clone() {
    rotationY = homeRotationY;
    _createMesh();
  }

  void _createMesh() {
    group = three.Group();

    // Kerala Police Khaki Palette
    const int darkKhakiHex = 0x6e5a3c;

    // Detailed uniformed humanoid: khaki tunic, leather belt, peaked cap
    // (red for sub-inspectors per Kerala Police convention)
    final rig = buildHumanoid(
      group,
      HumanoidPalette(
        torsoHex: 0xc8b28a, // Khaki uniform shirt/tunic
        pantsHex: darkKhakiHex,
        sleeveHex: 0xc8b28a,
        skinHex: 0x8a5530,
        hairHex: 0x161009,
        accentHex: 0x4a3c26,
        hairStyle: rank == PoliceRank.subInspector
            ? HumanoidHairStyle.bearded
            : HumanoidHairStyle.short,
        capHex: rank == PoliceRank.subInspector ? 0xa31c1c : 0x6e5a3c,
      ),
      torsoY: 1.25,
      headY: 1.76,
      shoulderY: 1.48,
      hipY: 0.8,
      shoulderHalfWidth: 0.29,
      hipHalfWidth: 0.165,
      bulk: 1.05,
    );

    torsoMesh = rig.bodyMesh;
    headMesh = rig.headMesh;
    leftArm = rig.leftArm;
    rightArm = rig.rightArm;
    leftLeg = rig.leftLeg;
    rightLeg = rig.rightLeg;

    // Lathi Baton gripped in the right hand
    final batonMat = three.MeshStandardMaterial();
    batonMat.color = three.Color.fromHex32(darkKhakiHex);
    batonMat.roughness = 0.5;
    batonMesh = three.Mesh(three.CylinderGeometry(0.025, 0.025, 0.8, 8), batonMat);
    batonMesh.position.setValues(0.02, -0.58, 0.12);
    batonMesh.rotation.x = 0.3;
    rightArm.add(batonMesh);

    // Legacy cap mesh reference points at the builder's crown (kept for parity)
    capMesh = torsoMesh;

    _syncTransform();
  }

  void _syncTransform() {
    group.position.setFrom(position);
    group.rotation.y = rotationY;
  }

  /// Evaluates line-of-sight and vision cone toward a given target point.
  bool canSeeTarget(three.Vector3 targetPos) {
    final dx = targetPos.x - position.x;
    final dz = targetPos.z - position.z;
    final dist = math.sqrt(dx * dx + dz * dz);
    if (dist > detectionRange) return false;

    // Angle relative to officer's facing orientation
    final angleToTarget = math.atan2(dx, dz);
    double diff = angleToTarget - rotationY;
    while (diff < -math.pi) {
      diff += 2 * math.pi;
    }
    while (diff > math.pi) {
      diff -= 2 * math.pi;
    }

    return diff.abs() <= (visionConeAngle / 2.0);
  }

  /// Alerts the officer to an incident/crime reported in their vicinity.
  void notifyIncident(three.Vector3 location, CrimeType crime) {
    if (isDead) return;
    incidentLocation = location.clone();
    state = PoliceState.respondToIncident;
    stateTimer = 0.0;
    _setShout('Control, 10-4, proceeding to incident scene!');
  }

  /// Sets shout dialogue banner.
  void _setShout(String message) {
    currentShout = message;
    shoutTimer = 3.5;
    onPoliceShout?.call(this, message);
  }

  /// Main AI tick updated each frame.
  void updateAI({
    required double dt,
    required three.Vector3 playerPos,
    required WantedSystem wantedSystem,
    required CombatSystem combatSystem,
  }) {
    if (isDead) {
      state = PoliceState.patrol;
      return;
    }

    stateTimer += dt;
    attackCooldownTimer = math.max(0.0, attackCooldownTimer - dt);
    if (shoutTimer > 0) {
      shoutTimer -= dt;
      if (shoutTimer <= 0) currentShout = null;
    }

    final hasLos = canSeeTarget(playerPos);
    final distToPlayer = math.sqrt(
      (playerPos.x - position.x) * (playerPos.x - position.x) +
      (playerPos.z - position.z) * (playerPos.z - position.z),
    );

    // State Machine
    switch (state) {
      case PoliceState.patrol:
        _handlePatrolState(dt, playerPos, hasLos, wantedSystem);
        break;

      case PoliceState.respondToIncident:
        _handleIncidentResponseState(dt, playerPos, hasLos, wantedSystem);
        break;

      case PoliceState.chase:
        _handleChaseState(dt, playerPos, distToPlayer, hasLos, wantedSystem, combatSystem);
        break;

      case PoliceState.search:
        _handleSearchState(dt, playerPos, hasLos, wantedSystem);
        break;

      case PoliceState.returnToPatrol:
        _handleReturnToPatrolState(dt, playerPos, hasLos, wantedSystem);
        break;

      case PoliceState.arresting:
        _handleArrestingState(dt, playerPos, distToPlayer, wantedSystem);
        break;
    }

    _updateProceduralAnimations(dt);
    _syncTransform();
  }

  void _handlePatrolState(
    double dt,
    three.Vector3 playerPos,
    bool hasLos,
    WantedSystem wantedSystem,
  ) {
    // If wanted level is active and officer spots player -> enter chase
    if (wantedSystem.wantedLevel > 0 && hasLos) {
      state = PoliceState.chase;
      lastKnownPlayerPosition = playerPos.clone();
      _setShout(wantedSystem.wantedLevel == 1
          ? 'Halt! Stop right there!'
          : 'Suspect spotted! All units move in!');
      return;
    }

    // Normal patrol route
    if (patrolWaypoints.isNotEmpty) {
      final targetWp = patrolWaypoints[currentWaypointIndex];
      final dx = targetWp.x - position.x;
      final dz = targetWp.z - position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist < 1.0) {
        currentWaypointIndex = (currentWaypointIndex + 1) % patrolWaypoints.length;
      } else {
        _navigateTowards(targetWp, walkSpeed, dt);
      }
    } else {
      // Idle at home post
      currentSpeed = 0.0;
    }
  }

  void _handleIncidentResponseState(
    double dt,
    three.Vector3 playerPos,
    bool hasLos,
    WantedSystem wantedSystem,
  ) {
    if (hasLos && wantedSystem.wantedLevel > 0) {
      state = PoliceState.chase;
      lastKnownPlayerPosition = playerPos.clone();
      _setShout('Suspect acquired at incident perimeter!');
      return;
    }

    if (incidentLocation != null) {
      final dx = incidentLocation!.x - position.x;
      final dz = incidentLocation!.z - position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist < 3.0) {
        // Arrived at incident scene: begin search
        incidentLocation = null;
        state = PoliceState.search;
        searchTimer = maxSearchDuration;
        _setShout('At location. Searching area for suspects.');
      } else {
        _navigateTowards(incidentLocation!, runSpeed, dt);
      }
    } else {
      state = PoliceState.patrol;
    }
  }

  void _handleChaseState(
    double dt,
    three.Vector3 playerPos,
    double distToPlayer,
    bool hasLos,
    WantedSystem wantedSystem,
    CombatSystem combatSystem,
  ) {
    // If wanted level cleared, return to patrol
    if (wantedSystem.wantedLevel == 0) {
      state = PoliceState.returnToPatrol;
      _setShout('Stand down. Suspect cleared.');
      return;
    }

    if (hasLos) {
      lastKnownPlayerPosition = playerPos.clone();
    } else {
      // Lost visual line of sight: transition to search mode
      state = PoliceState.search;
      searchTimer = maxSearchDuration;
      _setShout('Lost visual! Searching last known coordinates!');
      return;
    }

    final speedToUse = wantedSystem.wantedLevel >= 3 ? sprintSpeed : runSpeed;

    // 1 Star: Attempt arrest approach if close and player not attacking
    if (wantedSystem.wantedLevel == 1 && distToPlayer <= arrestRange) {
      state = PoliceState.arresting;
      arrestHoldTimer = 0.0;
      _setShout('Hands behind your back! Do not resist!');
      return;
    }

    // Navigate aggressively towards player
    _navigateTowards(playerPos, speedToUse, dt);

    // Combat engagements depending on wanted level
    if (distToPlayer <= 2.2 && attackCooldownTimer <= 0) {
      // Melee Lathi strike
      attackCooldownTimer = 1.4;
      combatSystem.damagePlayer(DamageInfo(
        amount: 14.0 + (wantedSystem.wantedLevel * 3.0),
        type: DamageType.blunt,
        attackerId: id,
        canKnockdown: wantedSystem.wantedLevel >= 2,
      ));
      _setShout('Down on the ground!');
    } else if (wantedSystem.wantedLevel >= 3 && distToPlayer > 5.0 && distToPlayer < 24.0 && attackCooldownTimer <= 0) {
      // Ranged sidearm fire at high wanted stars
      attackCooldownTimer = 2.0;
      combatSystem.damagePlayer(DamageInfo(
        amount: 22.0 + (wantedSystem.wantedLevel * 4.0),
        type: DamageType.gunshot,
        attackerId: id,
      ));
      _setShout('Armed hostile! Returning fire!');
    }
  }

  void _handleSearchState(
    double dt,
    three.Vector3 playerPos,
    bool hasLos,
    WantedSystem wantedSystem,
  ) {
    if (hasLos && wantedSystem.wantedLevel > 0) {
      state = PoliceState.chase;
      lastKnownPlayerPosition = playerPos.clone();
      _setShout('Suspect re-acquired!');
      return;
    }

    searchTimer -= dt;
    if (searchTimer <= 0 || wantedSystem.wantedLevel == 0) {
      state = PoliceState.returnToPatrol;
      _setShout('Area clear. Returning to sector post.');
      return;
    }

    // Wander around last known position in search circles
    if (lastKnownPlayerPosition != null) {
      final dx = lastKnownPlayerPosition!.x - position.x;
      final dz = lastKnownPlayerPosition!.z - position.z;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist < 2.0) {
        // Rotate in place searching
        rotationY += 1.5 * dt;
        currentSpeed = 0.0;
      } else {
        _navigateTowards(lastKnownPlayerPosition!, walkSpeed, dt);
      }
    }
  }

  void _handleReturnToPatrolState(
    double dt,
    three.Vector3 playerPos,
    bool hasLos,
    WantedSystem wantedSystem,
  ) {
    if (hasLos && wantedSystem.wantedLevel > 0) {
      state = PoliceState.chase;
      lastKnownPlayerPosition = playerPos.clone();
      _setShout('Suspect spotted again!');
      return;
    }

    final dx = homePosition.x - position.x;
    final dz = homePosition.z - position.z;
    final dist = math.sqrt(dx * dx + dz * dz);

    if (dist < 1.2) {
      state = PoliceState.patrol;
      rotationY = homeRotationY;
      currentSpeed = 0.0;
    } else {
      _navigateTowards(homePosition, walkSpeed, dt);
    }
  }

  void _handleArrestingState(
    double dt,
    three.Vector3 playerPos,
    double distToPlayer,
    WantedSystem wantedSystem,
  ) {
    if (distToPlayer > arrestRange + 1.0) {
      // Player fled arrest range: resume chase!
      state = PoliceState.chase;
      wantedSystem.reportCrime(CrimeType.assaultOfficer, customDescription: 'Fled active police arrest!');
      _setShout('Suspect is running! Pursuing!');
      return;
    }

    arrestHoldTimer += dt;
    currentSpeed = 0.0;

    if (arrestHoldTimer >= 3.0) {
      // Completed arrest
      wantedSystem.clearWantedLevel();
      state = PoliceState.returnToPatrol;
      _setShout('Suspect apprehended.');
      onPlayerArrested?.call(this);
    }
  }

  void _navigateTowards(three.Vector3 targetPos, double speed, double dt) {
    final dx = targetPos.x - position.x;
    final dz = targetPos.z - position.z;
    final dist = math.sqrt(dx * dx + dz * dz);

    if (dist > 0.1) {
      final desiredAngle = math.atan2(dx, dz);
      double angleDiff = desiredAngle - rotationY;
      while (angleDiff < -math.pi) {
        angleDiff += 2 * math.pi;
      }
      while (angleDiff > math.pi) {
        angleDiff -= 2 * math.pi;
      }

      rotationY += angleDiff * math.min(1.0, 5.0 * dt);
      currentSpeed = speed;

      final forwardX = math.sin(rotationY);
      final forwardZ = math.cos(rotationY);
      position.x += forwardX * speed * dt;
      position.z += forwardZ * speed * dt;
    } else {
      currentSpeed = 0.0;
    }
  }

  void _updateProceduralAnimations(double dt) {
    if (currentSpeed > 0.1) {
      _animTime += dt * (currentSpeed * 2.8);
      final swing = math.sin(_animTime) * 0.45;
      leftArm.rotation.x = -swing;
      rightArm.rotation.x = swing;
      leftLeg.rotation.x = swing;
      rightLeg.rotation.x = -swing;
    } else {
      leftArm.rotation.x = 0;
      rightArm.rotation.x = 0;
      leftLeg.rotation.x = 0;
      rightLeg.rotation.x = 0;
    }
  }
}

/// Central Police Dispatcher and Officer Management System for Veyrapuram.
class PoliceManager {
  final List<PoliceOfficerAI> officers = [];

  // Active shout for HUD broadcasting
  String? activeShoutNotification;
  double _shoutNotificationTimer = 0.0;

  PoliceManager() {
    _seedDefaultOfficers();
  }

  void _seedDefaultOfficers() {
    // 1. Officer Raghav (Sub-Inspector) stationed at central junction
    officers.add(
      PoliceOfficerAI(
        id: 'officer_raghav',
        name: 'Officer Raghav',
        badgeNumber: 'KL-07-4412',
        rank: PoliceRank.subInspector,
        position: three.Vector3(6.5, 0.0, 4.0),
        patrolWaypoints: [
          three.Vector3(6.5, 0.0, 4.0),
          three.Vector3(12.0, 0.0, 4.0),
          three.Vector3(12.0, 0.0, 12.0),
          three.Vector3(6.5, 0.0, 12.0),
        ],
      ),
    );

    // 2. Constable Biju on West Highway checkpoint
    officers.add(
      PoliceOfficerAI(
        id: 'officer_biju',
        name: 'Constable Biju',
        badgeNumber: 'KL-07-5509',
        rank: PoliceRank.constable,
        position: three.Vector3(-14.0, 0.0, 10.0),
        patrolWaypoints: [
          three.Vector3(-14.0, 0.0, 10.0),
          three.Vector3(-14.0, 0.0, 22.0),
        ],
      ),
    );

    // 3. Constable Shaji near Harbour access
    officers.add(
      PoliceOfficerAI(
        id: 'officer_shaji',
        name: 'Constable Shaji',
        badgeNumber: 'KL-07-6621',
        rank: PoliceRank.constable,
        position: three.Vector3(0.0, 0.0, 32.0),
        patrolWaypoints: [
          three.Vector3(0.0, 0.0, 32.0),
          three.Vector3(8.0, 0.0, 32.0),
        ],
      ),
    );

    for (final officer in officers) {
      officer.onPoliceShout = (off, shout) {
        activeShoutNotification = '${off.name}: "$shout"';
        _shoutNotificationTimer = 3.5;
      };
    }
  }

  /// Binds to WantedSystem crime reports to broadcast to officers.
  void hookWantedSystem(WantedSystem wantedSystem) {
    wantedSystem.onCrimeReported = (crime, description) {
      for (final officer in officers) {
        if (!officer.isDead) {
          officer.notifyIncident(officer.position, crime);
        }
      }
    };
  }

  /// Updates all officers and collects their 3D positions for the WantedSystem.
  void update({
    required double dt,
    required three.Vector3 playerPos,
    required WantedSystem wantedSystem,
    required CombatSystem combatSystem,
    required three.Scene scene,
  }) {
    if (_shoutNotificationTimer > 0) {
      _shoutNotificationTimer -= dt;
      if (_shoutNotificationTimer <= 0) activeShoutNotification = null;
    }

    final officerPositions = <three.Vector3>[];

    for (final officer in officers) {
      if (!officer.isDead) {
        officer.updateAI(
          dt: dt,
          playerPos: playerPos,
          wantedSystem: wantedSystem,
          combatSystem: combatSystem,
        );
        officerPositions.add(officer.position);
      }
    }

    // Update WantedSystem line of sight checks against all officer positions
    wantedSystem.update(
      dt: dt,
      playerPosition: playerPos,
      policePositions: officerPositions,
    );
  }
}
