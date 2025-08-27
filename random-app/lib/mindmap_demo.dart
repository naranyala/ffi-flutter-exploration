import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const MindMapApp());

class MindMapApp extends StatelessWidget {
  const MindMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final root = MindMapNode(
      'Mind Map',
      [
        MindMapNode('Planning', [MindMapNode('Goals'), MindMapNode('Roadmap')]),
        MindMapNode('Design', [MindMapNode('UX'), MindMapNode('UI')]),
        MindMapNode('Build', [MindMapNode('Backend'), MindMapNode('Frontend')]),
      ],
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Static Mind Map')),
        body: Center(
          child: CustomPaint(
            size: const Size(400, 400),
            painter: MindMapPainter(root),
          ),
        ),
      ),
    );
  }
}

class MindMapNode {
  final String label;
  final List<MindMapNode> children;
  MindMapNode(this.label, [this.children = const []]);
}

class MindMapPainter extends CustomPainter {
  final MindMapNode root;
  MindMapPainter(this.root);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _drawNode(canvas, center, root, 0, 2 * math.pi, 100);
  }

  void _drawNode(Canvas canvas, Offset pos, MindMapNode node,
      double startAngle, double sweep, double radius) {
    // Measure text
    final tp = TextPainter(
      text: TextSpan(
        text: node.label,
        style: const TextStyle(color: Colors.black),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 80);

    final boxWidth = tp.width + 16;
    final boxHeight = tp.height + 12;

    // Rounded box rect
    final rect = Rect.fromCenter(center: pos, width: boxWidth, height: boxHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    // Solid background fill
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    // Border
    canvas.drawRRect(
        rrect, Paint()..color = Colors.grey..style = PaintingStyle.stroke);

    // Text
    tp.paint(
      canvas,
      Offset(rect.left + (rect.width - tp.width) / 2,
          rect.top + (rect.height - tp.height) / 2),
    );

    if (node.children.isEmpty) return;

    final step = sweep / node.children.length;
    for (var i = 0; i < node.children.length; i++) {
      final angle = startAngle + step * (i + 0.5);
      final childPos = pos + Offset(math.cos(angle), math.sin(angle)) * radius;

      // Draw line from center of parent to center of child
      canvas.drawLine(pos, childPos, Paint()..color = Colors.grey);

      _drawNode(canvas, childPos, node.children[i],
          angle - step / 2, step, radius * 0.7);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

