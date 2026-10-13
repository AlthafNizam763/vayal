import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/infiltration/lock_data.dart';
import '../../game/infiltration/lockpicking_session.dart';

/// Full interactive Lockpicking & Infiltration Mini-Game Dialog.
/// Features interactive pick positioning, tension torque resistance,
/// visual pin strain vibration, and silent entry resolution.
class LockpickingDialog extends StatefulWidget {
  final LockData lock;
  final int initialPicks;
  final void Function(LockData lock, int picksRemaining)? onUnlocked;
  final void Function(int picksRemaining)? onClosed;

  const LockpickingDialog({
    super.key,
    required this.lock,
    this.initialPicks = 5,
    this.onUnlocked,
    this.onClosed,
  });

  @override
  State<LockpickingDialog> createState() => _LockpickingDialogState();
}

class _LockpickingDialogState extends State<LockpickingDialog> {
  late final LockpickingSession session;
  Timer? _loopTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    session = LockpickingSession(
      lock: widget.lock,
      picksRemaining: widget.initialPicks,
    );

    session.onLockOpened = () {
      if (mounted) {
        setState(() {});
        widget.onUnlocked?.call(widget.lock, session.picksRemaining);
      }
    };

    session.onPickBroke = () {
      if (mounted) {
        setState(() {});
      }
    };

    // 60 FPS physics tick
    _loopTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) {
        setState(() {
          session.update(0.016);
        });
      }
    });
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(LockDifficulty difficulty) {
    switch (difficulty) {
      case LockDifficulty.easy:
        return const Color(0xFF2EA043);
      case LockDifficulty.medium:
        return const Color(0xFF388BFD);
      case LockDifficulty.hard:
        return const Color(0xFFE3B341);
      case LockDifficulty.master:
        return const Color(0xFFFF3344);
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (session.isUnlocked || session.picksRemaining <= 0) return;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.keyA) {
        session.setPickAngle(session.pickAngle - 4.0);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.keyD) {
        session.setPickAngle(session.pickAngle + 4.0);
      } else if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyF) {
        session.startTurning();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.keyF) {
        session.stopTurning();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(widget.lock.difficulty);
    final isOut = session.picksRemaining <= 0 && !session.isUnlocked;

    // Pick vibration when straining against resistance
    final jitter = session.stress > 15.0
        ? (math.Random().nextDouble() - 0.5) * (session.stress / 20.0)
        : 0.0;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFA0D1117), // Rich dark slate
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header with Lock Target & Difficulty Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Color(0xFFD4AF37), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.lock.name.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE6EDF3),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: diffColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: diffColor, width: 1.2),
                    ),
                    child: Text(
                      widget.lock.difficulty.name.toUpperCase(),
                      style: TextStyle(
                        color: diffColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Interactive Lock Mechanism Core
              Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF161B22),
                  border: Border.all(color: const Color(0xFF484F58), width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x66000000), blurRadius: 16),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Brass Cylinder Housing
                    Transform.rotate(
                      angle: (session.cylinderAngle * math.pi) / 180.0,
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF8A6D3B), // Aged Brass
                              const Color(0xFF4B381C),
                            ],
                          ),
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        ),
                        child: Center(
                          // Keyhole slot
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0D1117),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 28,
                                color: const Color(0xFF0D1117),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tension Wrench indicator at bottom
                    Positioned(
                      bottom: 24,
                      child: Transform.rotate(
                        angle: (session.cylinderAngle * math.pi) / 180.0,
                        child: Container(
                          width: 6,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0C0C0), // Silver tension bar
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),

                    // Bobby Pin Pick Needle
                    Transform.rotate(
                      angle: ((session.pickAngle - 90.0 + jitter) * math.pi) / 180.0,
                      child: Container(
                        width: 4,
                        height: 130,
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 4,
                          height: 75,
                          decoration: BoxDecoration(
                            color: session.isPickBroken
                                ? const Color(0xFFFF3344)
                                : const Color(0xFFE6EDF3),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              if (session.stress > 25)
                                BoxShadow(
                                  color: session.stress > 70
                                      ? const Color(0xFFFF2233)
                                      : const Color(0xFFE3B341),
                                  blurRadius: 8,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Pick Durability & Strain Gauge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.build_circle_outlined,
                            size: 14,
                            color: session.stress > 70
                                ? const Color(0xFFFF3344)
                                : const Color(0xFF8B949E),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            session.isPickBroken ? 'LOCKPICK SNAPPED!' : 'PICK STRESS',
                            style: TextStyle(
                              color: session.isPickBroken
                                  ? const Color(0xFFFF4455)
                                  : (session.stress > 70 ? const Color(0xFFFF3344) : const Color(0xFF8B949E)),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'PICKS: ${session.picksRemaining}',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: session.stress / 100.0,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF21262D),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        session.stress > 70
                            ? const Color(0xFFFF3344)
                            : (session.stress > 35 ? const Color(0xFFE3B341) : const Color(0xFF388BFD)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Angular Arc Slider Controller
              if (!session.isUnlocked && !isOut) ...[
                Row(
                  children: [
                    const Text('0°', style: TextStyle(color: Color(0xFF8B949E), fontSize: 10)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFFD4AF37),
                          inactiveTrackColor: const Color(0xFF21262D),
                          thumbColor: const Color(0xFFE6EDF3),
                          overlayColor: const Color(0x33D4AF37),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        ),
                        child: Slider(
                          value: session.pickAngle,
                          min: 0.0,
                          max: 180.0,
                          onChanged: (val) {
                            setState(() => session.setPickAngle(val));
                          },
                        ),
                      ),
                    ),
                    const Text('180°', style: TextStyle(color: Color(0xFF8B949E), fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // 5. Result Banner or Tension Turning Button
              if (session.isUnlocked) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xDD0D2818),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2EA043)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open_rounded, color: Color(0xFF3FB950), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'LOCK OPENED SILENTLY!',
                            style: TextStyle(
                              color: Color(0xFF3FB950),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (widget.lock.rewardMoney > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+₹${widget.lock.rewardMoney} LOOT FOUND',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      widget.onClosed?.call(session.picksRemaining);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF238636),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('PROCEED', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else if (isOut) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xDD3A0A0E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF2233)),
                  ),
                  child: const Center(
                    child: Text(
                      'ALL LOCKPICKS BROKEN!',
                      style: TextStyle(
                        color: Color(0xFFFF4455),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      widget.onClosed?.call(session.picksRemaining);
                    },
                    child: const Text('ABORT'),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTapDown: (_) => session.startTurning(),
                        onTapUp: (_) => session.stopTurning(),
                        onTapCancel: () => session.stopTurning(),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.rotate_right, size: 18),
                          label: const Text(
                            'TURN WRENCH (HOLD SPACE)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21262D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFF8B949E), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          widget.onClosed?.call(session.picksRemaining);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('CANCEL', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
