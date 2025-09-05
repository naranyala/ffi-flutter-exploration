import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Widget Explorer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(child: RandomWidgetExplorer()),
      ),
    );
  }
}

class RandomWidgetExplorer extends StatefulWidget {
  const RandomWidgetExplorer({super.key});

  @override
  State<RandomWidgetExplorer> createState() => _RandomWidgetExplorerState();
}

class _RandomWidgetExplorerState extends State<RandomWidgetExplorer> {
  final Random _random = Random();
  Widget _currentWidget = const Placeholder();

  // List of interesting widgets to randomly display
  final List<Widget> _widgetExamples = [
    const FlutterLogo(size: 100),
    Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.star, color: Colors.white, size: 50),
    ),
    const CircleAvatar(
      radius: 60,
      backgroundImage: NetworkImage(
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
    ),
    Chip(
      avatar: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Text('FL', style: TextStyle(color: Colors.white)),
      ),
      label: const Text('Flutter is awesome!'),
      onDeleted: () {},
    ),
    const LinearProgressIndicator(value: 0.7),
    Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.album),
              title: Text('Beautiful Card'),
              subtitle: Text('This is a Material Card widget'),
            ),
            ButtonBar(
              children: [
                TextButton(onPressed: () {}, child: const Text('OK')),
                TextButton(onPressed: () {}, child: const Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    ),
    const Tooltip(
      message: 'This is a Tooltip! Hover or long press me.',
      child: Text('Hover or long press me', style: TextStyle(fontSize: 16)),
    ),
    FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getRandomWidget();
  }

  void _getRandomWidget() {
    setState(() {
      _currentWidget = _widgetExamples[_random.nextInt(_widgetExamples.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _getRandomWidget,
      child: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the random widget
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _currentWidget,
            ),
            const SizedBox(height: 30),
            // Instructions
            const Text(
              '👇 Tap anywhere to see a new random widget!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Show widget type name
            Text(
              _currentWidget.runtimeType.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
