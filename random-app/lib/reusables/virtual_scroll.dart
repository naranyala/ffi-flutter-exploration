import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Scroll Example'),
      ),
      body: Container(
        // Add outer border
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        margin: const EdgeInsets.all(16.0), // Optional: add margin from screen edges
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0), // Clip content to border radius
          child: SizedBox(
            height: double.infinity, // Take full available height
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Horizontal scroll
              child: SizedBox(
                width: 1000, // Define the width for the content
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scroll
                  child: Column(
                    children: List.generate(
                      50, // Number of items
                      (index) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Text('Item $index'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
