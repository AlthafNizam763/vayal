import 'package:flutter/material.dart';
import 'vayal_game_root.dart';

/// Root application widget for VAYAL.
class VayalApp extends StatelessWidget {
  const VayalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAYAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Color(0xFF8A939E),
          surface: Color(0xFF161A20),
        ),
      ),
      home: const VayalGameRoot(),
    );
  }
}
