import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Counter',
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int counter = 0;

  // Computed/derived value
  int get doubledValue => counter * 2;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  void decrementCounter() {
    setState(() {
      counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Counter:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '$counter',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              'Doubled Value:',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            Text(
              '$doubledValue',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: decrementCounter,
                  child: Text('- Decrease'),
                ),
                ElevatedButton(
                  onPressed: incrementCounter,
                  child: Text('+ Increase'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
