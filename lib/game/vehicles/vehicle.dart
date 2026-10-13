import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import '../combat/damage_system.dart';
import '../systems/interaction_system.dart';

/// Tire locations on a 4-wheel vehicle.
enum TirePosition {
  frontLeft,
  frontRight,
  rearLeft,
  rearRight,
}

/// Category of drivable world vehicles in Veyrapuram.
enum VehicleType {
  car, // Classic Ambassador / Premier Sedan
  bike, // Royal Enfield Bullet 350 (nimble, 2 wheels, high acceleration)
  van, // Maruti Omni / Matador delivery van (boxy cargo transport)
  truck, // Tata 1210SE Heavy Timber Lorry (high durability, massive ramming power)
  policeVehicle, // Kerala Police Interceptor with roof sirens
}

/// 3D Drivable World Vehicle built modularly with ThreeJS.
/// Supports cars, bikes, vans, trucks, and police interceptors with distinct
/// physical parameters, articulated wheels, damage states, and ownership tracking.
class Vehicle implements Damageable, Interactable {
  @override
  final String id;
  @override
  final String name;
  @override
  InteractableType get type => InteractableType.vehicle;

  final VehicleType vehicleType;
  bool isOwnedByPlayer;
  bool isStolen;

  @override
  three.Vector3 get position => _position;
  final three.Vector3 _position = three.Vector3(0, 0, 0);

  @override
  double get interactionRadius => vehicleType == VehicleType.bike ? 2.6 : 3.8;

  @override
  String get prompt {
    if (isOccupied) return '[E] / [TAP] EXIT VEHICLE';
    final typeName = vehicleType == VehicleType.bike ? 'RIDE $name' : 'DRIVE $name';
    return isOwnedByPlayer ? '[E] / [TAP] $typeName' : '[E] / [TAP] STEAL $typeName';
  }

  late final three.Group group;
  late final three.Mesh bodyMesh;
  late final three.Mesh cabinMesh;
  late final three.Group frontLeftWheelGroup;
  late final three.Group frontRightWheelGroup;
  late final three.Mesh frontLeftWheelMesh;
  late final three.Mesh frontRightWheelMesh;
  late final three.Mesh rearLeftWheelMesh;
  late final three.Mesh rearRightWheelMesh;
  late final three.Mesh headlightLeft;
  late final three.Mesh headlightRight;
  late final three.Mesh taillightLeft;
  late final three.Mesh taillightRight;

  // Kinematic parameters
  double rotationY = 0.0;
  double speed = 0.0; // Current velocity along heading vector in m/s
  double steeringAngle = 0.0; // In radians

  double maxForwardSpeed;
  double maxReverseSpeed;
  double accelerationRate;
  double brakeRate;
  final double frictionRate = 4.5;
  double maxSteeringAngle;
  final double steeringReturnRate = 4.0;
  final double wheelBase = 2.6; // Distance between axles
  final double wheelRadius;

  // Collision dimensions
  double width;
  double length;

  // State
  bool isOccupied = false;
  bool headlightsOn = true;

  // Phase 34: Tire & Engine Integrity
  // Indices: 0: Front-Left, 1: Front-Right, 2: Rear-Left, 3: Rear-Right
  final List<bool> tiresBlown = [false, false, false, false];
  bool isEngineSmoking = false;
  bool isEngineOnFire = false;

  bool get hasBlownTire => tiresBlown.any((t) => t);
  int get blownTireCount => tiresBlown.where((t) => t).length;
  double get effectiveMaxForwardSpeed =>
      maxForwardSpeed * (1.0 - (blownTireCount * 0.22)).clamp(0.25, 1.0);

  void punctureTire(dynamic tire) {
    final int idx = tire is TirePosition ? tire.index : (tire as int);
    if (idx >= 0 && idx < 4) {
      tiresBlown[idx] = true;
    }
  }

  bool isTireBlown(dynamic tire) {
    final int idx = tire is TirePosition ? tire.index : (tire as int);
    if (idx >= 0 && idx < 4) return tiresBlown[idx];
    return false;
  }

