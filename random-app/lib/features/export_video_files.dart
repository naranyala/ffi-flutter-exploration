import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Export Video Files',
      home: const CardListScreen(),
    );
  }
}

class CardListScreen extends StatelessWidget {
  const CardListScreen({super.key});

  // Sample data list
  final List<String> items = const [
    'Export MP4 - H.264/AVC',
    'Export MP4 - H.265/HEVC',
    'Export MP4 - AV1',
  ];

  void _logCardTap(String label, int index) {
    // Replace with your logging mechanism
    debugPrint('Tapped card [$index]: $label');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modular Card List')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final label = items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: ListTile(
              title: Text(label),
              onTap: () => _logCardTap(label, index),
            ),
          );
        },
      ),
    );
  }
}



