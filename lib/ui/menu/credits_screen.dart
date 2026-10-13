import 'package:flutter/material.dart';

/// Real credits screen for VAYAL — only factual, known contributors
/// and third-party attributions. No fabricated names.
class CreditsScreen extends StatelessWidget {
  final VoidCallback onClose;

  const CreditsScreen({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: onClose,
        ),
        title: const Text(
          'CREDITS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/branding/vayal/logo/vayal_logo_transparent.png',
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'V A Y A L',
                    style: TextStyle(
                      color: Color(0xFFE8E2D5),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Provided by Suppid Games',
                  style: TextStyle(
                    color: Color(0xFF8B95A2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 36),
                _section('STUDIO & BRAND'),
                const SizedBox(height: 8),
                _plain('Developer Brand', 'Suppid Games'),
                _plain('Product Identity', 'VAYAL — A Veyrapuram Story'),
                const SizedBox(height: 28),
                _section('GAME'),
                const SizedBox(height: 8),
                _plain('Story, World & Design', 'Suppid Games'),
                _plain('Game Programming', 'Suppid Games'),
                const SizedBox(height: 32),
                _section('TECHNOLOGY'),
                const SizedBox(height: 8),
                _plain('Engine Framework', 'Flutter (Google)'),
                _plain('3D Rendering', 'three.js for Dart'),
                const SizedBox(height: 32),
                _section('THIRD-PARTY'),
                const SizedBox(height: 8),
                _plain('Flutter', 'flutter.dev — BSD 3-Clause License'),
                _plain('three.js', 'threejs.org — MIT License (ported to Dart)'),
                const SizedBox(height: 48),
                const Text(
                  'All original content © Suppid Games. '
                  'Unauthorised distribution of VAYAL assets is not permitted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5E6B5C),
                    fontSize: 10,
                    letterSpacing: 0.6,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 14.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Colors.white12),
                    ),
                  ),
                  child: const Text(
                    'BACK',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFD97736),
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.0,
      ),
    );
  }

  Widget _plain(String label, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF8B95A2),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFE8E2D5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
