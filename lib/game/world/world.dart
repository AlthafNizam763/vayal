import 'dart:math' as math;
import 'package:three_js/three_js.dart' as three;
import 'world_chunk_manager.dart';
import 'world_manager.dart';
import 'world_object.dart';
import 'world_region.dart';

/// Phase 15: Builds the complete expanded open world of Veyrapuram:
/// Village, Old Town Bazaar, Industrial Depot, Northern Forest,
/// Main City Commercial Avenue, Coastal Highway, Harbour Berth 4, and Arabian Sea.
/// Integrates with WorldChunkManager for streaming culling and high-performance LOD.
class World {
  late final WorldManager manager;
  late final WorldChunkManager chunkManager;
  late final three.DirectionalLight sunLight;
  late final three.AmbientLight ambientLight;

  World({WorldManager? worldManager, WorldChunkManager? worldChunkManager}) {
    manager = worldManager ?? WorldManager();
    chunkManager = worldChunkManager ?? WorldChunkManager();
  }

  void initialize(three.Scene scene) {
    manager.clear();

    // 1. Initial Lighting & Atmosphere
    ambientLight = three.AmbientLight(0x565d70, 0.5);
    scene.add(ambientLight);

    sunLight = three.DirectionalLight(0xeb8b52, 1.2);
    sunLight.position.setValues(15, 25, 20);
    scene.add(sunLight);

    // Initial dusk atmosphere
    manager.updateAtmosphere(0.0, scene, sunLight, ambientLight);

    // 2. Base Ground Surface & Village Sector
    _buildTerrain(scene);
    _buildRoads(scene);
    _buildAadiHouse(scene);
    _buildShops(scene);
    _buildPark(scene);
    _buildStreetLighting(scene);

    // 3. Phase 15: Expanded Open World Regional Districts
    _buildOldTownDistrict(scene);
    _buildIndustrialDistrict(scene);
    _buildForestDistrict(scene);
    _buildMainCityDistrict(scene);
    _buildHighwayDistrict(scene);
    _buildHarbourDistrict(scene);
    _buildSeaDistrict(scene);

    // 4. Outer Open World Boundary Perimeter
    _buildExpandedBoundaryPerimeter(scene);
  }

  void _buildTerrain(three.Scene scene) {
    final terrainGeo = three.PlaneGeometry(240, 360);
    final terrainMat = three.MeshStandardMaterial();
    terrainMat.color = three.Color.fromHex32(0x192019); // Soil and foliage base
    terrainMat.roughness = 0.95;

    final terrain = three.Mesh(terrainGeo, terrainMat);
    terrain.rotation.x = -math.pi / 2;
    terrain.position.setValues(0, -0.01, -70);
    scene.add(terrain);
  }

  void _buildRoads(three.Scene scene) {
    final roadMat = three.MeshStandardMaterial();
    roadMat.color = three.Color.fromHex32(0x181a1f); // Dark asphalt
    roadMat.roughness = 0.85;

    final markMat = three.MeshStandardMaterial();
    markMat.color = three.Color.fromHex32(0xcc9933); // Faded road markings
    markMat.roughness = 0.5;

    final sidewalkMat = three.MeshStandardMaterial();
    sidewalkMat.color = three.Color.fromHex32(0x383e47);
    sidewalkMat.roughness = 0.9;

    // 1. Central Village North-South Road (Z: -36 to 36)
    final nsRoadGeo = three.PlaneGeometry(7.0, 72.0);
    final nsRoad = three.Mesh(nsRoadGeo, roadMat);
    nsRoad.rotation.x = -math.pi / 2;
    nsRoad.position.setValues(0, 0.02, 0);
    scene.add(nsRoad);

    // 2. East-West Central Road (Connecting Old Town <-> Village <-> Industrial)
    // From X: -95 to X: 95
    final ewRoadGeo = three.PlaneGeometry(190.0, 7.0);
    final ewRoad = three.Mesh(ewRoadGeo, roadMat);
    ewRoad.rotation.x = -math.pi / 2;
    ewRoad.position.setValues(0, 0.025, 0);
    scene.add(ewRoad);

    // Center stripes
    for (double x = -90.0; x <= 90.0; x += 6.0) {
      if (x > -5.0 && x < 5.0) continue;
      final stripeGeo = three.PlaneGeometry(2.8, 0.25);
      final stripe = three.Mesh(stripeGeo, markMat);
      stripe.rotation.x = -math.pi / 2;
      stripe.position.setValues(x, 0.03, 0);
      scene.add(stripe);
    }

    // Sidewalk Curbs along Village core
    _addSidewalk(scene, sidewalkMat, -4.2, 0, 1.4, 72.0);
    _addSidewalk(scene, sidewalkMat, 4.2, 0, 1.4, 72.0);
  }

