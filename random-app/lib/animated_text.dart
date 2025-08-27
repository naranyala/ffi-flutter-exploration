import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Zoom Text',
      theme: ThemeData.dark(),
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: NeonZoomText(),
        ),
      ),
    );
  }
}

class NeonZoomText extends StatefulWidget {
  const NeonZoomText({super.key});

  @override
  State<NeonZoomText> createState() => _NeonZoomTextState();
}

class _NeonZoomTextState extends State<NeonZoomText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // 🔡 Fixed size text container to prevent layout issues
  static const String text = 'NEON ZOOM';
  static const double fontSize = 64.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start animation loop
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: SizedBox(
            // 🔳 Ensure the text has fixed space
            width: 400,
            height: 100,
            child: Center(
              child: ShaderMask(
                // ✅ Clip to prevent overflow issues
                // clipBehavior: Clip.hardEdge,
                shaderCallback: (Rect bounds) {
                  // 🔁 Ensure bounds is valid
                  if (bounds.isEmpty) {
                    // Return dummy shader to prevent crash
                    return const LinearGradient(colors: [Colors.white])
                        .createShader(Rect.fromLTWH(0, 0, 1, 1));
                  }
                  return const LinearGradient(
                    colors: [
                      Colors.purpleAccent,
                      Colors.blueAccent,
                      Colors.cyanAccent,
                      Colors.greenAccent,
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.white, // 🔴 Required for ShaderMask
                    shadows: [
                      Shadow(
                        blurRadius: 15,
                        color: Colors.cyanAccent.withOpacity(0.8),
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 30,
                        color: Colors.blueAccent.withOpacity(0.6),
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 50,
                        color: Colors.purpleAccent.withOpacity(0.4),
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