  void punctureAllTires() {
    for (int i = 0; i < 4; i++) {
      tiresBlown[i] = true;
    }
  }

  void repairTires() {
    for (int i = 0; i < 4; i++) {
      tiresBlown[i] = false;
    }
  }

  @override
  double health = 100.0;
  @override
  double maxHealth = 100.0;

  @override
  bool get isDead => health <= 0;
  bool get isWrecked => health <= 0;

  @override
  bool get isBlocking => false;
  @override
  bool get isKnockedDown => false;

  void Function(DamageInfo info)? onVehicleDamaged;

  Vehicle({
    this.id = 'sedan_01',
    this.name = 'Padmini Vintage Sedan',
    this.vehicleType = VehicleType.car,
    this.isOwnedByPlayer = true,
    this.isStolen = false,
    three.Vector3? initialPosition,
    this.rotationY = 0.0,
    double? maxHealth,
    double? maxForwardSpeed,
    double? accelerationRate,
    double? brakeRate,
    double? maxSteeringAngle,
    double? width,
    double? length,
    double? wheelRadius,
  })  : maxHealth = maxHealth ?? (vehicleType == VehicleType.truck ? 220.0 : (vehicleType == VehicleType.bike ? 70.0 : 100.0)),
        maxForwardSpeed = maxForwardSpeed ?? (vehicleType == VehicleType.bike ? 25.0 : (vehicleType == VehicleType.truck ? 15.0 : 22.0)),
        maxReverseSpeed = vehicleType == VehicleType.bike ? -3.0 : (vehicleType == VehicleType.truck ? -4.5 : -6.0),
        accelerationRate = accelerationRate ?? (vehicleType == VehicleType.bike ? 18.0 : (vehicleType == VehicleType.truck ? 8.5 : 14.0)),
        brakeRate = brakeRate ?? (vehicleType == VehicleType.bike ? 26.0 : 22.0),
        maxSteeringAngle = maxSteeringAngle ?? (vehicleType == VehicleType.bike ? 0.72 : (vehicleType == VehicleType.truck ? 0.38 : 0.52)),
        width = width ?? (vehicleType == VehicleType.bike ? 0.9 : (vehicleType == VehicleType.truck ? 2.5 : (vehicleType == VehicleType.van ? 1.8 : 2.0))),
        length = length ?? (vehicleType == VehicleType.bike ? 2.3 : (vehicleType == VehicleType.truck ? 6.2 : (vehicleType == VehicleType.van ? 3.8 : 4.5))),
        wheelRadius = wheelRadius ?? (vehicleType == VehicleType.truck ? 0.52 : (vehicleType == VehicleType.bike ? 0.34 : 0.38)) {
    health = this.maxHealth;
    if (initialPosition != null) {
      _position.setFrom(initialPosition);
    }
    _createMesh();
  }

  /// Preset factory for Vintage Ambassador / Padmini sedan.
  factory Vehicle.car({
    String id = 'sedan_premier',
    String name = 'Premier Padmini Vintage Sedan',
    three.Vector3? initialPosition,
    double rotationY = 0.0,
    bool isOwnedByPlayer = true,
  }) =>
      Vehicle(
        id: id,
        name: name,
        vehicleType: VehicleType.car,
        isOwnedByPlayer: isOwnedByPlayer,
        initialPosition: initialPosition,
        rotationY: rotationY,
      );

  /// Preset factory for Royal Enfield Bullet 350.
  factory Vehicle.bike({
    String id = 'bike_bullet',
    String name = 'Royal Enfield Bullet 350',
    three.Vector3? initialPosition,
    double rotationY = 0.0,
    bool isOwnedByPlayer = false,
  }) =>
      Vehicle(
        id: id,
        name: name,
        vehicleType: VehicleType.bike,
        isOwnedByPlayer: isOwnedByPlayer,
        initialPosition: initialPosition,
        rotationY: rotationY,
      );