  void _addSidewalk(three.Scene scene, three.MeshStandardMaterial mat, double x, double z, double w, double d) {
    final walkGeo = three.BoxGeometry(w, 0.15, d);
    final walk = three.Mesh(walkGeo, mat);
    walk.position.setValues(x, 0.075, z);
    scene.add(walk);
  }

  void _buildAadiHouse(three.Scene scene) {
    final houseGroup = three.Group();

    // Authentic Kerala vernacular palette with realistic material properties
    final baseMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x3a332c) // Laterite stone foundation
      ..roughness = 0.92;

    final wallMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xd6cfc4) // Traditional lime-wash plaster
      ..roughness = 0.88;

    final woodMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x3e2316) // Rich aged Kerala teak / Rosewood
      ..roughness = 0.65;

    final tileMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x9a3f25) // Terracotta Mangalore roof tiles
      ..roughness = 0.72;

    final darkWoodMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x23140c)
      ..roughness = 0.55;

    final warmGlowMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xffb74d)
      ..emissive = three.Color.fromHex32(0xff8f00)
      ..roughness = 0.3;

    // 1. Plinth / Jagati (raised laterite plinth foundation)
    final plinth = three.Mesh(three.BoxGeometry(13.4, 0.45, 11.4), baseMat);
    plinth.position.setValues(-18.0, 0.225, -11.0);
    houseGroup.add(plinth);

    // Stone Steps leading up to the verandah
    for (int step = 0; step < 3; step++) {
      final s = three.Mesh(three.BoxGeometry(3.0 - step * 0.3, 0.15, 0.5), baseMat);
      s.position.setValues(-18.0, 0.075 + step * 0.15, -4.9 + step * 0.35);
      houseGroup.add(s);
    }

    // 2. Main Ground Floor Living Core
    final groundFloor = three.Mesh(three.BoxGeometry(11.6, 3.4, 8.2), wallMat);
    groundFloor.position.setValues(-18.0, 2.15, -12.4);
    houseGroup.add(groundFloor);

    // Teak Corner Framing Columns on Main Structure
    for (final cx in [-23.6, -12.4]) {
      for (final cz in [-16.3, -8.5]) {
        final col = three.Mesh(three.BoxGeometry(0.35, 3.4, 0.35), woodMat);
        col.position.setValues(cx, 2.15, cz);
        houseGroup.add(col);
      }
    }

    // 3. Poomukham / Open Verandah Deck with Charupadi (built-in wooden bench seating)
    final verandaFloor = three.Mesh(three.BoxGeometry(11.8, 0.2, 3.4), woodMat);
    verandaFloor.position.setValues(-18.0, 0.45, -6.6);
    houseGroup.add(verandaFloor);

    // Carved Round Teak Pillars supporting the front eaves
    for (double vx in [-23.2, -19.7, -16.3, -12.8]) {
      // Pillar stone base
      final pBase = three.Mesh(three.CylinderGeometry(0.24, 0.28, 0.35, 12), baseMat);
      pBase.position.setValues(vx, 0.625, -5.1);
      houseGroup.add(pBase);

      // Fluted wood pillar shaft
      final pShaft = three.Mesh(three.CylinderGeometry(0.16, 0.20, 2.6, 12), woodMat);
      pShaft.position.setValues(vx, 2.1, -5.1);
      houseGroup.add(pShaft);

      // Decorative pillar capital
      final pCap = three.Mesh(three.BoxGeometry(0.42, 0.2, 0.42), woodMat);
      pCap.position.setValues(vx, 3.5, -5.1);
      houseGroup.add(pCap);
    }

    // Wooden Charupadi (slanted bench railing along the verandah sides)
    for (final sideX in [-23.6, -12.4]) {
      final bench = three.Mesh(three.BoxGeometry(0.25, 0.75, 3.0), woodMat);
      bench.position.setValues(sideX, 0.9, -6.6);
      bench.rotation.z = sideX < -18 ? -0.15 : 0.15;
      houseGroup.add(bench);
    }

    // 4. Heavy Carved Main Entrance Door (Padippura-style framing)
    final doorFrame = three.Mesh(three.BoxGeometry(1.8, 2.8, 0.3), darkWoodMat);
    doorFrame.position.setValues(-18.0, 1.85, -8.2);
    houseGroup.add(doorFrame);

    final doorPanelL = three.Mesh(three.BoxGeometry(0.72, 2.5, 0.08), woodMat);
    doorPanelL.position.setValues(-18.4, 1.8, -8.1);
    houseGroup.add(doorPanelL);

    final doorPanelR = three.Mesh(three.BoxGeometry(0.72, 2.5, 0.08), woodMat);
    doorPanelR.position.setValues(-17.6, 1.8, -8.1);
    houseGroup.add(doorPanelR);

    // Brass door ring/knocker
    final knocker = three.Mesh(three.TorusGeometry(0.06, 0.015, 8, 16), three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xd4af37)
      ..metalness = 0.8
      ..roughness = 0.3);
    knocker.position.setValues(-17.6, 1.8, -8.04);
    houseGroup.add(knocker);

    // Traditional Verandah Hanging Brass Oil Lamp (Thookkuvilakku)
    final lampChain = three.Mesh(three.CylinderGeometry(0.01, 0.01, 0.8, 6), darkWoodMat);
    lampChain.position.setValues(-18.0, 3.2, -6.0);
    houseGroup.add(lampChain);

    final brassLamp = three.Mesh(three.ConeGeometry(0.18, 0.14, 10), warmGlowMat);
    brassLamp.position.setValues(-18.0, 2.75, -6.0);
    brassLamp.rotation.x = math.pi;
    houseGroup.add(brassLamp);

    // 5. Traditional Louvered Wood Windows on Front Facade
    for (final wx in [-21.2, -14.8]) {
      final winFrame = three.Mesh(three.BoxGeometry(1.4, 1.5, 0.2), darkWoodMat);
      winFrame.position.setValues(wx, 2.1, -8.2);
      houseGroup.add(winFrame);

      // Louvers / wooden vertical bars
      for (double bx = -0.45; bx <= 0.45; bx += 0.22) {
        final bar = three.Mesh(three.CylinderGeometry(0.025, 0.025, 1.25, 6), woodMat);
        bar.position.setValues(wx + bx, 2.1, -8.15);
        houseGroup.add(bar);
      }
    }

    // 6. Upper Storey / Attic (Machu) with wooden jali ventilation grilles
    final upperStorey = three.Mesh(three.BoxGeometry(9.6, 1.8, 6.8), woodMat);
    upperStorey.position.setValues(-18.0, 4.75, -12.4);
    houseGroup.add(upperStorey);

    // Gable End Windows with wooden lattice louvers
    final gableWin = three.Mesh(three.BoxGeometry(1.6, 1.0, 0.15), darkWoodMat);
    gableWin.position.setValues(-18.0, 4.8, -8.9);
    houseGroup.add(gableWin);

    // 7. Sloped Terracotta Roof (Kerala Hip Roof with extended overhanging eaves)
    // Lower Verandah Roof (Eaves shading the porch)
    final lowerRoofGeo = three.ConeGeometry(8.8, 2.2, 4);
    final lowerRoof = three.Mesh(lowerRoofGeo, tileMat);
    lowerRoof.position.setValues(-18.0, 4.4, -6.4);
    lowerRoof.rotation.y = math.pi / 4;
    lowerRoof.scale = three.Vector3(1.35, 0.65, 0.95);
    houseGroup.add(lowerRoof);

    // Main Upper Terracotta Tiled Roof
    final mainRoofGeo = three.ConeGeometry(10.2, 3.4, 4);
    final mainRoof = three.Mesh(mainRoofGeo, tileMat);
    mainRoof.position.setValues(-18.0, 6.9, -12.4);
    mainRoof.rotation.y = math.pi / 4;
    mainRoof.scale = three.Vector3(1.32, 1.0, 0.95);
    houseGroup.add(mainRoof);

    // Carved Wooden Eave Fascia Board (Mukhamppu) at the ridge apex
    final ridgeFascia = three.Mesh(three.ConeGeometry(1.2, 0.9, 3), woodMat);
    ridgeFascia.position.setValues(-18.0, 8.4, -8.0);
    houseGroup.add(ridgeFascia);

    scene.add(houseGroup);

    manager.registerObject(WorldObject(
      id: 'aadi_house',
      name: "Aadi's Family House",
      mesh: houseGroup,
      bounds: WorldBounds.fromCenter(cx: -18.0, cz: -11.0, width: 14.0, depth: 12.0, height: 8.5),
      isSolid: true,
    ));
  }

  void _buildShops(three.Scene scene) {
    final shopGroup = three.Group();

    // Weathered roadside tea stall materials
    final woodMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x4a3222) // Aged teak planks
      ..roughness = 0.85;

    final benchMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x352317)
      ..roughness = 0.9;

    final tarpMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x1e4535) // Weathered forest green tarpaulin
      ..roughness = 0.82;

    final steelMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xa0a8b4) // Stainless steel tea boiler
      ..metalness = 0.88
      ..roughness = 0.22;

    final brassMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xd4af37)
      ..metalness = 0.75
      ..roughness = 0.35;

    final glassMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0xe0e6ed)
      ..roughness = 0.1
      ..transparent = true
      ..opacity = 0.75;

    // 1. Raised Wooden Platform Base
    final platform = three.Mesh(three.BoxGeometry(5.4, 0.25, 4.4), woodMat);
    platform.position.setValues(14.0, 0.125, 8.0);
    shopGroup.add(platform);

    // 2. Main Stall Cabin (Weathered wooden plank walls)
    final cabin = three.Mesh(three.BoxGeometry(4.2, 2.8, 3.2), woodMat);
    cabin.position.setValues(14.0, 1.55, 8.0);
    shopGroup.add(cabin);

    // Corner Support Poles (Bamboo / Teak uprights)
    for (final px in [11.8, 16.2]) {
      for (final pz in [6.3, 9.7]) {
        final pole = three.Mesh(three.CylinderGeometry(0.08, 0.09, 3.4, 8), woodMat);
        pole.position.setValues(px, 1.7, pz);
        shopGroup.add(pole);
      }
    }

    // 3. Countertop Serving Hatch
    final counter = three.Mesh(three.BoxGeometry(3.6, 0.14, 0.75), woodMat);
    counter.position.setValues(14.0, 1.15, 6.3);
    shopGroup.add(counter);

    // 4. Iconic Kerala Cylindrical Chai Boiler (Samovar)
    final samovar = three.Mesh(three.CylinderGeometry(0.24, 0.24, 0.72, 14), steelMat);
    samovar.position.setValues(12.8, 1.58, 6.3);
    shopGroup.add(samovar);

    final samovarLid = three.Mesh(three.ConeGeometry(0.25, 0.18, 12), brassMat);
    samovarLid.position.setValues(12.8, 2.03, 6.3);
    shopGroup.add(samovarLid);

    // Chimney pipe for the coal/gas boiler
    final flue = three.Mesh(three.CylinderGeometry(0.04, 0.04, 0.8, 8), steelMat);
    flue.position.setValues(12.8, 2.5, 6.3);
    shopGroup.add(flue);

    // Glass display case for snacks (Parippuvada / Banana fritters)
    final snackCase = three.Mesh(three.BoxGeometry(1.1, 0.55, 0.55), glassMat);
    snackCase.position.setValues(14.8, 1.48, 6.3);
    shopGroup.add(snackCase);

    // 5. Sloped Monsoon Tarpaulin & Corrugated Roof with overhanging eaves
    final roofGeo = three.ConeGeometry(5.8, 1.4, 4);
    final roof = three.Mesh(roofGeo, tarpMat);
    roof.position.setValues(14.0, 3.4, 8.0);
    roof.rotation.y = math.pi / 4;
    roof.scale = three.Vector3(1.25, 0.55, 1.05);
    shopGroup.add(roof);

    // 6. Roadside Customer Benches (Aged wooden benches in front)
    final bench = three.Mesh(three.BoxGeometry(3.4, 0.45, 0.4), benchMat);
    bench.position.setValues(14.0, 0.35, 5.2);
    shopGroup.add(bench);

    scene.add(shopGroup);

    manager.registerObject(WorldObject(
      id: 'balan_stall',
      name: "Balan's Chai Stall",
      mesh: shopGroup,
      bounds: WorldBounds.fromCenter(cx: 14.0, cz: 8.0, width: 6.0, depth: 5.2, height: 4.2),
      isSolid: true,
    ));
  }

  void _buildPark(three.Scene scene) {
    final parkGroup = three.Group();

    // Lush Kerala monsoon soil and grass
    final groundMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x1b3518) // Rich tropical greenery
      ..roughness = 0.92;

    final canalMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x0f2a35) // Backwater canal water
      ..metalness = 0.75
      ..roughness = 0.25;

    // Park meadow
    final parkLawn = three.Mesh(three.PlaneGeometry(32, 28), groundMat);
    parkLawn.rotation.x = -math.pi / 2;
    parkLawn.position.setValues(-16.0, 0.03, 16.0);
    parkGroup.add(parkLawn);

    // Small village drainage / backwater irrigation stream
    final canal = three.Mesh(three.PlaneGeometry(3.2, 28.0), canalMat);
    canal.rotation.x = -math.pi / 2;
    canal.position.setValues(-28.0, 0.02, 16.0);
    parkGroup.add(canal);

    // Add Realistic Kerala Coconut Palms and Tropical Flora
    final palmLocations = [
      three.Vector3(-8.0, 0, 8.0),
      three.Vector3(-14.0, 0, 24.0),
      three.Vector3(-22.0, 0, 11.0),
      three.Vector3(-25.0, 0, 23.0),
      three.Vector3(-9.0, 0, 26.0),
    ];

    for (final loc in palmLocations) {
      _addCoconutPalm(parkGroup, loc.x, loc.z);
    }

    scene.add(parkGroup);
  }

  /// Realistic procedural Kerala Coconut Palm (Thengu) with curved trunk,
  /// textured ring nodes, crown bulb, and cascading arching palm fronds.
  void _addCoconutPalm(three.Group group, double x, double z) {
    final trunkMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x4a3c31) // Weathered greyish-brown palm bark
      ..roughness = 0.92;

    final frondMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x1f5c25) // Deep emerald green palm fronds
      ..roughness = 0.75;

    final coconutMat = three.MeshStandardMaterial()
      ..color = three.Color.fromHex32(0x2d441e) // Tender green/brown coconuts
      ..roughness = 0.8;

    // 1. Curved Multi-Segment Palm Trunk
    const int segments = 6;
    const double segHeight = 1.35;
    double currentY = 0.0;
    double currentX = x;
    double currentZ = z;

    // Lean direction based on pseudo-random coordinates
    final leanAngleX = (math.sin(x * 0.7) * 0.08);
    final leanAngleZ = (math.cos(z * 0.7) * 0.08);

    for (int i = 0; i < segments; i++) {
      final bottomR = 0.32 - (i * 0.025);
      final topR = 0.32 - ((i + 1) * 0.025);
      final trunkSeg = three.Mesh(
        three.CylinderGeometry(topR, bottomR, segHeight, 10),
        trunkMat,
      );

      trunkSeg.position.setValues(currentX, currentY + segHeight / 2, currentZ);
      trunkSeg.rotation.z = leanAngleX * (i + 1);
      trunkSeg.rotation.x = leanAngleZ * (i + 1);
      group.add(trunkSeg);

      // Ring node band for authentic palm tree texture
      final ringNode = three.Mesh(
        three.CylinderGeometry(topR * 1.08, bottomR * 1.06, 0.08, 10),
        trunkMat,
      );
      ringNode.position.setValues(currentX, currentY + segHeight, currentZ);
      group.add(ringNode);

      currentY += segHeight;
      currentX += leanAngleX * 0.6;
      currentZ += leanAngleZ * 0.6;
    }

    // 2. Crown Bulb at top of trunk
    final crown = three.Mesh(three.SphereGeometry(0.38, 10, 8), frondMat);
    crown.position.setValues(currentX, currentY, currentZ);
    group.add(crown);

    // 3. Cluster of Coconuts under the fronds
    for (int c = 0; c < 5; c++) {
      final angle = c * (math.pi * 2 / 5);
      final nut = three.Mesh(three.SphereGeometry(0.18, 8, 6), coconutMat);
      nut.scale = three.Vector3(0.9, 1.25, 0.9);
      nut.position.setValues(
        currentX + math.cos(angle) * 0.28,
        currentY - 0.2,
        currentZ + math.sin(angle) * 0.28,
      );
      group.add(nut);
    }

    // 4. Radiating Arching Palm Fronds (Feathery drooping leaves)
    const int frondCount = 9;
    for (int f = 0; f < frondCount; f++) {
      final angle = (f / frondCount) * math.pi * 2;
      // Arching frond blade
      final frond = three.Mesh(
        three.BoxGeometry(0.35, 0.06, 3.2),
        frondMat,
      );
      // Position at crown, angle outwards and droop downwards
      frond.position.setValues(
        currentX + math.sin(angle) * 1.4,
        currentY - 0.25,
        currentZ + math.cos(angle) * 1.4,
      );
      frond.rotation.y = angle;
      frond.rotation.x = 0.55; // Droop toward earth
      group.add(frond);
    }
  }

  void _addTree(three.Group group, double x, double z) {
    _addCoconutPalm(group, x, z);
  }

  void _buildStreetLighting(three.Scene scene) {
    final lampMat = three.MeshStandardMaterial();
    lampMat.color = three.Color.fromHex32(0x263238);

    final bulbMat = three.MeshStandardMaterial();
    bulbMat.color = three.Color.fromHex32(0xffe082);
    bulbMat.emissive = three.Color.fromHex32(0xffb74d);

    final lampPositions = [
      three.Vector3(-4.8, 0, -18.0),
      three.Vector3(4.8, 0, -6.0),
      three.Vector3(-4.8, 0, 6.0),
      three.Vector3(4.8, 0, 18.0),
    ];

    for (final pos in lampPositions) {
      final pole = three.Mesh(three.CylinderGeometry(0.12, 0.16, 5.5, 8), lampMat);
      pole.position.setValues(pos.x, 2.75, pos.z);
      scene.add(pole);

      final bulb = three.Mesh(three.SphereGeometry(0.32, 8, 8), bulbMat);
      bulb.position.setValues(pos.x, 5.4, pos.z);
      scene.add(bulb);
    }
  }

  // -------------------------------------------------------------
  // PHASE 15: EXPANDED OPEN WORLD REGIONAL DISTRICTS
  // -------------------------------------------------------------

  /// 1. Old Town Bazaar (West Region: X ~ -62, Z ~ 0)
  void _buildOldTownDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final stoneMat = three.MeshStandardMaterial();
    stoneMat.color = three.Color.fromHex32(0x403d39); // Cobblestone ground
    stoneMat.roughness = 0.9;

    final clayWallMat = three.MeshStandardMaterial();
    clayWallMat.color = three.Color.fromHex32(0x8a5a44);
    clayWallMat.roughness = 0.85;

    final roofMat = three.MeshStandardMaterial();
    roofMat.color = three.Color.fromHex32(0xa64b2a); // Traditional terracotta tile

    // Ground Plaza
    final plaza = three.Mesh(three.PlaneGeometry(60, 60), stoneMat);
    plaza.rotation.x = -math.pi / 2;
    plaza.position.setValues(-62.0, 0.02, 0);
    districtGroup.add(plaza);

    // Stone Welcome Gateway Arch
    final archPillar1 = three.Mesh(three.BoxGeometry(1.2, 5.0, 1.2), stoneMat);
    archPillar1.position.setValues(-38.0, 2.5, -4.5);
    districtGroup.add(archPillar1);

    final archPillar2 = three.Mesh(three.BoxGeometry(1.2, 5.0, 1.2), stoneMat);
    archPillar2.position.setValues(-38.0, 2.5, 4.5);
    districtGroup.add(archPillar2);

    final archBeam = three.Mesh(three.BoxGeometry(1.4, 0.9, 10.2), stoneMat);
    archBeam.position.setValues(-38.0, 5.2, 0);
    districtGroup.add(archBeam);

    // Heritage Shopfronts along Bazaar
    for (int i = 0; i < 4; i++) {
      final bldg = three.Mesh(three.BoxGeometry(9.0, 5.5, 12.0), clayWallMat);
      final zOffset = (i % 2 == 0) ? -16.0 : 16.0;
      final xOffset = -55.0 - (i * 8.0);
      bldg.position.setValues(xOffset, 2.75, zOffset);
      districtGroup.add(bldg);

      final roof = three.Mesh(three.ConeGeometry(8.5, 2.5, 4), roofMat);
      roof.position.setValues(xOffset, 6.7, zOffset);
      roof.rotation.y = math.pi / 4;
      districtGroup.add(roof);
    }

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.oldTown, districtGroup);
  }

  /// 2. Industrial District & Cargo Depot (East Region: X ~ 62, Z ~ 0)
  void _buildIndustrialDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final asphaltMat = three.MeshStandardMaterial();
    asphaltMat.color = three.Color.fromHex32(0x23272e);
    asphaltMat.roughness = 0.85;

    final warehouseMat = three.MeshStandardMaterial();
    warehouseMat.color = three.Color.fromHex32(0x4b5363); // Corrugated steel
    warehouseMat.metalness = 0.6;
    warehouseMat.roughness = 0.5;

    // Depot Ground
    final yard = three.Mesh(three.PlaneGeometry(60, 60), asphaltMat);
    yard.rotation.x = -math.pi / 2;
    yard.position.setValues(62.0, 0.02, 0);
    districtGroup.add(yard);

    // Main Berth 4 Cargo Warehouse
    final warehouse = three.Mesh(three.BoxGeometry(22.0, 7.5, 28.0), warehouseMat);
    warehouse.position.setValues(68.0, 3.75, 0.0);
    districtGroup.add(warehouse);

    // Stacks of Shipping Cargo Containers
    final containerColors = [0x8a2424, 0x224a8a, 0x2e6638, 0xc47e1b];
    final containerGeo = three.BoxGeometry(5.8, 2.4, 2.4);

    for (int i = 0; i < 6; i++) {
      final cMat = three.MeshStandardMaterial();
      cMat.color = three.Color.fromHex32(containerColors[i % containerColors.length]);
      cMat.roughness = 0.6;

      final cont = three.Mesh(containerGeo, cMat);
      final cx = 48.0 + (i % 2) * 6.5;
      final cz = -14.0 + (i * 5.0);
      final cy = (i == 4 || i == 5) ? 3.6 : 1.2;
      cont.position.setValues(cx, cy, cz);
      districtGroup.add(cont);
    }

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.industrial, districtGroup);
  }

  /// 3. Northern Teak Forest (North Region: X ~ 0, Z ~ 72)
  void _buildForestDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final mossMat = three.MeshStandardMaterial();
    mossMat.color = three.Color.fromHex32(0x132415);
    mossMat.roughness = 0.95;

    final forestGround = three.Mesh(three.PlaneGeometry(70, 70), mossMat);
    forestGround.rotation.x = -math.pi / 2;
    forestGround.position.setValues(0, 0.02, 72.0);
    districtGroup.add(forestGround);

    // Unpaved dirt trail running north
    final dirtMat = three.MeshStandardMaterial();
    dirtMat.color = three.Color.fromHex32(0x382d22);
    final trail = three.Mesh(three.PlaneGeometry(6.0, 70.0), dirtMat);
    trail.rotation.x = -math.pi / 2;
    trail.position.setValues(0, 0.025, 72.0);
    districtGroup.add(trail);

    // Dense tree clusters
    for (double fx = -26.0; fx <= 26.0; fx += 13.0) {
      if (fx > -4 && fx < 4) continue;
      for (double fz = 45.0; fz <= 95.0; fz += 16.0) {
        _addTree(districtGroup, fx, fz);
      }
    }

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.forest, districtGroup);
  }

  /// 4. Main City Commercial Avenue (South Region: X ~ 0, Z ~ -70)
  void _buildMainCityDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final roadMat = three.MeshStandardMaterial();
    roadMat.color = three.Color.fromHex32(0x1c1e24);

    final cityPave = three.Mesh(three.PlaneGeometry(70, 70), roadMat);
    cityPave.rotation.x = -math.pi / 2;
    cityPave.position.setValues(0, 0.02, -70.0);
    districtGroup.add(cityPave);

    // 4-Lane City Avenue
    final aveGeo = three.PlaneGeometry(12.0, 70.0);
    final ave = three.Mesh(aveGeo, roadMat);
    ave.rotation.x = -math.pi / 2;
    ave.position.setValues(0, 0.025, -70.0);
    districtGroup.add(ave);

    // Commercial high-rise block facades
    final bldgMat = three.MeshStandardMaterial();
    bldgMat.color = three.Color.fromHex32(0x28323e);
    bldgMat.roughness = 0.5;

    for (int i = 0; i < 4; i++) {
      final bldg = three.Mesh(three.BoxGeometry(14.0, 16.0, 14.0), bldgMat);
      final bx = (i % 2 == 0) ? -18.0 : 18.0;
      final bz = -50.0 - (i * 12.0);
      bldg.position.setValues(bx, 8.0, bz);
      districtGroup.add(bldg);
    }

    // Police Precinct Beacon Facade (West side)
    final policeMat = three.MeshStandardMaterial();
    policeMat.color = three.Color.fromHex32(0x1e3a5f);
    final policeBuilding = three.Mesh(three.BoxGeometry(16.0, 10.0, 14.0), policeMat);
    policeBuilding.position.setValues(-19.0, 5.0, -82.0);
    districtGroup.add(policeBuilding);

    final sirenBeaconMat = three.MeshStandardMaterial();
    sirenBeaconMat.color = three.Color.fromHex32(0x3388ff);
    sirenBeaconMat.emissive = three.Color.fromHex32(0x1a66ff);
    final beacon = three.Mesh(three.SphereGeometry(0.4, 8, 8), sirenBeaconMat);
    beacon.position.setValues(-19.0, 10.3, -75.0);
    districtGroup.add(beacon);

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.mainCity, districtGroup);
  }

  /// 5. Coastal Highway Corridor (South Region: X ~ 0, Z ~ -140)
  void _buildHighwayDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final hwayMat = three.MeshStandardMaterial();
    hwayMat.color = three.Color.fromHex32(0x14161b);
    hwayMat.roughness = 0.8;

    final barrierMat = three.MeshStandardMaterial();
    barrierMat.color = three.Color.fromHex32(0x9ca3af); // Steel highway guardrail

    // Highway Road Deck
    final deck = three.Mesh(three.PlaneGeometry(14.0, 70.0), hwayMat);
    deck.rotation.x = -math.pi / 2;
    deck.position.setValues(0, 0.05, -140.0);
    districtGroup.add(deck);

    // Guardrails on both sides
    final lrail = three.Mesh(three.BoxGeometry(0.3, 0.9, 70.0), barrierMat);
    lrail.position.setValues(-7.2, 0.45, -140.0);
    districtGroup.add(lrail);

    final rrail = three.Mesh(three.BoxGeometry(0.3, 0.9, 70.0), barrierMat);
    rrail.position.setValues(7.2, 0.45, -140.0);
    districtGroup.add(rrail);

    // Overhead Highway Green Signboard
    final signMat = three.MeshStandardMaterial();
    signMat.color = three.Color.fromHex32(0x145a32); // Highway sign green
    final sign = three.Mesh(three.BoxGeometry(8.5, 2.2, 0.3), signMat);
    sign.position.setValues(0, 6.2, -130.0);
    districtGroup.add(sign);

    final signPillar = three.Mesh(three.BoxGeometry(0.4, 7.0, 0.4), barrierMat);
    signPillar.position.setValues(-7.0, 3.5, -130.0);
    districtGroup.add(signPillar);

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.highway, districtGroup);
  }

  /// 6. Port Veyrapuram & Berth 4 Docks (Far South: X ~ 0, Z ~ -210)
  void _buildHarbourDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final dockMat = three.MeshStandardMaterial();
    dockMat.color = three.Color.fromHex32(0x374151); // Concrete pier
    dockMat.roughness = 0.9;

    final craneMat = three.MeshStandardMaterial();
    craneMat.color = three.Color.fromHex32(0xd97736); // Industrial crane amber-orange
    craneMat.metalness = 0.7;

    // Concrete Pier Apron
    final pier = three.Mesh(three.BoxGeometry(60.0, 1.5, 70.0), dockMat);
    pier.position.setValues(0, 0.75, -210.0);
    districtGroup.add(pier);

    // Giant Container Shipping Crane Tower
    final craneLeg1 = three.Mesh(three.BoxGeometry(0.8, 22.0, 0.8), craneMat);
    craneLeg1.position.setValues(-16.0, 11.0, -220.0);
    districtGroup.add(craneLeg1);

    final craneLeg2 = three.Mesh(three.BoxGeometry(0.8, 22.0, 0.8), craneMat);
    craneLeg2.position.setValues(-16.0, 11.0, -200.0);
    districtGroup.add(craneLeg2);

    final craneBoom = three.Mesh(three.BoxGeometry(28.0, 1.4, 1.4), craneMat);
    craneBoom.position.setValues(-6.0, 22.0, -210.0);
    districtGroup.add(craneBoom);

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.harbour, districtGroup);
  }

  /// 7. Arabian Sea & Water Horizon (Z < -245)
  void _buildSeaDistrict(three.Scene scene) {
    final districtGroup = three.Group();

    final waterMat = three.MeshStandardMaterial();
    waterMat.color = three.Color.fromHex32(0x0a192f); // Deep oceanic navy blue
    waterMat.metalness = 0.85;
    waterMat.roughness = 0.2;

    final ocean = three.Mesh(three.PlaneGeometry(280, 120), waterMat);
    ocean.rotation.x = -math.pi / 2;
    ocean.position.setValues(0, -0.2, -295.0);
    districtGroup.add(ocean);

    scene.add(districtGroup);
    chunkManager.registerRegionGroup(WorldRegion.sea, districtGroup);
  }

  void _buildExpandedBoundaryPerimeter(three.Scene scene) {
    final wallMat = three.MeshStandardMaterial();
    wallMat.color = three.Color.fromHex32(0x22262c);
    wallMat.roughness = 0.9;

    // Outer perimeter limits for entire expanded world (X: -105 to 105, Z: -260 to 115)
    // 1. Far West Wall (X = -105)
    _addBoundarySegment(scene, wallMat, 'wall_outer_west', -105.0, -70.0, 1.5, 380.0);
    // 2. Far East Wall (X = 105)
    _addBoundarySegment(scene, wallMat, 'wall_outer_east', 105.0, -70.0, 1.5, 380.0);
    // 3. Far North Forest Edge (Z = 115)
    _addBoundarySegment(scene, wallMat, 'wall_outer_north', 0, 115.0, 210.0, 1.5);
    // 4. Far South Seawall Barrier (Z = -250)
    _addBoundarySegment(scene, wallMat, 'wall_outer_south', 0, -250.0, 210.0, 1.5);
  }

  void _addBoundarySegment(
    three.Scene scene,
    three.MeshStandardMaterial mat,
    String id,
    double x,
    double z,
    double w,
    double d,
  ) {
    final wall = three.Mesh(three.BoxGeometry(w, 3.5, d), mat);
    wall.position.setValues(x, 1.75, z);
    scene.add(wall);

    manager.registerObject(WorldObject(
      id: id,
      name: 'Boundary Wall',
      mesh: wall,
      bounds: WorldBounds.fromCenter(cx: x, cz: z, width: w, depth: d, height: 4.0),
      isSolid: true,
    ));
  }
}
