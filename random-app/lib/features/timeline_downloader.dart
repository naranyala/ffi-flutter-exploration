import 'package:flutter/material.dart';

// Data model for a single timeline item
class TimelineItem {
  final String year;
  final List<String> events;
  TimelineItem({required this.year, required this.events});
}

// Main timeline widget
class TimelineDownloader extends StatelessWidget {
  Timeline({super.key});

  static final List<TimelineItem> data = [
    TimelineItem(
      year: '2023',
      events: ['Launched new product', 'Opened second office', 'Reached 100K users'],
    ),
    TimelineItem(
      year: '2024',
      events: ['Expanded globally', 'Added AI features', 'Series B funding'],
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
      child: Column(
        children: [
          // Draw the continuous vertical line first
          Stack(
            children: [
              // Vertical line
              Positioned(
                left: 7, // Center of the 16px dot (8px) minus half line width (1px)
                child: Container(
                  width: 2,
                  height: _calculateTotalHeight(),
                  color: Colors.blue,
                ),
              ),
              // Timeline items
              Column(
                children: [
                  for (int i = 0; i < data.length; i++) 
                    _TimelineItem(item: data[i], isLast: i == data.length - 1),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Calculate approximate total height of timeline
  double _calculateTotalHeight() {
    double height = 0;
    for (var item in data) {
      // Approximate height based on number of events
      height += 40 + (item.events.length * 24) + 24;
    }
    return height;
  }
}

// Individual timeline item widget
class _TimelineItem extends StatelessWidget {
  final TimelineItem item;
  final bool isLast;

  const _TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year
                Text(
                  item.year,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Events
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final event in item.events)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $event'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// void TimelineDownloader() {
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Fixed Timeline'),
//         ),
//         body: const Timeline(),
//       ),
//     ),
//   );
// }
//