  /// Preset factory for Maruti Omni Cargo Van.
  factory Vehicle.van({
    String id = 'van_omni',
    String name = 'Maruti Omni Cargo Van',
    three.Vector3? initialPosition,
    double rotationY = 0.0,
    bool isOwnedByPlayer = false,
  }) =>
      Vehicle(
        id: id,
        name: name,
        vehicleType: VehicleType.van,
        isOwnedByPlayer: isOwnedByPlayer,
        initialPosition: initialPosition,
        rotationY: rotationY,
      );

  /// Preset factory for Tata 1210SE Heavy Timber Lorry.
  factory Vehicle.truck({
    String id = 'truck_tata',
    String name = 'Tata 1210SE Heavy Timber Lorry',
    three.Vector3? initialPosition,
    double rotationY = 0.0,
    bool isOwnedByPlayer = false,
  }) =>
      Vehicle(
        id: id,
        name: name,
        vehicleType: VehicleType.truck,
        isOwnedByPlayer: isOwnedByPlayer,
        initialPosition: initialPosition,
        rotationY: rotationY,
      );

  /// Preset factory for Kerala Police Cruiser.
  factory Vehicle.police({
    String id = 'cruiser_police',
    String name = 'Kerala Police Interceptor',
    three.Vector3? initialPosition,
    double rotationY = 0.0,
    bool isOwnedByPlayer = false,
  }) =>
      Vehicle(
        id: id,
        name: name,
        vehicleType: VehicleType.policeVehicle,
        isOwnedByPlayer: isOwnedByPlayer,
        initialPosition: initialPosition,
        rotationY: rotationY,
      );

