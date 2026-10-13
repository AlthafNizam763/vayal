import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/audio/audio_event.dart';
import '../../game/audio/audio_manager.dart';

/// Modal dialog for adjusting audio levels and testing sound effects.
class AudioSettingsDialog extends StatefulWidget {
  final AudioManager audioManager;

  const AudioSettingsDialog({
    super.key,
    required this.audioManager,
  });

  @override
  State<AudioSettingsDialog> createState() => _AudioSettingsDialogState();
}

class _AudioSettingsDialogState extends State<AudioSettingsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: AnimatedBuilder(
        animation: widget.audioManager,
        builder: (context, _) {
          return Container(
            width: math.min(500.0, MediaQuery.of(context).size.width * 0.9),
            constraints: BoxConstraints(
              maxHeight: math.min(560.0, MediaQuery.of(context).size.height * 0.86),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.white24, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 24.0,
                  spreadRadius: 6.0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.volume_up, color: Colors.white70, size: 24.0),
                        SizedBox(width: 10.0),
                        Text(
                          'AUDIO MIXER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.audioManager.isMuted ? Icons.volume_off : Icons.volume_up,
                            color: widget.audioManager.isMuted ? const Color(0xFFEF4444) : Colors.white70,
                          ),
                          onPressed: () => widget.audioManager.toggleMute(),
                          tooltip: 'Toggle Mute',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(color: Colors.white12, height: 24.0),

                // Volume Sliders
                _buildSlider(
                  'MASTER VOLUME',
                  widget.audioManager.masterVolume,
                  (v) => widget.audioManager.masterVolume = v,
                ),
                const SizedBox(height: 12.0),
                _buildSlider(
                  'MUSIC VOLUME',
                  widget.audioManager.musicVolume,
                  (v) => widget.audioManager.musicVolume = v,
                ),
                const SizedBox(height: 12.0),
                _buildSlider(
                  'SFX VOLUME',
                  widget.audioManager.sfxVolume,
                  (v) => widget.audioManager.sfxVolume = v,
                ),
                const SizedBox(height: 12.0),
                _buildSlider(
                  'AMBIENCE VOLUME',
                  widget.audioManager.ambientVolume,
                  (v) => widget.audioManager.ambientVolume = v,
                ),

                const SizedBox(height: 20.0),
                const Text(
                  'TEST AUDIO CHANNELS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10.0),

                // Sound trigger test buttons
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildTestButton('FOOTSTEP', () {
                      widget.audioManager.playFootstep(isSprinting: false);
                    }),
                    _buildTestButton('HORN', () {
                      widget.audioManager.playVehicleSfx(AudioEvent.vehicleHorn);
                    }),
                    _buildTestButton('PUNCH', () {
                      widget.audioManager.playCombatSfx(AudioEvent.combatPunchHeavy);
                    }),
                    _buildTestButton('CHIME', () {
                      widget.audioManager.playUi(AudioEvent.missionObjectiveTick);
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTestButton(String title, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 11.0, letterSpacing: 1.2),
      ),
    );
  }
}
