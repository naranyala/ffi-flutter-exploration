import 'package:flutter/material.dart';
import 'dart:math';

class PersonalDevelopment {
  final String area;
  final double score; // Score from 0 to 100
  PersonalDevelopment(this.area, this.score);
}

final developmentData = [
  PersonalDevelopment('Time Management', 75),
  PersonalDevelopment('Emotional Intelligence', 60),
  PersonalDevelopment('Physical Health', 80),
  PersonalDevelopment('Learning & Skills', 90),
  PersonalDevelopment('Social Connections', 70),
  PersonalDevelopment('Financial Literacy', 65),
];

class PersonalRadarChartPainter extends CustomPainter {
  final List<PersonalDevelopment> data;
  final Color chartColor;
  
  PersonalRadarChartPainter({required this.data, this.chartColor = Colors.green});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chartColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final radius = min(size.width, size.height) / 2 * 0.7;
    final center = Offset(size.width / 2, size.height / 2);
    final angle = 2 * pi / data.length;

    // Draw concentric polygons (grid background)
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
      
      // Fill with very light background
      canvas.drawPath(path, Paint()..color = Colors.grey.withOpacity(0.05));
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines from center to vertices
    for (int i = 0; i < data.length; i++) {
      final x = center.dx + radius * cos(i * angle - pi / 2);
      final y = center.dy + radius * sin(i * angle - pi / 2);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw score rings (concentric circles with score labels)
    for (int i = 1; i <= 5; i++) {
      final ringRadius = radius * i / 5;
      final scoreValue = (i * 20).toString();
      
      // Draw score label at the top
      textPainter.text = TextSpan(
        text: scoreValue,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      );
      textPainter.layout();
      
      final labelX = center.dx - textPainter.width / 2;
      final labelY = center.dy - ringRadius - textPainter.height / 2;
      
      canvas.save();
      canvas.translate(labelX, labelY);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Draw data polygon
    final dataPath = Path();
    final dataPoints = <Offset>[];
    
    for (int i = 0; i < data.length; i++) {
      final r = radius * (data[i].score / 100);
      final x = center.dx + r * cos(i * angle - pi / 2);
      final y = center.dy + r * sin(i * angle - pi / 2);
      dataPoints.add(Offset(x, y));
      
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();
    
    // Draw filled area
    canvas.drawPath(dataPath, paint);
    
    // Draw border
    canvas.drawPath(dataPath, strokePaint);

    // Draw data points
    for (final point in dataPoints) {
      canvas.drawCircle(point, 4, Paint()..color = chartColor);
      canvas.drawCircle(point, 4, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }

    // Draw labels with better positioning and styling
    for (int i = 0; i < data.length; i++) {
      final labelDistance = radius + 40;
      final x = center.dx + labelDistance * cos(i * angle - pi / 2);
      final y = center.dy + labelDistance * sin(i * angle - pi / 2);
      
      // Main label
      textPainter.text = TextSpan(
        text: data[i].area,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      
      // Calculate text position based on angle for better readability
      double textX = x - textPainter.width / 2;
      double textY = y - textPainter.height / 2;
      
      // Adjust positioning for labels that would be cut off
      final anglePos = i * angle - pi / 2;
      if (cos(anglePos) > 0.5) { // Right side
        textX = x - 5;
      } else if (cos(anglePos) < -0.5) { // Left side
        textX = x - textPainter.width + 5;
      }
      
      if (sin(anglePos) > 0.5) { // Bottom
        textY = y - 5;
      } else if (sin(anglePos) < -0.5) { // Top
        textY = y - textPainter.height + 5;
      }
      
      canvas.save();
      canvas.translate(textX, textY);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
      
      // Score value under the label
      textPainter.text = TextSpan(
        text: '${data[i].score.toInt()}%',
        style: TextStyle(
          color: chartColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(textX + (textPainter.width / 2), textY + 15);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PersonalRadarChart extends StatelessWidget {
  final List<PersonalDevelopment> data;
  final double size;
  
  const PersonalRadarChart({
    super.key, 
    required this.data,
    this.size = 350,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PersonalRadarChartPainter(
          data: data, 
          chartColor: Colors.teal,
        ),
      ),
    );
  }
}

class PersonalDevelopmentPage extends StatelessWidget {
  const PersonalDevelopmentPage({super.key});

  // Calculate average score
  double get averageScore {
    return developmentData.map((d) => d.score).reduce((a, b) => a + b) / developmentData.length;
  }

  // Get improvement suggestions
  List<PersonalDevelopment> get areasForImprovement {
    return developmentData.where((d) => d.score < 75).toList()
      ..sort((a, b) => a.score.compareTo(b.score));
  }

  // Get strengths
  List<PersonalDevelopment> get strengths {
    return developmentData.where((d) => d.score >= 80).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Personal Development Radar"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header card with summary
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Overall Development Score",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${averageScore.toInt()}%",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Keep growing! Every step counts.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Radar chart
            PersonalRadarChart(data: developmentData),
            
            const SizedBox(height: 30),
            
            // Insights section
            Row(
              children: [
                // Strengths
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Strengths",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...strengths.map((strength) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${strength.area} (${strength.score.toInt()}%)",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Areas for improvement
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Growth Areas",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...areasForImprovement.map((area) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${area.area} (${area.score.toInt()}%)",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add action for creating development plan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Development plan feature coming soon!"),
                    ),
                  );
                },
                icon: const Icon(Icons.assignment),
                label: const Text("Create Development Plan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Demo app to run the personal development radar
class PersonalDevelopmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Development Radar',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PersonalDevelopmentPage(),
    );
  }
}

void main() {
  runApp(PersonalDevelopmentApp());
}
