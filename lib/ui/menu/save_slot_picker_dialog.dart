import 'package:flutter/material.dart';
import '../../game/save/save_data.dart';

/// Slot chooser shown at the main menu when continuing or loading.
/// Only lists valid, deserializable saves. Tap to start the game at that slot.
class SaveSlotPickerDialog extends StatelessWidget {
  final List<SaveSlotMetadata> slots;
  final ValueChanged<int> onSlotSelected;

  const SaveSlotPickerDialog({
    super.key,
    required this.slots,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<SaveSlotMetadata>.from(slots)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Dialog(
      backgroundColor: const Color(0xFF141820),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF2C3540)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'SELECT SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: sorted
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _slotButton(context, s),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Color(0xFF8B95A2),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slotButton(BuildContext context, SaveSlotMetadata s) {
    String source;
    Color chip;
    if (s.isCheckpoint) {
      source = 'CHECKPOINT';
      chip = const Color(0xFF81C784);
    } else if (s.isAutosave) {
      source = 'AUTOSAVE';
      chip = const Color(0xFF38BDF8);
    } else {
      source = 'MANUAL';
      chip = const Color(0xFFD97736);
    }

    return InkWell(
      onTap: () => onSlotSelected(s.slotId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF2C3540)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    s.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  source,
                  style: TextStyle(
                    color: chip,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${s.actTitle}  •  ${s.regionName}  •  ₹${s.money}',
              style: const TextStyle(
                color: Color(0xFF8B95A2),
                fontSize: 10.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatPlaytime(s.playTimeSeconds),
              style: const TextStyle(
                color: Color(0xFF5E6B5C),
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPlaytime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return 'Playtime: ${h}h ${m}m';
    return 'Playtime: ${m}m';
  }
}