  void _createMesh() {
    group = three.Group();

    final bodyMat = three.MeshStandardMaterial();
    final chromeMat = three.MeshStandardMaterial();
    chromeMat.color = three.Color.fromHex32(0xd6d9de);
    chromeMat.metalness = 0.9;
    chromeMat.roughness = 0.2;

    final windowMat = three.MeshStandardMaterial();
    windowMat.color = three.Color.fromHex32(0x0e141a);
    windowMat.metalness = 0.8;
    windowMat.roughness = 0.15;

    final rubberMat = three.MeshStandardMaterial();
    rubberMat.color = three.Color.fromHex32(0x141416);
    rubberMat.roughness = 0.9;

    final headlightMat = three.MeshStandardMaterial();
    headlightMat.color = three.Color.fromHex32(0xfff4c2);
    headlightMat.emissive = three.Color.fromHex32(0xffd573);

    final taillightMat = three.MeshStandardMaterial();
    taillightMat.color = three.Color.fromHex32(0xcc2222);
    taillightMat.emissive = three.Color.fromHex32(0x991111);

    switch (vehicleType) {
      case VehicleType.bike:
        // Royal Enfield Bullet 350
        bodyMat.color = three.Color.fromHex32(0x121212); // Jet black
        bodyMat.metalness = 0.7;

        bodyMesh = three.Mesh(three.BoxGeometry(0.35, 0.45, 1.8), bodyMat);
        bodyMesh.position.setValues(0, 0.55, 0);
        group.add(bodyMesh);

        // Fuel Tank
        final tank = three.Mesh(three.BoxGeometry(0.42, 0.28, 0.7), chromeMat);
        tank.position.setValues(0, 0.82, 0.35);
        group.add(tank);

        // Handlebars
        final bars = three.Mesh(three.BoxGeometry(0.85, 0.08, 0.08), chromeMat);
        bars.position.setValues(0, 1.05, 0.75);
        group.add(bars);

        // Cabin dummy for consistency
        cabinMesh = three.Mesh(three.BoxGeometry(0.32, 0.12, 0.65), bodyMat);
        cabinMesh.position.setValues(0, 0.75, -0.25);
        group.add(cabinMesh);

        // Wheels: Single Front, Single Rear
        final wheelGeo = three.CylinderGeometry(wheelRadius, wheelRadius, 0.16, 12);
        frontLeftWheelGroup = three.Group();
        frontLeftWheelGroup.position.setValues(0.0, 0.34, 0.9);
        frontLeftWheelMesh = three.Mesh(wheelGeo, rubberMat);
        frontLeftWheelMesh.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(frontLeftWheelMesh);
        group.add(frontLeftWheelGroup);

        frontRightWheelGroup = three.Group();
        frontRightWheelMesh = three.Mesh(three.BoxGeometry(0.01, 0.01, 0.01), rubberMat);
        frontRightWheelGroup.add(frontRightWheelMesh);

        rearLeftWheelMesh = three.Mesh(wheelGeo, rubberMat);
        rearLeftWheelMesh.position.setValues(0.0, 0.34, -0.9);
        rearLeftWheelMesh.rotation.z = math.pi / 2;
        group.add(rearLeftWheelMesh);

        rearRightWheelMesh = three.Mesh(three.BoxGeometry(0.01, 0.01, 0.01), rubberMat);
        break;

      case VehicleType.truck:
        // Tata 1210SE Heavy Timber Lorry
        bodyMat.color = three.Color.fromHex32(0x194d28); // Kerala lorry forest green

        final cargoMat = three.MeshStandardMaterial();
        cargoMat.color = three.Color.fromHex32(0x734a26); // Wooden timber planks

        // High Cab
        bodyMesh = three.Mesh(three.BoxGeometry(2.4, 1.4, 2.0), bodyMat);
        bodyMesh.position.setValues(0, 1.4, 1.8);
        group.add(bodyMesh);

        // Front Grille & Heavy Bullbar
        final bullbar = three.Mesh(three.BoxGeometry(2.5, 0.6, 0.3), chromeMat);
        bullbar.position.setValues(0, 0.6, 2.85);
        group.add(bullbar);

        // Rear Wooden Flatbed Cargo Tray
        cabinMesh = three.Mesh(three.BoxGeometry(2.45, 0.9, 4.0), cargoMat);
        cabinMesh.position.setValues(0, 1.15, -1.1);
        group.add(cabinMesh);

        // 4 Axle Wheels
        final truckWheelGeo = three.CylinderGeometry(wheelRadius, wheelRadius, 0.36, 14);
        frontLeftWheelGroup = three.Group();
        frontLeftWheelGroup.position.setValues(-1.25, 0.52, 1.8);
        frontLeftWheelMesh = three.Mesh(truckWheelGeo, rubberMat);
        frontLeftWheelMesh.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(frontLeftWheelMesh);
        group.add(frontLeftWheelGroup);

        frontRightWheelGroup = three.Group();
        frontRightWheelGroup.position.setValues(1.25, 0.52, 1.8);
        frontRightWheelMesh = three.Mesh(truckWheelGeo, rubberMat);
        frontRightWheelMesh.rotation.z = math.pi / 2;
        frontRightWheelGroup.add(frontRightWheelMesh);
        group.add(frontRightWheelGroup);

        rearLeftWheelMesh = three.Mesh(truckWheelGeo, rubberMat);
        rearLeftWheelMesh.position.setValues(-1.25, 0.52, -1.8);
        rearLeftWheelMesh.rotation.z = math.pi / 2;
        group.add(rearLeftWheelMesh);

        rearRightWheelMesh = three.Mesh(truckWheelGeo, rubberMat);
        rearRightWheelMesh.position.setValues(1.25, 0.52, -1.8);
        rearRightWheelMesh.rotation.z = math.pi / 2;
        group.add(rearRightWheelMesh);
        break;

      case VehicleType.van:
        // Maruti Omni Cargo Van
        bodyMat.color = three.Color.fromHex32(0xe2e6eb); // Utility white

        bodyMesh = three.Mesh(three.BoxGeometry(1.75, 1.1, 3.8), bodyMat);
        bodyMesh.position.setValues(0, 0.95, 0);
        group.add(bodyMesh);

        cabinMesh = three.Mesh(three.BoxGeometry(1.76, 0.5, 3.5), windowMat);
        cabinMesh.position.setValues(0, 1.25, 0);
        group.add(cabinMesh);

        final vanWheelGeo = three.CylinderGeometry(wheelRadius, wheelRadius, 0.24, 12);
        frontLeftWheelGroup = three.Group();
        frontLeftWheelGroup.position.setValues(-0.92, 0.38, 1.2);
        frontLeftWheelMesh = three.Mesh(vanWheelGeo, rubberMat);
        frontLeftWheelMesh.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(frontLeftWheelMesh);
        group.add(frontLeftWheelGroup);

        frontRightWheelGroup = three.Group();
        frontRightWheelGroup.position.setValues(0.92, 0.38, 1.2);
        frontRightWheelMesh = three.Mesh(vanWheelGeo, rubberMat);
        frontRightWheelMesh.rotation.z = math.pi / 2;
        frontRightWheelGroup.add(frontRightWheelMesh);
        group.add(frontRightWheelGroup);

        rearLeftWheelMesh = three.Mesh(vanWheelGeo, rubberMat);
        rearLeftWheelMesh.position.setValues(-0.92, 0.38, -1.2);
        rearLeftWheelMesh.rotation.z = math.pi / 2;
        group.add(rearLeftWheelMesh);

        rearRightWheelMesh = three.Mesh(vanWheelGeo, rubberMat);
        rearRightWheelMesh.position.setValues(0.92, 0.38, -1.2);
        rearRightWheelMesh.rotation.z = math.pi / 2;
        group.add(rearRightWheelMesh);
        break;

      case VehicleType.policeVehicle:
        // Kerala Police Interceptor
        bodyMat.color = three.Color.fromHex32(0xf0f3f6);

        bodyMesh = three.Mesh(three.BoxGeometry(1.9, 0.65, 4.3), bodyMat);
        bodyMesh.position.setValues(0, 0.58, 0);
        group.add(bodyMesh);

        cabinMesh = three.Mesh(three.BoxGeometry(1.68, 0.68, 2.3), windowMat);
        cabinMesh.position.setValues(0, 1.15, -0.2);
        group.add(cabinMesh);

        // Flashing Siren Bar
        final sirenBlue = three.Mesh(
          three.BoxGeometry(0.35, 0.15, 0.2),
          three.MeshStandardMaterial()..color = three.Color.fromHex32(0x0066ff)..emissive = three.Color.fromHex32(0x0044cc),
        );
        sirenBlue.position.setValues(-0.35, 1.55, -0.2);
        group.add(sirenBlue);

        final sirenRed = three.Mesh(
          three.BoxGeometry(0.35, 0.15, 0.2),
          three.MeshStandardMaterial()..color = three.Color.fromHex32(0xff2233)..emissive = three.Color.fromHex32(0xcc1122),
        );
        sirenRed.position.setValues(0.35, 1.55, -0.2);
        group.add(sirenRed);

        final policeWheelGeo = three.CylinderGeometry(wheelRadius, wheelRadius, 0.26, 14);
        frontLeftWheelGroup = three.Group();
        frontLeftWheelGroup.position.setValues(-1.0, 0.38, 1.3);
        frontLeftWheelMesh = three.Mesh(policeWheelGeo, rubberMat);
        frontLeftWheelMesh.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(frontLeftWheelMesh);
        group.add(frontLeftWheelGroup);

        frontRightWheelGroup = three.Group();
        frontRightWheelGroup.position.setValues(1.0, 0.38, 1.3);
        frontRightWheelMesh = three.Mesh(policeWheelGeo, rubberMat);
        frontRightWheelMesh.rotation.z = math.pi / 2;
        frontRightWheelGroup.add(frontRightWheelMesh);
        group.add(frontRightWheelGroup);

        rearLeftWheelMesh = three.Mesh(policeWheelGeo, rubberMat);
        rearLeftWheelMesh.position.setValues(-1.0, 0.38, -1.3);
        rearLeftWheelMesh.rotation.z = math.pi / 2;
        group.add(rearLeftWheelMesh);

        rearRightWheelMesh = three.Mesh(policeWheelGeo, rubberMat);
        rearRightWheelMesh.position.setValues(1.0, 0.38, -1.3);
        rearRightWheelMesh.rotation.z = math.pi / 2;
        group.add(rearRightWheelMesh);
        break;

      case VehicleType.car:
        // Classic Premier Padmini Sedan (Authentic Noir Kerala Taxi / Thriller sedan)
        bodyMat.color = three.Color.fromHex32(0x1a2130); // Deep midnight navy gloss
        bodyMat.metalness = 0.65;
        bodyMat.roughness = 0.35;

        // 1. Contoured Lower Chassis Body with slight wheel arch taper
        bodyMesh = three.Mesh(three.BoxGeometry(1.9, 0.62, 4.4), bodyMat);
        bodyMesh.position.setValues(0, 0.58, 0);
        group.add(bodyMesh);

        // 2. Sloped Front Hood & Engine Bonnet
        final bonnet = three.Mesh(three.BoxGeometry(1.82, 0.22, 1.4), bodyMat);
        bonnet.position.setValues(0, 0.76, 1.35);
        bonnet.rotation.x = -0.06;
        group.add(bonnet);

        // Chrome Front Grille (Iconic Padmini horizontal slats)
        final grille = three.Mesh(three.BoxGeometry(1.4, 0.28, 0.12), chromeMat);
        grille.position.setValues(0, 0.62, 2.22);
        group.add(grille);

        // Dual Round Chrome Headlights
        for (final hx in [-0.72, 0.72]) {
          final hl = three.Mesh(three.CylinderGeometry(0.14, 0.14, 0.08, 12), headlightMat);
          hl.rotation.x = math.pi / 2;
          hl.position.setValues(hx, 0.64, 2.22);
          group.add(hl);

          final bezel = three.Mesh(three.TorusGeometry(0.14, 0.025, 8, 14), chromeMat);
          bezel.position.setValues(hx, 0.64, 2.24);
          group.add(bezel);
        }

        // Dual Chrome Front & Rear Overrider Bumpers
        final fbumper = three.Mesh(three.BoxGeometry(1.98, 0.16, 0.22), chromeMat);
        fbumper.position.setValues(0, 0.38, 2.26);
        group.add(fbumper);

        final rbumper = three.Mesh(three.BoxGeometry(1.98, 0.16, 0.22), chromeMat);
        rbumper.position.setValues(0, 0.38, -2.26);
        group.add(rbumper);

        // Dual Rear Taillights
        for (final rx in [-0.74, 0.74]) {
          final tl = three.Mesh(three.BoxGeometry(0.24, 0.14, 0.08), taillightMat);
          tl.position.setValues(rx, 0.62, -2.22);
          group.add(tl);
        }

        // 3. Passenger Glass Greenhouse Cabin with A/B/C Pillars
        cabinMesh = three.Mesh(three.BoxGeometry(1.68, 0.65, 2.2), windowMat);
        cabinMesh.position.setValues(0, 1.15, -0.22);
        group.add(cabinMesh);

        // Metal Roof Skin with rain gutter lip
        final roof = three.Mesh(three.BoxGeometry(1.64, 0.08, 2.25), bodyMat);
        roof.position.setValues(0, 1.5, -0.22);
        group.add(roof);

        // Sloped rear boot lid (Trunk)
        final boot = three.Mesh(three.BoxGeometry(1.82, 0.22, 1.1), bodyMat);
        boot.position.setValues(0, 0.72, -1.55);
        boot.rotation.x = 0.08;
        group.add(boot);

        // 4. Wheels with Chrome Hubcaps
        final sedanWheelGeo = three.CylinderGeometry(wheelRadius, wheelRadius, 0.26, 14);
        final hubcapGeo = three.CylinderGeometry(wheelRadius * 0.48, wheelRadius * 0.48, 0.27, 10);

        frontLeftWheelGroup = three.Group();
        frontLeftWheelGroup.position.setValues(-1.0, 0.38, 1.3);
        frontLeftWheelMesh = three.Mesh(sedanWheelGeo, rubberMat);
        frontLeftWheelMesh.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(frontLeftWheelMesh);
        final fLHub = three.Mesh(hubcapGeo, chromeMat);
        fLHub.rotation.z = math.pi / 2;
        frontLeftWheelGroup.add(fLHub);
        group.add(frontLeftWheelGroup);

        frontRightWheelGroup = three.Group();
        frontRightWheelGroup.position.setValues(1.0, 0.38, 1.3);
        frontRightWheelMesh = three.Mesh(sedanWheelGeo, rubberMat);
        frontRightWheelMesh.rotation.z = math.pi / 2;
        frontRightWheelGroup.add(frontRightWheelMesh);
        final fRHub = three.Mesh(hubcapGeo, chromeMat);
        fRHub.rotation.z = math.pi / 2;
        frontRightWheelGroup.add(fRHub);
        group.add(frontRightWheelGroup);

        rearLeftWheelMesh = three.Mesh(sedanWheelGeo, rubberMat);
        rearLeftWheelMesh.position.setValues(-1.0, 0.38, -1.3);
        rearLeftWheelMesh.rotation.z = math.pi / 2;
        group.add(rearLeftWheelMesh);
        final rLHub = three.Mesh(hubcapGeo, chromeMat);
        rLHub.position.setValues(-1.0, 0.38, -1.3);
        rLHub.rotation.z = math.pi / 2;
        group.add(rLHub);

        rearRightWheelMesh = three.Mesh(sedanWheelGeo, rubberMat);
        rearRightWheelMesh.position.setValues(1.0, 0.38, -1.3);
        rearRightWheelMesh.rotation.z = math.pi / 2;
        group.add(rearRightWheelMesh);
        final rRHub = three.Mesh(hubcapGeo, chromeMat);
        rRHub.position.setValues(1.0, 0.38, -1.3);
        rRHub.rotation.z = math.pi / 2;
        group.add(rRHub);
        break;
    }

    _syncTransform();
  }

