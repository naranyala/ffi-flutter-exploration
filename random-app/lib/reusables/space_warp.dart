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
      title: 'Space Warp Animation',
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SpaceWarp(),
        ),
      ),
    );
  }
}

class SpaceWarp extends StatefulWidget {
  const SpaceWarp({super.key});

  @override
  State<SpaceWarp> createState() => _SpaceWarpState();
}

class _SpaceWarpState extends State<SpaceWarp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final List<Star> _stars = [];
  final int _starCount = 200;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize stars
    for (int i = 0; i < _starCount; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * 2 - 1, // -1 to 1
        y: _random.nextDouble() * 2 - 1, // -1 to 1
        z: _random.nextDouble(),         // 0 to 1
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.02 + 0.005,
      ));
    }
    
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {
          // Update star positions
          for (var star in _stars) {
            star.z -= star.speed;
            if (star.z <= 0) {
              star.z = 1;
              star.x = _random.nextDouble() * 2 - 1;
              star.y = _random.nextDouble() * 2 - 1;
            }
          }
        });
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpaceWarpPainter(_stars),
      size: Size.infinite,
    );
  }
}

class Star {
  double x, y, z;
  final double size;
  final double speed;
  
  Star({
    required this.x,
    required this.y,
    required this.z,
    required this.size,
    required this.speed,
  });
}

class SpaceWarpPainter extends CustomPainter {
  final List<Star> stars;
  
  SpaceWarpPainter(this.stars);
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw background gradient for space
    final Rect rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    final Gradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        Colors.black.withOpacity(0.9),
        Colors.black,
      ],
      stops: [0.0, 1.0],
    );
    final Paint bgPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);
    
    // Draw stars
    for (var star in stars) {
      // Perspective projection
      final double offsetX = (star.x / star.z) * centerX;
      final double offsetY = (star.y / star.z) * centerY;
      final double starX = centerX + offsetX;
      final double starY = centerY + offsetY;
      
      // Star size based on distance (z value)
      final double starSize = star.size / star.z;
      
      // Star color based on distance (z value)
      final int colorValue = (255 * (1 - star.z)).clamp(50, 255).toInt();
      final Color starColor = Color.fromARGB(
        255, 
        colorValue, 
        colorValue, 
        min(255, colorValue + 50),
      );
      
      // Draw star
      final Paint starPaint = Paint()
        ..color = starColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      
      canvas.drawCircle(
        Offset(starX, starY),
        starSize,
        starPaint,
      );
      
      // Draw star glow
      if (star.z < 0.3) {
        final Paint glowPaint = Paint()
          ..color = starColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        
        canvas.drawCircle(
          Offset(starX, starY),
          starSize * 3,
          glowPaint,
        );
      }
    }
    
    // Draw central warp effect
    final Paint warpPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 100));
    
    canvas.drawCircle(
      Offset(centerX, centerY),
      100,
      warpPaint,
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
