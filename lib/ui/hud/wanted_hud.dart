import 'package:flutter/material.dart';
import '../../game/systems/wanted_system.dart';

/// Top-mounted Wanted Stars indicator for Veyrapuram.
/// Renders 5 noir-styled stars with amber/crimson filling,
/// pulsing animation during evasion cooldown, and crime status banner.
class WantedHud extends StatefulWidget {
  final WantedSystem wantedSystem;

  const WantedHud({
    super.key,
    required this.wantedSystem,
  });

  @override
  State<WantedHud> createState() => _WantedHudState();
}

class _WantedHudState extends State<WantedHud> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wantedLevel = widget.wantedSystem.wantedLevel;
    if (wantedLevel <= 0) return const SizedBox.shrink();

    final isEvading = widget.wantedSystem.isEvading;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final opacity = isEvading ? _pulseAnimation.value : 1.0;

        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115).withAlpha(220),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEvading
                    ? const Color(0xFFD97736).withAlpha(180)
                    : const Color(0xFFE53935).withAlpha(220),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isEvading ? const Color(0xFFD97736) : const Color(0xFFE53935))
                      .withAlpha(80),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isFilled = starIndex <= wantedLevel;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        size: 20,
                        color: isFilled
                            ? (wantedLevel >= 4
                                ? const Color(0xFFEF5350)
                                : const Color(0xFFFFB300))
                            : const Color(0xFF4A5568),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 2),
                Text(
                  isEvading
                      ? 'EVADING POLICE (${widget.wantedSystem.evasionTimer.ceil()}s)'
                      : (wantedLevel >= 3 ? 'POLICE DISPATCH IN PURSUIT' : 'WANTED - OFFICER ALERT'),
                  style: TextStyle(
                    color: isEvading ? const Color(0xFFFFB300) : const Color(0xFFEF5350),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
