import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/save/save_data.dart';
import '../../game/save/save_manager.dart';

/// Modal dialog for saving and loading games across offline slots.
class SaveLoadDialog extends StatefulWidget {
  final SaveManager saveManager;
  final bool isSaveMode; // true = Save, false = Load
  final Future<void> Function(int slotId)? onSaveRequested;
  final Future<void> Function(int slotId)? onLoadRequested;

  const SaveLoadDialog({
    super.key,
    required this.saveManager,
    this.isSaveMode = true,
    this.onSaveRequested,
    this.onLoadRequested,
  });

  @override
  State<SaveLoadDialog> createState() => _SaveLoadDialogState();
}

class _SaveLoadDialogState extends State<SaveLoadDialog> {
  late bool _saveMode;
  List<SaveSlotMetadata> _slots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _saveMode = widget.isSaveMode;
    _refreshSlots();
  }

  Future<void> _refreshSlots() async {
    setState(() => _isLoading = true);
    final slots = await widget.saveManager.listSaveSlots();
    if (mounted) {
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    }
  }

  SaveSlotMetadata? _getMetaForSlot(int slotId) {
    try {
      return _slots.firstWhere((s) => s.slotId == slotId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scale down on small landscape screens instead of overflowing.
    final screen = MediaQuery.of(context).size;
    final dialogW = math.min(600.0, screen.width * 0.9);
    final dialogH = math.min(520.0, screen.height * 0.86);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: dialogW,
        height: dialogH,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white24, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 24.0,
              spreadRadius: 8.0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Mode Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTabButton('SAVE GAME', true),
                      const SizedBox(width: 12.0),
                      _buildTabButton('LOAD GAME', false),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Slots List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white70))
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        if (!_saveMode) ...[
                          _buildSlotTile(0, 'AUTOSAVE (SLOT 0)', isSystem: true),
                          const SizedBox(height: 10.0),
                          _buildSlotTile(-1, 'CHECKPOINT (SLOT -1)', isSystem: true),
                          const SizedBox(height: 10.0),
                        ],
                        _buildSlotTile(1, 'SAVE SLOT 1'),
                        const SizedBox(height: 10.0),
                        _buildSlotTile(2, 'SAVE SLOT 2'),
                        const SizedBox(height: 10.0),
                        _buildSlotTile(3, 'SAVE SLOT 3'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSave) {
    final active = _saveMode == isSave;
    return InkWell(
      onTap: () {
        setState(() {
          _saveMode = isSave;
        });
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.black : Colors.white60,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSlotTile(int slotId, String defaultLabel, {bool isSystem = false}) {
    final meta = _getMetaForSlot(slotId);
    final isEmpty = meta == null;

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isEmpty ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: isEmpty ? Colors.white10 : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: isSystem
                  ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              isSystem ? Icons.history : (isEmpty ? Icons.save_outlined : Icons.bookmark),
              color: isSystem ? const Color(0xFFEF4444) : Colors.white70,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defaultLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '[ Empty Slot ]',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12.0),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            meta.label.isNotEmpty ? meta.label : defaultLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            meta.formattedDate,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 11.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${meta.actTitle} • ${meta.missionTitle}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        '${meta.regionName} • Time: ${meta.formattedTime} • ₹${meta.money} • Rep: ${meta.reputation}',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11.0),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12.0),
          if (_saveMode)
            ElevatedButton(
              onPressed: () async {
                await widget.onSaveRequested?.call(slotId);
                await _refreshSlots();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              child: Text(isEmpty ? 'SAVE' : 'OVERWRITE'),
            )
          else
            ElevatedButton(
              onPressed: isEmpty
                  ? null
                  : () async {
                      await widget.onLoadRequested?.call(slotId);
                      if (mounted) Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              child: const Text('LOAD'),
            ),
        ],
      ),
    );
  }
}
