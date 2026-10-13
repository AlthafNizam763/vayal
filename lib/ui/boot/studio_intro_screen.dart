import 'package:flutter/material.dart';

/// Suppid Games studio intro shown before the title screen.
/// Restrained, dark, cinematic. Tap anywhere to skip.
class StudioIntroScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const StudioIntroScreen({super.key, required this.onFinished});

  @override
  State<StudioIntroScreen> createState() => _StudioIntroScreenState();
}

class _StudioIntroScreenState extends State<StudioIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    // Auto-advance; generous window, always skippable by tap.
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111311), // Brand charcoal black
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onFinished,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _controller,
                child: Image.asset(
                  'assets/branding/suppid_games/suppid_games_logo.png',
                  width: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => CustomPaint(
                    size: const Size(96, 96),
                    painter: _SuppidEmblemPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _controller,
                child: const Column(
                  children: [
                    Text(
                      'STORIES FROM VEYRAPURAM',
                      style: TextStyle(
                        color: Color(0xFF5E6B5C),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Original Suppid Games emblem: rotated forest-green square framing two
/// ivory chevrons over a horizon line — works at small sizes, no mascots.
class _SuppidEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sq = size.width * 0.82;

    // Outer rotated square (forest green)
    final frame = Rect.fromCenter(center: center, width: sq, height: sq);
    final framePaint = Paint()
      ..color = const Color(0xFF26382C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.61547); // 35.26°
    canvas.translate(-center.dx, -center.dy);
    canvas.drawRect(frame.deflate(2), framePaint);
    canvas.restore();

    // Horizon line (ivory)
    final horizon = Paint()
      ..color = const Color(0xFFE8E2D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.30, size.height * 0.62),
      Offset(size.width * 0.70, size.height * 0.62),
      horizon,
    );

    // Rising chevron above horizon (ivory)
    final chevron = Paint()
      ..color = const Color(0xFFE8E2D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.34, size.height * 0.52)
      ..lineTo(size.width * 0.50, size.height * 0.34)
      ..lineTo(size.width * 0.66, size.height * 0.52);
    canvas.drawPath(path, chevron);

    // Earthy-red field accent below horizon
    final field = Paint()
      ..color = const Color(0xFF87443A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.34,
          size.height * 0.66,
          size.width * 0.32,
          4,
        ),
        const Radius.circular(2),
      ),
      field,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
