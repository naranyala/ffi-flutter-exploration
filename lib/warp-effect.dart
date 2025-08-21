import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WarpEffectWithSidebar(),
  ));
}

class WarpEffectWithSidebar extends StatefulWidget {
  const WarpEffectWithSidebar({super.key});

  @override
  State<WarpEffectWithSidebar> createState() => _WarpEffectWithSidebarState();
}

class _WarpEffectWithSidebarState extends State<WarpEffectWithSidebar> {
  double amplitude = 10;
  double frequency = 0.05;
  double fontSize = 48;
  String text = 'Warp Text';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Sidebar controls
          Container(
            width: 250,
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text('Warp Config',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Text',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white38),
                    ),
                  ),
                  onChanged: (v) => setState(() => text = v),
                ),
                const SizedBox(height: 24),
                _sliderControl(
                  label: 'Amplitude',
                  value: amplitude,
                  min: 0,
                  max: 50,
                  onChanged: (v) => setState(() => amplitude = v),
                ),
                _sliderControl(
                  label: 'Frequency',
                  value: frequency,
                  min: 0.01,
                  max: 0.2,
                  onChanged: (v) => setState(() => frequency = v),
                ),
                _sliderControl(
                  label: 'Font Size',
                  value: fontSize,
                  min: 10,
                  max: 100,
                  onChanged: (v) => setState(() => fontSize = v),
                ),
              ],
            ),
          ),

          // Main warped text area
          Expanded(
            child: Center(
              child: SizedBox(
                width: 400,
                height: 150,
                child: CustomPaint(
                  painter: WarpedTextPainter(
                    text: text.isEmpty ? ' ' : text,
                    amplitude: amplitude,
                    frequency: frequency,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white)),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class WarpedTextPainter extends CustomPainter {
  final String text;
  final double amplitude;
  final double frequency;
  final double fontSize;

  WarpedTextPainter({
    required this.text,
    required this.amplitude,
    required this.frequency,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial',
    );

    final textStyle = ui.TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'Arial',
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: size.width));

    final baseY = size.height / 2 - paragraph.height / 2;

    // Draw warped text by slicing vertical strips
    for (double x = 0; x < size.width; x++) {
      final offsetY = amplitude * math.sin(x * frequency);
      canvas.save();
      canvas.translate(x, baseY + offsetY);
      canvas.clipRect(Rect.fromLTWH(0, -offsetY, 1, paragraph.height));
      canvas.drawParagraph(paragraph, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant WarpedTextPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.frequency != frequency ||
        oldDelegate.fontSize != fontSize;
  }
}

