import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;

/// Category of points of interest on the Veyrapuram map.
enum PoiCategory {
  safehouse,
  shop,
  npc,
  landmark,
  mission,
  customWaypoint,
}

/// Point of Interest marker on the world map.
class MapPoi {
  final String id;
  final String title;
  final String subtitle;
  final PoiCategory category;
  final three.Vector3 position;
  final IconData icon;
  final Color color;

  const MapPoi({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.position,
    required this.icon,
    required this.color,
  });

  /// Default registry of static POIs across Veyrapuram.
  static final List<MapPoi> defaultPois = [
    // Safehouse
    MapPoi(
      id: 'poi_safehouse',
      title: 'Menon Ancestral Home',
      subtitle: 'Primary Safehouse • Bed & Stash',
      category: PoiCategory.safehouse,
      position: three.Vector3(-16.0, 0.0, -8.0),
      icon: Icons.home_rounded,
      color: const Color(0xFF10B981),
    ),

    // Shops
    MapPoi(
      id: 'poi_shop_chai',
      title: "Balan's Chai Stall",
      subtitle: 'Village Crossroads • Provisions & Rumours',
      category: PoiCategory.shop,
      position: three.Vector3(12.0, 0.0, 7.5),
      icon: Icons.local_cafe_rounded,
      color: const Color(0xFFF59E0B),
    ),
    MapPoi(
      id: 'poi_shop_store',
      title: 'Veyrapuram Provisions',
      subtitle: 'General Store • Supplies & Tools',
      category: PoiCategory.shop,
      position: three.Vector3(12.0, 0.0, -2.0),
      icon: Icons.store_mall_directory_rounded,
      color: const Color(0xFFF59E0B),
    ),
    MapPoi(
      id: 'poi_shop_garage',
      title: "Kumaran's Auto Works",
      subtitle: 'Old Town Garage • Repairs & Upgrades',
      category: PoiCategory.shop,
      position: three.Vector3(-55.0, 0.0, 0.0),
      icon: Icons.build_rounded,
      color: const Color(0xFFF59E0B),
    ),
    MapPoi(
      id: 'poi_shop_harbour_market',
      title: 'Harbour Fish Market',
      subtitle: 'Berth 2 • Port Supplies & Fresh Catch',
      category: PoiCategory.shop,
      position: three.Vector3(25.0, 0.0, -210.0),
      icon: Icons.shopping_basket_rounded,
      color: const Color(0xFFF59E0B),
    ),

    // NPCs
    MapPoi(
      id: 'poi_npc_meera',
      title: 'Meera (Wife)',
      subtitle: 'Menon Verandah • Family Anchor',
      category: PoiCategory.npc,
      position: three.Vector3(-15.0, 0.0, -8.5),
      icon: Icons.person_pin_circle_rounded,
      color: const Color(0xFFEC4899),
    ),
    MapPoi(
      id: 'poi_npc_diya',
      title: 'Diya (Sister)',
      subtitle: 'Village Coconut Grove • Side Quest Contact',
      category: PoiCategory.npc,
      position: three.Vector3(-12.0, 0.0, -6.0),
      icon: Icons.person_rounded,
      color: const Color(0xFFA855F7),
    ),
    MapPoi(
      id: 'poi_npc_kumaran',
      title: 'Kumaran (Old Mechanic)',
      subtitle: 'Old Town Alley • Side Quest Contact',
      category: PoiCategory.npc,
      position: three.Vector3(-58.0, 0.0, 2.0),
      icon: Icons.car_repair_rounded,
      color: const Color(0xFF38BDF8),
    ),
    MapPoi(
      id: 'poi_npc_mohan',
      title: 'Mohan (Dock Worker)',
      subtitle: 'Port Berth 4 • Port Union Representative',
      category: PoiCategory.npc,
      position: three.Vector3(0.0, 0.0, -205.0),
      icon: Icons.anchor_rounded,
      color: const Color(0xFF06B6D4),
    ),
    MapPoi(
      id: 'poi_npc_rahu',
      title: 'Rahu (Childhood Friend)',
      subtitle: 'National Highway Diner • Confidant',
      category: PoiCategory.npc,
      position: three.Vector3(10.0, 0.0, -135.0),
      icon: Icons.connect_without_contact_rounded,
      color: const Color(0xFF6366F1),
    ),

    // Landmarks / Discovered Locations
    MapPoi(
      id: 'poi_landmark_vayal',
      title: 'Veyrapuram Paddy Fields (Vayal)',
      subtitle: 'Ancestral Farmlands • Heart of the Dispute',
      category: PoiCategory.landmark,
      position: three.Vector3(0.0, 0.0, 30.0),
      icon: Icons.grass_rounded,
      color: const Color(0xFF84CC16),
    ),
    MapPoi(
      id: 'poi_landmark_church',
      title: 'St. George Old Church',
      subtitle: 'Old Town Heritage • Portuguese Stone Belltower',
      category: PoiCategory.landmark,
      position: three.Vector3(-72.0, 0.0, -18.0),
      icon: Icons.church_rounded,
      color: const Color(0xFF94A3B8),
    ),
    MapPoi(
      id: 'poi_landmark_checkpoint',
      title: 'Veyrapuram Police Checkpoint',
      subtitle: 'Central Highway Barrier • Heavy Patrol Zone',
      category: PoiCategory.landmark,
      position: three.Vector3(0.0, 0.0, -65.0),
      icon: Icons.security_rounded,
      color: const Color(0xFFEF4444),
    ),
    MapPoi(
      id: 'poi_landmark_quarry',
      title: 'Syndicate Industrial Quarry',
      subtitle: 'Eastern Hills • Heavy Machinery & Smuggling',
      category: PoiCategory.landmark,
      position: three.Vector3(80.0, 0.0, -35.0),
      icon: Icons.factory_rounded,
      color: const Color(0xFFF97316),
    ),
    MapPoi(
      id: 'poi_landmark_port',
      title: 'Port Veyrapuram Berth 4',
      subtitle: 'Deepwater Docks • Container Terminals',
      category: PoiCategory.landmark,
      position: three.Vector3(0.0, 0.0, -220.0),
      icon: Icons.directions_boat_rounded,
      color: const Color(0xFF0284C7),
    ),
  ];
}
