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
          // Background: Cinematic Block-Style Title Screen Artwork
          Positioned.fill(
            child: Image.asset(
              'assets/branding/vayal/splash/vayal_splash.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Color(0xFF141923),
                      Color(0xFF090B0E),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Atmospheric Dark Gradient Vignette for UI Readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.60),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),

          // Central Menu Layout (Adaptive for Landscape & Portrait)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > constraints.maxHeight;

                if (isLandscape) {
                  // Two-column or compact landscape layout so all buttons fit on screen
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Column: Logo & Quote
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/branding/vayal/logo/vayal_logo_transparent.png',
                                height: 75.0,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/branding/vayal/logo/vayal_logo.png',
                                  height: 75.0,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Text(
                                    'V A Y A L',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 10.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6.0),
                              Text(
                                '“Can a man escape the person he used to be?”',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 11.0,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.8,
                                  shadows: const [
                                    Shadow(color: Colors.black, blurRadius: 10),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              const Text(
                                'Provided by Suppid Games',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 24.0),

                        // Right Column: Navigation Buttons
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 320.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (hasSaveData) ...[
                                    _buildMenuBtn('CONTINUE', onContinue, isHighlight: true),
                                    const SizedBox(height: 6.0),
                                  ],
                                  _buildMenuBtn('NEW GAME', onNewGame),
                                  const SizedBox(height: 6.0),
                                  _buildMenuBtn('LOAD GAME', onLoadGame),
                                  const SizedBox(height: 6.0),
                                  _buildMenuBtn('SETTINGS & AUDIO', onOpenSettings),
                                  const SizedBox(height: 6.0),
                                  _buildMenuBtn('CREDITS', onOpenCredits),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Portrait fallback
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/branding/vayal/logo/vayal_logo_transparent.png',
                              height: 90.0,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/branding/vayal/logo/vayal_logo.png',
                                height: 90.0,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Text(
                                  'V A Y A L',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40.0,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '“Can a man escape the person he used to be?”',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.0,
                              shadows: const [
                                Shadow(color: Colors.black, blurRadius: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 320.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (hasSaveData) ...[
                                  _buildMenuBtn('CONTINUE', onContinue, isHighlight: true),
                                  const SizedBox(height: 8.0),
                                ],
                                _buildMenuBtn('NEW GAME', onNewGame),
                                const SizedBox(height: 8.0),
                                _buildMenuBtn('LOAD GAME', onLoadGame),
                                const SizedBox(height: 8.0),
                                _buildMenuBtn('SETTINGS & AUDIO', onOpenSettings),
                                const SizedBox(height: 8.0),
                                _buildMenuBtn('CREDITS', onOpenCredits),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            'Provided by Suppid Games',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
