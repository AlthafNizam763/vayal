import 'package:flutter/material.dart';

/// Minimal noir Pause menu dialog with navigation actions.
class PauseMenuDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenMissions;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenSaveLoad;
  final VoidCallback onOpenSettings;
  final VoidCallback onQuitToMainMenu;

  const PauseMenuDialog({
    super.key,
    required this.onResume,
    required this.onOpenMap,
    required this.onOpenMissions,
    required this.onOpenInventory,
    required this.onOpenSaveLoad,
    required this.onOpenSettings,
    required this.onQuitToMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24.0),
      child: Container(
        width: 360.0,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1116),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.white24, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 28.0,
              spreadRadius: 8.0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'V A Y A L',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6.0,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Center(
              child: Text(
                'GAME PAUSED',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10.0,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Divider(color: Colors.white12, height: 28.0),

            _menuBtn(context, 'RESUME', Icons.play_arrow_outlined, onResume, isPrimary: true),
            const SizedBox(height: 8.0),
            _menuBtn(context, 'TACTICAL MAP [M]', Icons.map_outlined, onOpenMap),
            const SizedBox(height: 8.0),
            _menuBtn(context, 'MISSION LOG [J]', Icons.assignment_outlined, onOpenMissions),
            const SizedBox(height: 8.0),
            _menuBtn(context, 'INVENTORY BAG [I]', Icons.backpack_outlined, onOpenInventory),
            const SizedBox(height: 8.0),
            _menuBtn(context, 'SAVE / LOAD GAME', Icons.save_outlined, onOpenSaveLoad),
            const SizedBox(height: 8.0),
            _menuBtn(context, 'SETTINGS & AUDIO', Icons.settings_outlined, onOpenSettings),
            const SizedBox(height: 12.0),
            const Divider(color: Colors.white12, height: 16.0),
            _menuBtn(context, 'MAIN MENU', Icons.logout, onQuitToMainMenu, isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isPrimary = false,
    bool isDanger = false,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).pop();
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Colors.white
            : (isDanger ? const Color(0xFFEF4444).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.06)),
        foregroundColor: isPrimary ? Colors.black : (isDanger ? const Color(0xFFEF4444) : Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isDanger ? const Color(0xFFEF4444).withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.0),
          const SizedBox(width: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