  void _syncTransform() {
    group.position.setFrom(_position);
    group.rotation.y = rotationY;
  }

  /// Updates wheels rotation and front steering pivot.
  void updateVisuals(double dt) {
    frontLeftWheelGroup.rotation.y = steeringAngle;
    frontRightWheelGroup.rotation.y = steeringAngle;

    final spinAngle = (speed * dt) / wheelRadius;
    frontLeftWheelMesh.rotation.x += spinAngle;
    frontRightWheelMesh.rotation.x += spinAngle;
    rearLeftWheelMesh.rotation.x += spinAngle;
    rearRightWheelMesh.rotation.x += spinAngle;

    _syncTransform();
  }

  @override
  void takeDamage(DamageInfo info) {
    if (isDead) return;
    health = (health - info.amount).clamp(0.0, maxHealth);

    if (health <= maxHealth * 0.45) {
      isEngineSmoking = true;
    }
    if (health <= maxHealth * 0.18) {
      isEngineOnFire = true;
    }

    if (health < 30.0) {
      speed *= 0.7;
    }
    if (health <= 0) {
      speed = 0.0;
    }
    onVehicleDamaged?.call(info);
  }

  @override
  bool canInteract(InteractionContext context) => !isWrecked;

  @override
  InteractionResult onInteract(InteractionContext context) {
    if (isWrecked) {
      return const InteractionResult.failure('Engine is totaled and beyond repair.');
    }
    isOccupied = !isOccupied;
    if (isOccupied && !isOwnedByPlayer) {
      isStolen = true;
    }
    final msg = isOccupied
        ? 'Mounted $name. Use WASD/Stick to steer, Space to brake.'
        : 'Dismounted $name.';
    return InteractionResult.success(msg);
  }
}
