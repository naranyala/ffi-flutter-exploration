import 'package:flutter/material.dart';

// Data model for a single timeline item.
class TimelineItem {
  final String year;
  final List<String> events;
  TimelineItem({required this.year, required this.events});
}

// Configuration for timeline styling with more options
class TimelineConfig {
  static const double lineWidth = 4.0;
  static const double dotSize = 20.0;
  static const double dotBorderWidth = 3.0;
  static const double itemSpacing = 32.0;
  static const double contentSpacing = 20.0;
  static const Color lineColor = Colors.blue;
  static const Color dotColor = Colors.blueAccent;
  static const Color textColor = Colors.black87;
  static const Color backgroundColor = Colors.white;
  static const Color yearBadgeColor = Color(0xFFE3F2FD);
  static const Color eventDotColor = Color(0xFF64B5F6);
  static const Duration animationDuration = Duration(milliseconds: 300);
}

// Custom painter to draw the vertical timeline line
class _TimelinePainter extends CustomPainter {
  final List<double> dotPositions;
  final double lineWidth;
  final Color lineColor;
  final double dotSize;
  final double totalHeight;

  _TimelinePainter({
    required this.dotPositions,
    required this.lineWidth,
    required this.lineColor,
    required this.dotSize,
    required this.totalHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dotPositions.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Draw the full vertical line first
    final lineStart = Offset(dotSize / 2, 0);
    final lineEnd = Offset(dotSize / 2, totalHeight);
    canvas.drawLine(lineStart, lineEnd, paint);
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) =>
      dotPositions != oldDelegate.dotPositions ||
      totalHeight != oldDelegate.totalHeight;
}

// Main timeline widget
class Timeline extends StatelessWidget {
  const Timeline({super.key});

  static final List<TimelineItem> data = [
    TimelineItem(
      year: '2023',
      events: ['Launched new product', 'Opened second office', 'Reached 100K users', 'Won industry award'],
    ),
    TimelineItem(
      year: '2024',
      events: ['Expanded globally', 'Added AI features', 'Series B funding', 'New partnerships', 'Mobile app launch'],
    ),
    TimelineItem(
      year: '2025',
      events: ['Carbon neutral', 'Open-sourced toolkit'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: _TimelineBuilder(data: data),
    );
  }
}

// Widget that builds timeline with proper measurements
class _TimelineBuilder extends StatefulWidget {
  final List<TimelineItem> data;
  
  const _TimelineBuilder({required this.data});

  @override
  _TimelineBuilderState createState() => _TimelineBuilderState();
}

class _TimelineBuilderState extends State<_TimelineBuilder> {
  final List<GlobalKey> _itemKeys = [];
  List<double> _itemHeights = [];
  double _totalHeight = 0;
  bool _heightsCalculated = false;

  @override
  void initState() {
    super.initState();
    // Create keys for each timeline item
    for (int i = 0; i < widget.data.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timeline with line
        Stack(
          children: [
            // Timeline line (drawn behind content)
            if (_heightsCalculated)
              SizedBox(
                height: _totalHeight,
                child: CustomPaint(
                  painter: _TimelinePainter(
                    dotPositions: _itemHeights,
                    lineWidth: TimelineConfig.lineWidth,
                    lineColor: TimelineConfig.lineColor,
                    dotSize: TimelineConfig.dotSize,
                    totalHeight: _totalHeight,
                  ),
                ),
              ),
            // Timeline content
            Column(
              children: widget.data.asMap().entries.map<Widget>((entry) {
                final index = entry.key;
                final item = entry.value;
                
                return Container(
                  key: _itemKeys[index],
                  margin: EdgeInsets.only(
                    bottom: (index == widget.data.length - 1) ? 0 : TimelineConfig.itemSpacing,
                  ),
                  child: _TimelineItemWidget(item: item, index: index),
                );
              }).toList(),
            ),
          ],
        ),
        // Calculate sizes after build
        if (!_heightsCalculated)
          LayoutBuilder(
            builder: (context, constraints) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _calculateHeights();
              });
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  void _calculateHeights() {
    final newHeights = <double>[];
    double currentHeight = 0;

    for (final key in _itemKeys) {
      final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        newHeights.add(currentHeight + renderBox.size.height / 2);
        currentHeight += renderBox.size.height + 
            ((newHeights.length < _itemKeys.length) ? TimelineConfig.itemSpacing : 0);
      }
    }

    if (newHeights.length == widget.data.length) {
      setState(() {
        _itemHeights = newHeights;
        _totalHeight = currentHeight;
        _heightsCalculated = true;
      });
    }
  }
}

// Individual timeline item widget
class _TimelineItemWidget extends StatelessWidget {
  final TimelineItem item;
  final int index;

  const _TimelineItemWidget({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot with enhanced styling
        Container(
          width: TimelineConfig.dotSize,
          height: TimelineConfig.dotSize,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TimelineConfig.dotColor,
                TimelineConfig.dotColor.withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: TimelineConfig.backgroundColor,
              width: TimelineConfig.dotBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: TimelineConfig.lineColor.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(width: TimelineConfig.contentSpacing),
        // Content area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Year badge with animation
              _AnimatedYearBadge(year: item.year),
              const SizedBox(height: 12),
              // Events container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.events.asMap().entries.map<Widget>((eventEntry) {
                    final eventIndex = eventEntry.key;
                    final event = eventEntry.value;
                    final isLastEvent = eventIndex == item.events.length - 1;
                    
                    return Container(
                      margin: EdgeInsets.only(bottom: isLastEvent ? 0 : 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 12),
                            decoration: BoxDecoration(
                              color: TimelineConfig.eventDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              event,
                              style: TextStyle(
                                fontSize: 14,
                                color: TimelineConfig.textColor,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Animated year badge widget
class _AnimatedYearBadge extends StatefulWidget {
  final String year;

  const _AnimatedYearBadge({required this.year});

  @override
  __AnimatedYearBadgeState createState() => __AnimatedYearBadgeState();
}

class __AnimatedYearBadgeState extends State<_AnimatedYearBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TimelineConfig.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    // Start animation with a slight delay based on the year
    Future.delayed(Duration(milliseconds: 100 * int.parse(widget.year) % 2010), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: TimelineConfig.yearBadgeColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: TimelineConfig.lineColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          widget.year,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: TimelineConfig.lineColor.withOpacity(0.8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: TimelineConfig.textColor),
        ),
      ),
      home: Scaffold(
        backgroundColor: TimelineConfig.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Enhanced Timeline',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          backgroundColor: TimelineConfig.backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Timeline(),
      ),
    ),
  );
}
