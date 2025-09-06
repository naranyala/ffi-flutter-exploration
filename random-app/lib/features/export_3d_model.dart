import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Export 3D Model',
      home: const CardListScreen(),
    );
  }
}

class CardListScreen extends StatelessWidget {
  const CardListScreen({super.key});

  // Sample data list
  final List<String> items = const [
    'Export BLEND',
    'Export OBJ',
    'Export GLB',
    'Export GLTF',
    'Export FBX',
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




