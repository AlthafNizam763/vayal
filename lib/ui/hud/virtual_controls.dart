import 'package:flutter/material.dart';

/// Minimalist cinematic on-screen touch controls for mobile.
/// Supports both on-foot movement/combat and driving modes.
class VirtualControls extends StatefulWidget {
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onCameraDrag;
  final VoidCallback onJump;
  final ValueChanged<bool> onSprintToggle;
  final bool isSprinting;
  final VoidCallback? onInteract;
  final bool showInteractButton;

  // Combat controls (on foot)
  final VoidCallback? onLightAttack;
  final VoidCallback? onHeavyAttack;
  final ValueChanged<bool>? onBlockToggle;
  final bool isBlocking;

  // Vehicle driving mode
  final bool isDriving;
  final ValueChanged<double>? onThrottle;
  final VoidCallback? onExitVehicle;
  final VoidCallback? onHandbrake;

  const VirtualControls({
    super.key,
    required this.onMove,
    required this.onCameraDrag,
    required this.onJump,
    required this.onSprintToggle,
    required this.isSprinting,
    this.onInteract,
    this.showInteractButton = false,
    this.onLightAttack,
    this.onHeavyAttack,
    this.onBlockToggle,
    this.isBlocking = false,
    this.isDriving = false,
    this.onThrottle,
    this.onExitVehicle,
    this.onHandbrake,
  });

  @override
  State<VirtualControls> createState() => _VirtualControlsState();
}

class _VirtualControlsState extends State<VirtualControls> {
  // Joystick internal state
  Offset _joystickKnobOffset = Offset.zero;
  final double _joystickRadius = 55.0;

  void _updateJoystick(Offset localPosition, Offset center) {
    final delta = localPosition - center;
    final distance = delta.distance;

    if (distance <= _joystickRadius) {
      _joystickKnobOffset = delta;
    } else {
      _joystickKnobOffset = Offset.fromDirection(delta.direction, _joystickRadius);
    }

    final normalizedInput = Offset(
      _joystickKnobOffset.dx / _joystickRadius,
      -_joystickKnobOffset.dy / _joystickRadius,
    );

    widget.onMove(normalizedInput);
    setState(() {});
  }

  void _resetJoystick() {
    _joystickKnobOffset = Offset.zero;
    widget.onMove(Offset.zero);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Right-side touch surface for camera rotation (active on foot or driving)
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              height: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  widget.onCameraDrag(details.delta);
                },
              ),
            ),
          ),
        ),

        // 2. Bottom-left Virtual Joystick / Steering
        Positioned(
          left: 28,
          bottom: 28,
          child: SizedBox(
            width: _joystickRadius * 2 + 30,
            height: _joystickRadius * 2 + 30,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) => _updateJoystick(details.localPosition, center),
                  onPanUpdate: (details) => _updateJoystick(details.localPosition, center),
                  onPanEnd: (_) => _resetJoystick(),
                  onPanCancel: () => _resetJoystick(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _joystickRadius * 2,
                        height: _joystickRadius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF14181F).withAlpha(150),
                          border: Border.all(
                            color: const Color(0xFF384353).withAlpha(180),
                            width: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: _joystickRadius * 1.5,
                        color: Colors.white.withAlpha(20),
                      ),
                      Container(
                        width: _joystickRadius * 1.5,
                        height: 1,
                        color: Colors.white.withAlpha(20),
                      ),
                      Transform.translate(
                        offset: _joystickKnobOffset,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isDriving
                                ? const Color(0xFFD97736)
                                : const Color(0xFFE2E8F0),
                            border: Border.all(
                              color: const Color(0xFF1A202C),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: widget.isDriving
                              ? const Icon(Icons.directions_car, size: 20, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Action Buttons on Bottom-Right
        Positioned(
          right: 28,
          bottom: 28,
          child: widget.isDriving
              ? _buildDrivingButtons()
              : _buildFootAndCombatButtons(),
        ),
      ],
    );
  }

  /// Vehicle driving controls (Accelerate, Brake, Handbrake, Exit).
  Widget _buildDrivingButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Exit Vehicle button
        if (widget.onExitVehicle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: widget.onExitVehicle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB71C1C).withAlpha(220),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEF5350), width: 1.4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'EXIT CAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handbrake
            GestureDetector(
              onTap: widget.onHandbrake,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B222D).withAlpha(210),
                  border: Border.all(color: const Color(0xFF4C586A), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'DRIFT',
                    style: TextStyle(
                      color: Color(0xFFB0B9C6),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Reverse / Brake
            GestureDetector(
              onTapDown: (_) => widget.onThrottle?.call(-1.0),
              onTapUp: (_) => widget.onThrottle?.call(0.0),
              onTapCancel: () => widget.onThrottle?.call(0.0),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B2020).withAlpha(220),
                  border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                ),
                child: const Center(
                  child: Text(
                    'BRAKE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Drive / Gas
            GestureDetector(
              onTapDown: (_) => widget.onThrottle?.call(1.0),
              onTapUp: (_) => widget.onThrottle?.call(0.0),
              onTapCancel: () => widget.onThrottle?.call(0.0),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E7D32).withAlpha(230),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withAlpha(120),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'GAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// On-foot movement and combat action buttons.
  Widget _buildFootAndCombatButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top action: Interact prompt
        if (widget.showInteractButton && widget.onInteract != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: widget.onInteract,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97736).withAlpha(240),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(150),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'INTERACT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Combat row: Punch, Heavy, Block
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Block Guard
              if (widget.onBlockToggle != null)
                GestureDetector(
                  onTap: () => widget.onBlockToggle?.call(!widget.isBlocking),
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isBlocking
                          ? const Color(0xFF1976D2).withAlpha(230)
                          : const Color(0xFF161B22).withAlpha(180),
                      border: Border.all(
                        color: widget.isBlocking
                            ? const Color(0xFF64B5F6)
                            : const Color(0xFF3B4654),
                        width: 1.4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'BLOCK',
                        style: TextStyle(
                          color: widget.isBlocking ? Colors.white : const Color(0xFFB0B9C6),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

              // Heavy Attack
              if (widget.onHeavyAttack != null)
                GestureDetector(
                  onTap: widget.onHeavyAttack,
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B1E1E).withAlpha(200),
                      border: Border.all(color: const Color(0xFFD32F2F), width: 1.4),
                    ),
                    child: const Center(
                      child: Text(
                        'HEAVY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

              // Light Punch Combo
              if (widget.onLightAttack != null)
                GestureDetector(
                  onTap: widget.onLightAttack,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFBF360C).withAlpha(230),
                      border: Border.all(color: const Color(0xFFFF7043), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBF360C).withAlpha(100),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'PUNCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Movement row: Sprint & Jump
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sprint Toggle
            GestureDetector(
              onTap: () {
                widget.onSprintToggle(!widget.isSprinting);
              },
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSprinting
                      ? const Color(0xFFD97736).withAlpha(220)
                      : const Color(0xFF161B22).withAlpha(180),
                  border: Border.all(
                    color: widget.isSprinting
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF3B4654),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'SPRINT',
                    style: TextStyle(
                      color: widget.isSprinting ? Colors.white : const Color(0xFFB0B9C6),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            // Jump Button
            GestureDetector(
              onTap: widget.onJump,
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF161B22).withAlpha(220),
                  border: Border.all(
                    color: const Color(0xFF4C586A),
                    width: 1.8,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'JUMP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
