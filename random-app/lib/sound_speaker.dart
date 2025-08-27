import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smooth Speaker Bump',
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SpeakerWaveAnimation(),
        ),
      ),
    );
  }
}

class SpeakerWaveAnimation extends StatefulWidget {
  const SpeakerWaveAnimation({super.key});

  @override
  State<SpeakerWaveAnimation> createState() => _SpeakerWaveAnimationState();
}

class _SpeakerWaveAnimationState extends State<SpeakerWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800), // Longer duration for smoother animation
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: SpeakerWavePainter(_controller.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SpeakerWavePainter extends CustomPainter {
  final double progress;
  
  // Smoother curve for the animation
  static final Curve waveCurve = Curves.easeOutCubic;

  SpeakerWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) * 0.15;
    
    // Main pulsating circle with smooth animation
    final mainProgress = waveCurve.transform(progress % 1.0);
    final mainRadius = baseRadius + baseRadius * 1.5 * sin(mainProgress * pi);
    
    // Draw multiple ripple waves for smoother effect
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + i * 0.3) % 1.0;
      final waveRadius = baseRadius * 2.0 + baseRadius * 3.0 * waveProgress;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);
      
      final wavePaint = Paint()
        ..color = Colors.blue.withOpacity(0.5 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + 3.0 * (1.0 - waveProgress);
      
      if (waveRadius > mainRadius) {
        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }
    
    // Second set of ripples with different color
    for (int i = 0; i < 2; i++) {
      final waveProgress = (progress + 0.15 + i * 0.4) % 1.0;
      final waveRadius = baseRadius * 1.8 + baseRadius * 3.2 * waveProgress;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);
      
      final wavePaint = Paint()
        ..color = Colors.purple.withOpacity(0.4 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + 2.5 * (1.0 - waveProgress);
      
      if (waveRadius > mainRadius) {
        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }
    
    // Main speaker circle with smooth pulsing
    final hueShift = (360 * progress).toInt() % 360;
    final mainColor = HSLColor.fromAHSL(1.0, hueShift.toDouble(), 0.8, 0.7).toColor();
    
    final mainPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, mainRadius, mainPaint);
    
    // Inner highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final highlightRadius = mainRadius * 0.4;
    final highlightOffset = Offset(
      center.dx - highlightRadius * 0.3,
      center.dy - highlightRadius * 0.3,
    );
    
    canvas.drawCircle(highlightOffset, highlightRadius, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant SpeakerWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
