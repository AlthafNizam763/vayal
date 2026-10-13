import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/audio/audio_manager.dart';

/// Performance graphics quality preset.
enum GraphicsPreset {
  low, // 30 FPS target, 65m draw distance, no shadows, low simulation budget
  medium, // 60 FPS target, 95m draw distance, balanced LOD
  high, // 60 FPS target, 125m draw distance, full dynamic lights
  ultra, // 60+ FPS target, 180m draw distance, extended simulation
}

/// Unified Settings dialog for adjusting Audio mixer, Graphics performance presets,
/// and developer diagnostic overlays.
class SettingsDialog extends StatefulWidget {
  final AudioManager audioManager;
  final GraphicsPreset currentPreset;
  final bool showPerformanceHud;
  final ValueChanged<GraphicsPreset> onPresetChanged;
  final ValueChanged<bool> onPerformanceHudToggled;

  const SettingsDialog({
    super.key,
    required this.audioManager,
    required this.currentPreset,
    required this.showPerformanceHud,
    required this.onPresetChanged,
    required this.onPerformanceHudToggled,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _activeTab = 0; // 0 = Audio, 1 = Graphics & Performance
  late GraphicsPreset _selectedPreset;
  late bool _perfHudEnabled;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.currentPreset;
    _perfHudEnabled = widget.showPerformanceHud;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: math.min(580.0, MediaQuery.of(context).size.width * 0.9),
        height: math.min(500.0, MediaQuery.of(context).size.height * 0.86),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1116),
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
        child: Column(
          children: [
            // Header Bar & Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTabBtn('AUDIO MIXER', 0),
                      const SizedBox(width: 8.0),
                      _buildTabBtn('GRAPHICS & PERFORMANCE', 1),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _activeTab == 0 ? _buildAudioTab() : _buildGraphicsTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(String label, int index) {
    final active = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : Colors.white60,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAudioTab() {
    return AnimatedBuilder(
      animation: widget.audioManager,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MASTER BUSSES',
                  style: TextStyle(color: Colors.white54, fontSize: 11.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                TextButton.icon(
                  onPressed: () => widget.audioManager.toggleMute(),
                  icon: Icon(
                    widget.audioManager.isMuted ? Icons.volume_off : Icons.volume_up,
                    size: 16.0,
                    color: widget.audioManager.isMuted ? const Color(0xFFEF4444) : Colors.white70,
                  ),
                  label: Text(
                    widget.audioManager.isMuted ? 'UNMUTE ALL' : 'MUTE ALL',
                    style: TextStyle(
                      color: widget.audioManager.isMuted ? const Color(0xFFEF4444) : Colors.white70,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _buildSlider('MASTER VOLUME', widget.audioManager.masterVolume, (v) => widget.audioManager.masterVolume = v),
            const SizedBox(height: 8.0),
            _buildSlider('MUSIC THEME', widget.audioManager.musicVolume, (v) => widget.audioManager.musicVolume = v),
            const SizedBox(height: 8.0),
            _buildSlider('SOUND EFFECTS (SFX)', widget.audioManager.sfxVolume, (v) => widget.audioManager.sfxVolume = v),
            const SizedBox(height: 8.0),
            _buildSlider('ENVIRONMENT AMBIENCE', widget.audioManager.ambientVolume, (v) => widget.audioManager.ambientVolume = v),
          ],
        );
      },
    );
  }

  Widget _buildGraphicsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'PERFORMANCE PRESETS',
          style: TextStyle(color: Colors.white54, fontSize: 11.0, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: GraphicsPreset.values.map((preset) {
            final isSelected = _selectedPreset == preset;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedPreset = preset);
                  widget.onPresetChanged(preset);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD97736) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF9800) : Colors.white12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        preset.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        preset == GraphicsPreset.low
                            ? '30 FPS • 65m'
                            : (preset == GraphicsPreset.medium
                                ? '60 FPS • 95m'
                                : (preset == GraphicsPreset.high ? '60 FPS • 125m' : '60+ • 180m')),
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.white38,
                          fontSize: 10.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const Divider(color: Colors.white12, height: 32.0),

        // Debug Monitor Toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'PERFORMANCE METRICS HUD',
            style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w600, letterSpacing: 1.2),
          ),
          subtitle: const Text(
            'Real-time FPS, delta frame timing, visible chunks, and active simulated NPCs',
            style: TextStyle(color: Colors.white38, fontSize: 11.0),
          ),
          value: _perfHudEnabled,
          activeThumbColor: const Color(0xFF10B981),
          onChanged: (val) {
            setState(() => _perfHudEnabled = val);
            widget.onPerformanceHudToggled(val);
          },
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.0, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            Text('${(val * 100).toInt()}%', style: const TextStyle(color: Colors.white38, fontSize: 11.0)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
          ),
          child: Slider(
            value: val,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
