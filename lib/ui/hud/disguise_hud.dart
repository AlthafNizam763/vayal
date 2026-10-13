import 'package:flutter/material.dart';
import '../../game/disguise/disguise_manager.dart';

/// HUD Overlay displaying current disguise uniform, restricted zone trespassing banners,
/// social blending status, and identity scrutiny meters.
class DisguiseHudOverlay extends StatelessWidget {
  final DisguiseManager disguiseManager;
  final VoidCallback? onToggleBlend;

  const DisguiseHudOverlay({
    super.key,
    required this.disguiseManager,
    this.onToggleBlend,
  });

  @override
  Widget build(BuildContext context) {
    final currentDisguise = disguiseManager.currentDisguise;
    final isTrespassing = disguiseManager.isTrespassing;
    final isBlending = disguiseManager.isBlending;
    final isBlown = disguiseManager.isDisguiseBlown;
    final compromise = disguiseManager.disguiseCompromise;
    final activeZone = disguiseManager.activeRestrictedZone;
    final blendSpot = disguiseManager.currentBlendSpot;

    return Stack(
      children: [
        // 1. Trespassing Warning Banner (Top Center)
        if (isTrespassing)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xDD8B0000), // Dark blood red
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFF3333), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FF1111),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'RESTRICTED ZONE: ${activeZone?.name.toUpperCase() ?? "RESTRICTED"} (TRESPASSING)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Disguise Badge & Scrutiny Meter (Top Left under Region/Wanted)
        Positioned(
          top: 72,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xCC0D1117),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBlown
                    ? const Color(0xFFFF2233)
                    : (compromise > 0.3 ? const Color(0xFFE3B341) : const Color(0xFF388BFD)),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isBlown
                      ? Icons.no_accounts
                      : Icons.assignment_ind_outlined,
                  color: isBlown
                      ? const Color(0xFFFF3344)
                      : (compromise > 0.3 ? const Color(0xFFE3B341) : const Color(0xFF58A6FF)),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBlown ? 'COVER BLOWN!' : currentDisguise.name.toUpperCase(),
                      style: TextStyle(
                        color: isBlown ? const Color(0xFFFF4455) : const Color(0xFFE6EDF3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (compromise > 0.05 && !isBlown) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'SCRUTINY: ${(compromise * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFE3B341),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 50,
                            height: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: compromise,
                                backgroundColor: const Color(0xFF21262D),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  compromise > 0.7 ? const Color(0xFFFF3344) : const Color(0xFFE3B341),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // 3. Social Blending Status & Contextual Prompt
        if (isBlending && blendSpot != null)
          Positioned(
            bottom: 165,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xDD0D2818),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2EA043), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF3FB950), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'BLENDING: ${blendSpot.blendAction.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF3FB950),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (blendSpot != null && !isBlending)
          Positioned(
            bottom: 165,
            left: 20,
            child: GestureDetector(
              onTap: onToggleBlend,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xCC161B22),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8B949E), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_outlined, color: Color(0xFFC9D1D9), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '[B] BLEND IN: ${blendSpot.name}',
                      style: const TextStyle(
                        color: Color(0xFFC9D1D9),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
