import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CircleSliderDemo(),
  ));
}

class CircleSliderDemo extends StatefulWidget {
  const CircleSliderDemo({super.key});

  @override
  State<CircleSliderDemo> createState() => _CircleSliderDemoState();
}

class _CircleSliderDemoState extends State<CircleSliderDemo> {
  double _diameter = 150; // initial diameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resize Circle with Slider")),
      body: Column(
        children: [
          // Drawing area
          Expanded(
            child: CustomPaint(
              painter: CirclePainter(_diameter),
              child: const SizedBox.expand(),
            ),
          ),

          // Slider control
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Slider(
                  value: _diameter,
                  min: 20,
                  max: 400,
                  divisions: 38,
                  label: _diameter.round().toString(),
                  onChanged: (value) {
                    setState(() => _diameter = value);
                  },
                ),
                Text(
                  "Diameter: ${_diameter.toStringAsFixed(0)} px",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double diameter;

  CirclePainter(this.diameter);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, diameter / 2, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.diameter != diameter;
}

