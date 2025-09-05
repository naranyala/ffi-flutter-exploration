import 'package:flutter/material.dart';

void main() {
  runApp(const WidgetDemoApp());
}

class WidgetDemoApp extends StatelessWidget {
  const WidgetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WidgetDemoScreen(),
    );
  }
}

class WidgetDemoScreen extends StatefulWidget {
  const WidgetDemoScreen({super.key});

  @override
  State<WidgetDemoScreen> createState() => _WidgetDemoScreenState();
}

class _WidgetDemoScreenState extends State<WidgetDemoScreen> {
  int _counter = 0;
  double _sliderValue = 50.0;
  bool _isSwitched = false;
  bool _isChecked = false;
  String _textFieldValue = 'Type something...';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Widget Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _counter = 0;
                _sliderValue = 50.0;
                _isSwitched = false;
                _isChecked = false;
                _textFieldValue = 'Type something...';
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Widgets
            const Text(
              'Text Widgets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('This is a regular text widget'),
            Text(
              'This is bold colored text!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
                fontSize: 16,
              ),
            ),
            const Divider(height: 30),

            // Button Widgets
            const Text(
              'Button Widgets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _incrementCounter,
                  child: const Text('Elevated Button'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined Button'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FloatingActionButton.small(
              onPressed: _incrementCounter,
              child: const Icon(Icons.add),
            ),
            const Divider(height: 30),

            // Counter Display
            const Text(
              'Counter & Icons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: Colors.green,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  'Count: $_counter',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.star,
                  color: _counter > 5 ? Colors.amber : Colors.grey,
                  size: 30,
                ),
              ],
            ),
            const Divider(height: 30),

            // Input Widgets
            const Text(
              'Input Widgets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Type here',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onChanged: (value) {
                setState(() {
                  _textFieldValue = value.isNotEmpty ? value : 'Type something...';
                });
              },
            ),
            const SizedBox(height: 10),
            Text('You typed: $_textFieldValue'),
            const Divider(height: 30),

            // Switch and Checkbox
            const Text(
              'Toggle Widgets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Switch:'),
                Switch(
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                    });
                  },
                ),
                const SizedBox(width: 20),
                const Text('Checkbox:'),
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                ),
              ],
            ),
            Text(
              _isSwitched ? 'Switch is ON! 🔛' : 'Switch is OFF 🔴',
              style: TextStyle(
                color: _isSwitched ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),

            // Slider
            const Text(
              'Slider Widget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              label: _sliderValue.round().toString(),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            Text(
              'Slider value: ${_sliderValue.round()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),

            // Container with decoration
            const Text(
              'Container & BoxDecoration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.widgets, size: 40, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'This is a fancy Container!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('With padding, border, and shadow!'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
