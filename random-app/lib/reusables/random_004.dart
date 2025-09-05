import 'package:flutter/material.dart';

void main() => runApp(const WidgetPlayground());

class WidgetPlayground extends StatelessWidget {
  const WidgetPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🎪 Flutter Widget Playground'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: const WidgetDemo(),
      ),
    );
  }
}

class WidgetDemo extends StatefulWidget {
  const WidgetDemo({super.key});

  @override
  State<WidgetDemo> createState() => _WidgetDemoState();
}

class _WidgetDemoState extends State<WidgetDemo> {
  int _counter = 0;
  double _sliderValue = 50;
  bool _isSwitched = false;
  bool _isChecked = true;
  String _text = 'Hello Flutter!';
  int _selectedIndex = 0;

  void _incrementCounter() => setState(() => _counter++);
  void _decrementCounter() => setState(() => _counter--);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counter Section
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('🔢 Counter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('$_counter', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.small(
                        onPressed: _decrementCounter,
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton.small(
                        onPressed: _incrementCounter,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Toggle Widgets
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔘 Toggles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Switch:'),
                      Switch(
                        value: _isSwitched,
                        onChanged: (value) => setState(() => _isSwitched = value),
                      ),
                      Text(_isSwitched ? 'ON' : 'OFF', style: TextStyle(
                        color: _isSwitched ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Checkbox:'),
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) => setState(() => _isChecked = value!),
                      ),
                      Text(_isChecked ? 'CHECKED' : 'UNCHECKED', style: TextStyle(
                        color: _isChecked ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Slider
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎚️ Slider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    label: _sliderValue.round().toString(),
                    onChanged: (value) => setState(() => _sliderValue = value),
                  ),
                  Text('Value: ${_sliderValue.round()}', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Text Input
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📝 Text Input', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Type something',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                    onChanged: (value) => setState(() => _text = value.isNotEmpty ? value : 'Hello Flutter!'),
                  ),
                  const SizedBox(height: 10),
                  Text('You typed: "$_text"', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Buttons
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎯 Buttons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Elevated Button pressed!')),
                        ),
                        child: const Text('Elevated'),
                      ),
                      OutlinedButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Outlined Button pressed!')),
                        ),
                        child: const Text('Outlined'),
                      ),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Text Button pressed!')),
                        ),
                        child: const Text('Text'),
                      ),
                      IconButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Icon Button pressed!')),
                        ),
                        icon: const Icon(Icons.favorite, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Navigation
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🧭 Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  NavigationBar(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                      NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                      NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Selected tab: $_selectedIndex', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Progress Indicators
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: _sliderValue / 100),
                  const SizedBox(height: 10),
                  CircularProgressIndicator(value: _sliderValue / 100),
                  const SizedBox(height: 10),
                  Text('Progress: ${(_sliderValue / 100 * 100).round()}%', style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
