import 'package:three_js/three_js.dart' as three;

/// The 8 interconnected geographic districts of expanded Veyrapuram.
enum WorldRegion {
  village,
  oldTown,
  industrial,
  forest,
  mainCity,
  highway,
  harbour,
  sea,
}

/// Metadata, display title, and coordinates for a Veyrapuram world region.
class RegionData {
  final WorldRegion region;
  final String title;
  final String subtitle;
  final three.Vector3 center;
  final double radius;

  const RegionData({
    required this.region,
    required this.title,
    required this.subtitle,
    required this.center,
    required this.radius,
  });

  static final Map<WorldRegion, RegionData> registry = {
    WorldRegion.village: RegionData(
      region: WorldRegion.village,
      title: 'VILLAGE SECTOR',
      subtitle: 'Menon Family Residence & Town Center',
      center: three.Vector3(0, 0, 0),
      radius: 35.0,
    ),
    WorldRegion.oldTown: RegionData(
      region: WorldRegion.oldTown,
      title: 'OLD TOWN BAZAAR',
      subtitle: 'Heritage Quarters & Narrow Alleys',
      center: three.Vector3(-62.0, 0, 0),
      radius: 35.0,
    ),
    WorldRegion.industrial: RegionData(
      region: WorldRegion.industrial,
      title: 'INDUSTRIAL DISTRICT',
      subtitle: 'Devraj Enterprises Cargo Depot & Warehouses',
      center: three.Vector3(62.0, 0, 0),
      radius: 35.0,
    ),
    WorldRegion.forest: RegionData(
      region: WorldRegion.forest,
      title: 'NORTHERN TEAK FOREST',
      subtitle: 'Secluded Hideouts & Mountain Paths',
      center: three.Vector3(0, 0, 72.0),
      radius: 40.0,
    ),
    WorldRegion.mainCity: RegionData(
      region: WorldRegion.mainCity,
      title: 'MAIN CITY COMMERCIAL',
      subtitle: 'Veyrapuram Central Avenue & Police Precinct',
      center: three.Vector3(0, 0, -70.0),
      radius: 40.0,
    ),
    WorldRegion.highway: RegionData(
      region: WorldRegion.highway,
      title: 'COASTAL HIGHWAY',
      subtitle: 'Corridor 4 to Port Veyrapuram',
      center: three.Vector3(0, 0, -140.0),
      radius: 40.0,
    ),
    WorldRegion.harbour: RegionData(
      region: WorldRegion.harbour,
      title: 'PORT VEYRAPURAM // BERTH 4',
      subtitle: 'Deepwater Docks & Contraband Shipping',
      center: three.Vector3(0, 0, -210.0),
      radius: 42.0,
    ),
    WorldRegion.sea: RegionData(
      region: WorldRegion.sea,
      title: 'ARABIAN SEA',
      subtitle: 'Coastal Waters & Distant Shipping Lanes',
      center: three.Vector3(0, 0, -280.0),
      radius: 50.0,
    ),
  };
}
