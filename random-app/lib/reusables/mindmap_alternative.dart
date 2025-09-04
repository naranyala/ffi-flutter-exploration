import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MindMapApp());
}

class MindMapApp extends StatelessWidget {
  const MindMapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MindMapView(
          root: MindMapNode(
            id: '1',
            title: 'Root',
            children: [
              MindMapNode(id: '2', title: 'Idea 1'),
              MindMapNode(
                id: '3',
                title: 'Idea 2',
                children: [
                  MindMapNode(id: '5', title: 'Sub Idea A'),
                  MindMapNode(id: '6', title: 'Sub Idea B'),
                ],
              ),
              MindMapNode(id: '4', title: 'Idea 3'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple node data model
class MindMapNode {
  final String id;
  final String title;
  final List<MindMapNode> children;

  MindMapNode({required this.id, required this.title, this.children = const []});
}

/// Widget for each node in the mindmap
class NodeWidget extends StatelessWidget {
  final String title;
  const NodeWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

/// Painter for drawing connection lines
class ConnectionPainter extends CustomPainter {
  final List<Offset> connections;
  ConnectionPainter(this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < connections.length; i += 2) {
      final start = connections[i];
      final end = connections[i + 1];
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          (start.dx + end.dx) / 2, start.dy,
          end.dx, end.dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) => true;
}

/// Main mind map visualization
class MindMapView extends StatefulWidget {
  final MindMapNode root;
  const MindMapView({Key? key, required this.root}) : super(key: key);

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  final List<Offset> _connections = [];

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 2.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _connections.clear();
          final center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight / 2,
          );
          final widgets = <Widget>[];

          // Build nodes recursively
          widgets.addAll(_buildNode(widget.root, center, 0, 360));

          return Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: ConnectionPainter(_connections),
              ),
              ...widgets,
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildNode(
      MindMapNode node, Offset center, double startAngle, double sweepAngle) {
    final widgets = <Widget>[];

    // Add current node
    widgets.add(Positioned(
      left: center.dx - 50,
      top: center.dy - 20,
      child: NodeWidget(title: node.title),
    ));

    if (node.children.isNotEmpty) {
      final radius = 140.0;
      final perChildAngle = sweepAngle / node.children.length;
      for (int i = 0; i < node.children.length; i++) {
        final angle = startAngle + i * perChildAngle + perChildAngle / 2;
        final rad = angle * pi / 180;
        final childCenter = Offset(
          center.dx + radius * cos(rad),
          center.dy + radius * sin(rad),
        );

        _connections.add(center);
        _connections.add(childCenter);

        // Recursively build child widgets
        widgets.addAll(_buildNode(
          node.children[i],
          childCenter,
          angle - perChildAngle / 2,
          perChildAngle,
        ));
      }
    }

    return widgets;
  }
}

