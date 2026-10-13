import 'package:flutter/material.dart';

/// Fullscreen Main Menu for VAYAL open-world crime thriller.
class MainMenuScreen extends StatelessWidget {
  final bool hasSaveData;
  final VoidCallback onContinue;
  final VoidCallback onNewGame;
  final VoidCallback onLoadGame;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCredits;

  const MainMenuScreen({
    super.key,
    this.hasSaveData = true,
    required this.onContinue,
    required this.onNewGame,
    required this.onLoadGame,
    required this.onOpenSettings,
    required this.onOpenCredits,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Atmospheric Noir Vignette & Grain Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Color(0xFF141923), // Deep slate mystery
                    Color(0xFF090B0E),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Central Menu Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Emblem
                      const Center(
                        child: Image(
                          image: AssetImage('assets/branding/vayal_emblem.png'),
                          width: 96.0,
                          height: 96.0,
                          fit: BoxFit.contain,
                          semanticLabel: 'VAYAL emblem',
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Subtitle Tag
                      const Text(
                        'A CRIME THRILLER OPEN-WORLD 3D EXPERIENCE',
                        style: TextStyle(
                          color: Color(0xFFD97736),
                          fontSize: 10.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Title Logo
                      const Text(
                        'V A Y A L',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 54.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 16.0,
                          shadows: [
                            Shadow(
                              color: Color(0xFFD97736),
                              blurRadius: 28.0,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // Core Theme Quote
                      Text(
                        '“Can a man escape the person he used to be?”',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13.0,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 48.0),

                      // Menu Navigation Buttons
                      Container(
                        constraints: const BoxConstraints(maxWidth: 320.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (hasSaveData) ...[
                              _buildMenuBtn('CONTINUE', onContinue, isHighlight: true),
                              const SizedBox(height: 10.0),
                            ],
                            _buildMenuBtn('NEW GAME', onNewGame),
                            const SizedBox(height: 10.0),
                            _buildMenuBtn('LOAD GAME', onLoadGame),
                            const SizedBox(height: 10.0),
                            _buildMenuBtn('SETTINGS & AUDIO', onOpenSettings),
                            const SizedBox(height: 10.0),
                            _buildMenuBtn('CREDITS', onOpenCredits),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48.0),

                      // Footer Credits & Platform Notes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'OFFLINE EDITION • VEYRAPURAM OPEN WORLD',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBtn(String label, VoidCallback onTap, {bool isHighlight = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isHighlight ? const Color(0xFFD97736) : Colors.white.withValues(alpha: 0.08),
        foregroundColor: isHighlight ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: isHighlight ? const Color(0xFFFF9800) : Colors.white12,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.5,
          color: isHighlight ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
