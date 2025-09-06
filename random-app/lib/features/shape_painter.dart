import 'package:flutter/material.dart';
import 'dart:math' as math;

enum ShapeType {
  circle,
  square,
  triangle,
  star,
}

class ShapePainter extends CustomPainter {
  final ShapeType shapeType;

  ShapePainter(this.shapeType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;

    switch (shapeType) {
      case ShapeType.circle:
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeType.square:
        final rect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 2);
        canvas.drawRect(rect, paint);
        break;
      case ShapeType.triangle:
        final path = Path();
        path.moveTo(center.dx, center.dy - radius);
        path.lineTo(center.dx - radius, center.dy + radius);
        path.lineTo(center.dx + radius, center.dy + radius);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ShapeType.star:
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final angle = (i * math.pi) / 5;
          final r = i.isEven ? radius : radius * 0.5;
          final x = center.dx + r * math.cos(angle - math.pi / 2);
          final y = center.dy + r * math.sin(angle - math.pi / 2);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Shape Painter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: ShapeSwitcher(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class ShapeSwitcher extends StatefulWidget {
  const ShapeSwitcher({super.key});

  @override
  _ShapeSwitcherState createState() => _ShapeSwitcherState();
}

class _ShapeSwitcherState extends State<ShapeSwitcher> {
  ShapeType selectedShape = ShapeType.circle;

  final shapes = [
    {'type': ShapeType.circle, 'name': 'Circle', 'icon': Icons.circle},
    {'type': ShapeType.square, 'name': 'Square', 'icon': Icons.square},
    {'type': ShapeType.triangle, 'name': 'Triangle', 'icon': Icons.change_history},
    {'type': ShapeType.star, 'name': 'Star', 'icon': Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shape Painter'),
      ),
      body: Column(
        children: [
          // Fixed horizontal switcher
          Container(
            height: 80,
            color: Colors.grey[100],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: shapes.length,
              itemBuilder: (context, index) {
                final shape = shapes[index];
                final isSelected = shape['type'] == selectedShape;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedShape = shape['type'] as ShapeType;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          shape['icon'] as IconData,
                          color: isSelected ? Colors.blue : Colors.grey[600],
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          shape['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Painter section
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: CustomPaint(
                painter: ShapePainter(selectedShape),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
