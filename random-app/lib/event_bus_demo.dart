import 'dart:async';
import 'package:flutter/material.dart';

/// --- System Bus Implementation --- ///
abstract class AppEvent {}

class IncrementEvent extends AppEvent {}
class DecrementEvent extends AppEvent {}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  final _controller = StreamController<AppEvent>.broadcast();

  EventBus._internal();
  factory EventBus() => _instance;

  // Listen for events of specific type
  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  // Emit event
  void emit(AppEvent event) {
    _controller.add(event);
  }
}

/// --- Flutter Counter App --- ///
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Bus Counter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;
  late StreamSubscription _incSub;
  late StreamSubscription _decSub;

  @override
  void initState() {
    super.initState();

    // Listen for Increment Events
    _incSub = EventBus().on<IncrementEvent>().listen((_) {
      setState(() => _counter++);
    });

    // Listen for Decrement Events
    _decSub = EventBus().on<DecrementEvent>().listen((_) {
      setState(() => _counter--);
    });
  }

  @override
  void dispose() {
    _incSub.cancel();
    _decSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Bus Counter')),
      body: Center(
        child: Text('Counter: $_counter', style: const TextStyle(fontSize: 32)),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => EventBus().emit(IncrementEvent()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => EventBus().emit(DecrementEvent()),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

