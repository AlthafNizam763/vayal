import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import '../../game/world/world_region.dart';
import '../../game/world/map_poi.dart';

/// Full interactive 2D tactical open-world map of Veyrapuram with
/// pan/zoom (InteractiveViewer), custom destination waypoint tapping,
/// category filters, and detailed POI markers.
class WorldMapScreen extends StatefulWidget {
  final three.Vector3 playerPosition;
  final double playerRotationY;
  final three.Vector3? vehiclePosition;
  final three.Vector3? missionWaypoint;
  final String? missionTitle;
  final three.Vector3? customWaypoint;
  final ValueChanged<three.Vector3?>? onSetCustomWaypoint;
  final WorldRegion currentRegion;
  final VoidCallback onClose;

  const WorldMapScreen({
    super.key,
    required this.playerPosition,
    required this.playerRotationY,
    this.vehiclePosition,
    this.missionWaypoint,
    this.missionTitle,
    this.customWaypoint,
    this.onSetCustomWaypoint,
    required this.currentRegion,
    required this.onClose,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  late WorldRegion _selectedRegion;
  three.Vector3? _customWaypoint;
  PoiCategory? _activeCategoryFilter; // null means "All"
  MapPoi? _selectedPoi;
  final TransformationController _transformController = TransformationController();

  static const double _mapCanvasWidth = 900.0;
  static const double _mapCanvasHeight = 900.0;
  static const double _mapScale = 1.1;

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.currentRegion;
    _customWaypoint = widget.customWaypoint;
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _recenterOnPlayer() {
    final cx = _mapCanvasWidth / 2;
    final cy = _mapCanvasHeight / 2;
    final canvasX = cx + (widget.playerPosition.x * _mapScale);
    final canvasY = cy - (widget.playerPosition.z * _mapScale) - 30.0;

    // Center canvas in viewport (assume viewport ~ 600x600)
    final tx = 300.0 - canvasX;
    final ty = 300.0 - canvasY;

    final matrix = Matrix4.identity();
    matrix.storage[0] = 1.2;
    matrix.storage[5] = 1.2;
    matrix.storage[12] = tx * 0.5;
    matrix.storage[13] = ty * 0.5;
    _transformController.value = matrix;
  }

  void _handleMapTap(TapUpDetails details) {
    final localPos = details.localPosition;
    final cx = _mapCanvasWidth / 2;
    final cy = _mapCanvasHeight / 2;

    // Convert local canvas position back to world coordinates
    final worldX = (localPos.dx - cx) / _mapScale;
    final worldZ = (cy - 30.0 - localPos.dy) / _mapScale;

    final tappedPoint = three.Vector3(worldX, 0.0, worldZ);

    // If tapped very close to existing waypoint, clear it
    if (_customWaypoint != null) {
      final dist = math.sqrt(
        math.pow(_customWaypoint!.x - worldX, 2) + math.pow(_customWaypoint!.z - worldZ, 2),
      );
      if (dist < 15.0) {
        setState(() {
          _customWaypoint = null;
        });
        widget.onSetCustomWaypoint?.call(null);
        return;
      }
    }

    // Check if clicked close to an existing POI
    MapPoi? clickedPoi;
    for (final poi in MapPoi.defaultPois) {
      final pDist = math.sqrt(
        math.pow(poi.position.x - worldX, 2) + math.pow(poi.position.z - worldZ, 2),
      );
      if (pDist < 12.0) {
        clickedPoi = poi;
        break;
      }
    }

    setState(() {
      _selectedPoi = clickedPoi;
      _customWaypoint = tappedPoint;
    });
    widget.onSetCustomWaypoint?.call(_customWaypoint);
  }

  double _calcDistance(three.Vector3 target) {
    return math.sqrt(
      math.pow(widget.playerPosition.x - target.x, 2) +
          math.pow(widget.playerPosition.z - target.z, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regData = RegionData.registry[_selectedRegion]!;
    final filteredPois = _activeCategoryFilter == null
        ? MapPoi.defaultPois
        : MapPoi.defaultPois.where((p) => p.category == _activeCategoryFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090B0E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: const BoxDecoration(
                color: Color(0xFF10141D),
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.explore_outlined, color: Color(0xFFD97736), size: 22.0),
                  const SizedBox(width: 8.0),
                  const Text(
                    'VEYRAPURAM TACTICAL MAP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  // Coordinates badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      'X: ${widget.playerPosition.x.toStringAsFixed(1)} • Z: ${widget.playerPosition.z.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.0,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Quick Action: Recenter
                  TextButton.icon(
                    icon: const Icon(Icons.my_location_rounded, size: 16.0, color: Color(0xFF10B981)),
                    label: const Text('RECENTER', style: TextStyle(color: Color(0xFF10B981), fontSize: 11.0)),
                    onPressed: _recenterOnPlayer,
                  ),
                  const SizedBox(width: 6.0),

                  // Quick Action: Clear Waypoint
                  if (_customWaypoint != null)
                    TextButton.icon(
                      icon: const Icon(Icons.clear_rounded, size: 16.0, color: Color(0xFFEF4444)),
                      label: const Text('CLEAR PIN', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11.0)),
                      onPressed: () {
                        setState(() {
                          _customWaypoint = null;
                        });
                        widget.onSetCustomWaypoint?.call(null);
                      },
                    ),

                  const SizedBox(width: 10.0),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Category Filter Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              color: const Color(0xFF141924),
              child: Row(
                children: [
                  const Text(
                    'POI FILTERS:',
                    style: TextStyle(color: Colors.white54, fontSize: 10.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(width: 10.0),
                  _buildFilterChip('ALL', null),
                  const SizedBox(width: 6.0),
                  _buildFilterChip('SAFEHOUSE', PoiCategory.safehouse),
                  const SizedBox(width: 6.0),
                  _buildFilterChip('SHOPS', PoiCategory.shop),
                  const SizedBox(width: 6.0),
                  _buildFilterChip('NPCS', PoiCategory.npc),
                  const SizedBox(width: 6.0),
                  _buildFilterChip('LANDMARKS', PoiCategory.landmark),
                  const Spacer(),
                  const Text(
                    'TIP: Tap map to place custom waypoint pin',
                    style: TextStyle(color: Colors.white38, fontSize: 10.0, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            // Main Map Body & Inspector Sidebar
            Expanded(
              child: Row(
                children: [
                  // Vector Interactive Map Canvas
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F131B),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: InteractiveViewer(
                            transformationController: _transformController,
                            minScale: 0.6,
                            maxScale: 3.5,
                            boundaryMargin: const EdgeInsets.all(350.0),
                            child: GestureDetector(
                              onTapUp: _handleMapTap,
                              child: CustomPaint(
                                size: const Size(_mapCanvasWidth, _mapCanvasHeight),
                                painter: _VeyrapuramMapPainter(
                                  playerPosition: widget.playerPosition,
                                  playerRotationY: widget.playerRotationY,
                                  vehiclePosition: widget.vehiclePosition,
                                  missionWaypoint: widget.missionWaypoint,
                                  customWaypoint: _customWaypoint,
                                  selectedRegion: _selectedRegion,
                                  pois: filteredPois,
                                  scale: _mapScale,
                                  canvasWidth: _mapCanvasWidth,
                                  canvasHeight: _mapCanvasHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // District & POI Inspector Sidebar
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.only(top: 12.0, bottom: 12.0, right: 12.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131822),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // District Header
                          const Text(
                            'DISTRICT DOSSIER',
                            style: TextStyle(
                              color: Color(0xFFD97736),
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            regData.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            regData.subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          // District Selector Chips
                          Wrap(
                            spacing: 5.0,
                            runSpacing: 5.0,
                            children: WorldRegion.values.map((r) {
                              final isSelected = r == _selectedRegion;
                              final meta = RegionData.registry[r]!;
                              return ChoiceChip(
                                label: Text(meta.title, style: const TextStyle(fontSize: 9.5)),
                                selected: isSelected,
                                selectedColor: const Color(0xFFD97736),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) {
                                  setState(() => _selectedRegion = r);
                                },
                              );
                            }).toList(),
                          ),

                          const Divider(color: Colors.white12, height: 24.0),

                          // Selected POI or Selected Custom Waypoint Card
                          if (_selectedPoi != null)
                            _buildPoiCard(_selectedPoi!)
                          else if (_customWaypoint != null)
                            _buildCustomWaypointCard()
                          else
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'POI INSPECTION',
                                    style: TextStyle(color: Colors.white54, fontSize: 10.0, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Tap any icon on the map to inspect POI details or tap anywhere to place a custom waypoint beacon.',
                                    style: TextStyle(color: Colors.white38, fontSize: 11.0),
                                  ),
                                ],
                              ),
                            ),

                          const Spacer(),

                          // Active Story Objective Waypoint Card
                          if (widget.missionTitle != null && widget.missionWaypoint != null)
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_rounded, color: Color(0xFFEF4444), size: 20.0),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'STORY OBJECTIVE',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          widget.missionTitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${_calcDistance(widget.missionWaypoint!).toStringAsFixed(0)}m',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, PoiCategory? category) {
    final isSelected = _activeCategoryFilter == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCategoryFilter = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD97736) : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: isSelected ? const Color(0xFFD97736) : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPoiCard(MapPoi poi) {
    final dist = _calcDistance(poi.position);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: poi.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: poi.color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(poi.icon, color: poi.color, size: 20.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  poi.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${dist.toStringAsFixed(0)}m',
                style: TextStyle(color: poi.color, fontSize: 11.0, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            poi.subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 11.0),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: poi.color,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(30.0),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.navigation_rounded, size: 14.0),
            label: const Text('SET DESTINATION PIN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                _customWaypoint = poi.position;
              });
              widget.onSetCustomWaypoint?.call(_customWaypoint);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomWaypointCard() {
    final dist = _calcDistance(_customWaypoint!);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_rounded, color: Color(0xFFF59E0B), size: 20.0),
              const SizedBox(width: 8.0),
              const Expanded(
                child: Text(
                  'CUSTOM DESTINATION',
                  style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${dist.toStringAsFixed(0)}m',
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11.0, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Text(
            'GPS Coordinates: X: ${_customWaypoint!.x.toStringAsFixed(1)}, Z: ${_customWaypoint!.z.toStringAsFixed(1)}',
            style: const TextStyle(color: Colors.white70, fontSize: 11.0, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10.0),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              minimumSize: const Size.fromHeight(30.0),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 14.0),
            label: const Text('REMOVE DESTINATION PIN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() {
                _customWaypoint = null;
              });
              widget.onSetCustomWaypoint?.call(null);
            },
          ),
        ],
      ),
    );
  }
}

class _VeyrapuramMapPainter extends CustomPainter {
  final three.Vector3 playerPosition;
  final double playerRotationY;
  final three.Vector3? vehiclePosition;
  final three.Vector3? missionWaypoint;
  final three.Vector3? customWaypoint;
  final WorldRegion selectedRegion;
  final List<MapPoi> pois;
  final double scale;
  final double canvasWidth;
  final double canvasHeight;

  _VeyrapuramMapPainter({
    required this.playerPosition,
    required this.playerRotationY,
    this.vehiclePosition,
    this.missionWaypoint,
    this.customWaypoint,
    required this.selectedRegion,
    required this.pois,
    required this.scale,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = canvasWidth / 2;
    final cy = canvasHeight / 2;

    Offset worldToCanvas(double x, double z) {
      return Offset(
        cx + (x * scale),
        cy - (z * scale) - 30.0,
      );
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double i = 0; i < canvasWidth; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, canvasHeight), gridPaint);
    }
    for (double i = 0; i < canvasHeight; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(canvasWidth, i), gridPaint);
    }

    // Connecting highway network
    final roadPaint = Paint()
      ..color = const Color(0xFF2C3545)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final pNorth = worldToCanvas(0, 100);
    final pVillage = worldToCanvas(0, 0);
    final pOldTown = worldToCanvas(-70, 0);
    final pIndustrial = worldToCanvas(70, 0);
    final pCity = worldToCanvas(0, -75);
    final pHighway = worldToCanvas(0, -140);
    final pHarbour = worldToCanvas(0, -215);
    final pSea = worldToCanvas(0, -280);

    canvas.drawLine(pNorth, pVillage, roadPaint);
    canvas.drawLine(pOldTown, pIndustrial, roadPaint);
    canvas.drawLine(pVillage, pCity, roadPaint);
    canvas.drawLine(pCity, pHighway, roadPaint);
    canvas.drawLine(pHighway, pHarbour, roadPaint);
    canvas.drawLine(pHarbour, pSea, roadPaint);

    // District boundary regions
    for (final entry in RegionData.registry.entries) {
      final reg = entry.key;
      final data = entry.value;
      final center = worldToCanvas(data.center.x, data.center.z);
      final r = data.radius * scale;

      final isSelected = reg == selectedRegion;

      final fillPaint = Paint()
        ..color = isSelected
            ? const Color(0xFFD97736).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.04)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? const Color(0xFFD97736) : Colors.white24
        ..strokeWidth = isSelected ? 2.0 : 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, r, fillPaint);
      canvas.drawCircle(center, r, borderPaint);

      // District Label
      final tp = TextPainter(
        text: TextSpan(
          text: data.title,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD97736) : Colors.white60,
            fontSize: 9.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx - (tp.width / 2), center.dy - 6));
    }

    // Draw POI markers
    for (final poi in pois) {
      final pPos = worldToCanvas(poi.position.x, poi.position.z);

      // Outer circle
      final poiBgPaint = Paint()
        ..color = poi.color.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, 11.0, poiBgPaint);

      // Inner dot
      final poiDotPaint = Paint()
        ..color = poi.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pPos, 5.0, poiDotPaint);

      // Small POI title
      final tp = TextPainter(
        text: TextSpan(
          text: poi.title,
          style: TextStyle(
            color: poi.color,
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pPos.dx - (tp.width / 2), pPos.dy + 8));
    }

    // Draw Custom Destination Pin Waypoint (Gold Beacon)
    if (customWaypoint != null) {
      final pCustom = worldToCanvas(customWaypoint!.x, customWaypoint!.z);
      final pulsePaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      final markPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;

      // Concentric beacon rings
      canvas.drawCircle(pCustom, 16.0, pulsePaint);
      canvas.drawCircle(pCustom, 7.0, markPaint);

      // Diamond marker on top
      final diamondPath = Path()
        ..moveTo(pCustom.dx, pCustom.dy - 12.0)
        ..lineTo(pCustom.dx + 5.0, pCustom.dy - 5.0)
        ..lineTo(pCustom.dx, pCustom.dy)
        ..lineTo(pCustom.dx - 5.0, pCustom.dy - 5.0)
        ..close();
      canvas.drawPath(diamondPath, markPaint);
    }

    // Draw Mission Objective Waypoint (Red Beacon)
    if (missionWaypoint != null) {
      final pMission = worldToCanvas(missionWaypoint!.x, missionWaypoint!.z);
      final pulsePaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      final markPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pMission, 16.0, pulsePaint);
      canvas.drawCircle(pMission, 6.0, markPaint);
    }

    // Draw Vehicle Marker
    if (vehiclePosition != null) {
      final pVeh = worldToCanvas(vehiclePosition!.x, vehiclePosition!.z);
      final vehPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromCenter(center: pVeh, width: 9, height: 9), vehPaint);
    }

    // Draw Player Marker (Arrow indicating facing direction)
    final pPlayer = worldToCanvas(playerPosition.x, playerPosition.z);
    final playerPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(pPlayer.dx, pPlayer.dy);
    canvas.rotate(-playerRotationY + math.pi);

    final path = Path()
      ..moveTo(0, -10)
      ..lineTo(7, 8)
      ..lineTo(0, 5)
      ..lineTo(-7, 8)
      ..close();
    canvas.drawPath(path, playerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VeyrapuramMapPainter oldDelegate) => true;
}
