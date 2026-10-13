import 'package:flutter/material.dart';
import '../../game/combat/combat_system.dart';

/// Weapon HUD displaying active weapon card, ammo counters, reload prompts,
/// and quick-slot loadout selector.
class WeaponHud extends StatelessWidget {
  final CombatSystem combatSystem;
  final ValueChanged<int>? onSelectSlot;
  final VoidCallback? onReload;

  const WeaponHud({
    super.key,
    required this.combatSystem,
    this.onSelectSlot,
    this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final weapon = combatSystem.equippedWeapon;
    final isReloading = combatSystem.isReloading;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF10141D).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFF333E50), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 12.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Quick Loadout Slot Selector (1, 2, 3, 4)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(combatSystem.weaponSlots.length, (index) {
              final w = combatSystem.weaponSlots[index];
              final isSelected = index == combatSystem.activeSlotIndex;
              return GestureDetector(
                onTap: () => onSelectSlot?.call(index),
                child: Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD97736)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF9800) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white60,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        w.hudIcon,
                        size: 13.0,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8.0),

          // Active Weapon Detail Card
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(weapon.hudIcon, color: const Color(0xFFD97736), size: 22.0),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    weapon.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (weapon.isFirearm) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${weapon.currentAmmo}',
                          style: TextStyle(
                            color: weapon.currentAmmo == 0
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF38BDF8),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          ' / ${weapon.reserveAmmo}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12.0,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'MELEE • ${weapon.damage.toInt()} DMG',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Reload Prompt / Progress
          if (weapon.isFirearm) ...[
            const SizedBox(height: 6.0),
            if (isReloading) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Text(
                  'RELOADING...',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ] else if (weapon.needsReload) ...[
              GestureDetector(
                onTap: onReload,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 11.0, color: Color(0xFFEF4444)),
                      SizedBox(width: 4.0),
                      Text(
                        'RELOAD [R]',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Tactical crosshair overlay when aiming or weapon is readied.
class CrosshairOverlay extends StatelessWidget {
  final bool isAiming;

  const CrosshairOverlay({
    super.key,
    required this.isAiming,
  });

  @override
  Widget build(BuildContext context) {
    final size = isAiming ? 18.0 : 28.0;
    final color = isAiming ? const Color(0xFFEF4444) : Colors.white70;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CrosshairPainter(color: color, isAiming: isAiming),
        ),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final Color color;
  final bool isAiming;

  _CrosshairPainter({required this.color, required this.isAiming});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = isAiming ? 2.0 : 1.5
      ..strokeCap = StrokeCap.round;

    final gap = isAiming ? 3.0 : 6.0;
    final lineLen = isAiming ? 5.0 : 7.0;

    // Top
    canvas.drawLine(Offset(cx, cy - gap), Offset(cx, cy - gap - lineLen), paint);
    // Bottom
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + gap + lineLen), paint);
    // Left
    canvas.drawLine(Offset(cx - gap, cy), Offset(cx - gap - lineLen, cy), paint);
    // Right
    canvas.drawLine(Offset(cx + gap, cy), Offset(cx + gap + lineLen, cy), paint);

    // Center dot if aiming
    if (isAiming) {
      canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isAiming != isAiming;
}
