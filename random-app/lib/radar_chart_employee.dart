import 'package:flutter/material.dart';
import 'dart:math';

class EmployeePerformance {
  final String category;
  final double score; // Score from 0 to 100
  EmployeePerformance(this.category, this.score);
}

final performanceData = [
  EmployeePerformance('Communication', 80),
  EmployeePerformance('Teamwork', 70),
  EmployeePerformance('Problem Solving', 90),
  EmployeePerformance('Punctuality', 60),
  EmployeePerformance('Creativity', 75),
];

class RadarChartPainter extends CustomPainter {
  final List<EmployeePerformance> data;
  final Color chartColor;

  RadarChartPainter({required this.data, this.chartColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chartColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final radius = min(size.width, size.height) / 2 * 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = 2 * pi / data.length;

    // Draw polygon background (grid lines)
    for (int i = 5; i >= 1; i--) {
      final path = Path();
      for (int j = 0; j < data.length; j++) {
        final r = radius * i / 5;
        final x = center.dx + r * cos(j * angle - pi / 2);
        final y = center.dy + r * sin(j * angle - pi / 2);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint..color = Colors.grey.withOpacity(0.1));
      canvas.drawPath(path, strokePaint..color = Colors.grey.withOpacity(0.3));
    }

    // Draw axis lines from center to each vertex
    for (int i = 0; i < data.length; i++) {
      final x = center.dx + radius * cos(i * angle - pi / 2);
      final y = center.dy + radius * sin(i * angle - pi / 2);
      canvas.drawLine(center, Offset(x, y), strokePaint..color = Colors.grey.withOpacity(0.3));
    }

    // Draw data polygon
    final dataPath = Path();
    for (int i = 0; i < data.length; i++) {
      final r = radius * (data[i].score / 100);
      final x = center.dx + r * cos(i * angle - pi / 2);
      final y = center.dy + r * sin(i * angle - pi / 2);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, paint..color = chartColor.withOpacity(0.3));
    canvas.drawPath(dataPath, strokePaint..color = chartColor);

    // Draw data points
    for (int i = 0; i < data.length; i++) {
      final r = radius * (data[i].score / 100);
      final x = center.dx + r * cos(i * angle - pi / 2);
      final y = center.dy + r * sin(i * angle - pi / 2);
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = chartColor);
    }

    // Draw labels
    for (int i = 0; i < data.length; i++) {
      final labelRadius = radius + 30;
      final x = center.dx + labelRadius * cos(i * angle - pi / 2);
      final y = center.dy + labelRadius * sin(i * angle - pi / 2);
      
      textPainter.text = TextSpan(
        text: data[i].category,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      
      // Adjust text position based on quadrant for better readability
      double textX = x - textPainter.width / 2;
      double textY = y - textPainter.height / 2;
      
      canvas.save();
      canvas.translate(textX, textY);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
      
      // Draw score text
      textPainter.text = TextSpan(
        text: data[i].score.toInt().toString(),
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      canvas.save();
      canvas.translate(textX, textY + 15);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget to display the radar chart
class RadarChart extends StatelessWidget {
  final List<EmployeePerformance> data;
  final Color chartColor;
  final double size;

  const RadarChart({
    Key? key,
    required this.data,
    this.chartColor = Colors.blue,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RadarChartPainter(
          data: data,
          chartColor: chartColor,
        ),
      ),
    );
  }
}

// Example usage in a complete app
class RadarChartDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Performance Radar Chart',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Performance'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Performance Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                RadarChart(
                  data: performanceData,
                  chartColor: Colors.blue,
                  size: 350,
                ),
                const SizedBox(height: 20),
                // Legend
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: performanceData.map((item) => 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${item.category}: ${item.score.toInt()}%'),
                      ],
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(RadarChartDemo());
}
