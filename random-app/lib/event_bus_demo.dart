import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

/// --- System Bus Built on Dart Event Loop --- ///
abstract class AppEvent {}

class IncrementEvent extends AppEvent {}
class DecrementEvent extends AppEvent {}

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _handlers = HashMap<Type, List<Function>>();

  /// Subscribe to a specific event type
  void on<T extends AppEvent>(void Function(T event) handler) {
    _handlers.putIfAbsent(T, () => []).add(handler);
  }

  /// Emit an event, processed asynchronously in the event loop
  void emit(AppEvent event) {
    // Put into event queue
    Future(() {
      final handlers = _handlers[event.runtimeType];
      if (handlers != null) {
        for (final handler in handlers) {
          handler(event); // Dispatch event
        }
      }
    });
  }

  /// Optional: Emit immediately using microtask queue (higher priority)
  void emitMicro(AppEvent event) {
    scheduleMicrotask(() {
      final handlers = _handlers[event.runtimeType];
      if (handlers != null) {
        for (final handler in handlers) {
          handler(event);
        }
      }
    });
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
      title: 'Event Loop System Bus',
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

  @override
  void initState() {
    super.initState();

    // Subscribe to events
    EventBus().on<IncrementEvent>((_) => setState(() => _counter++));
    EventBus().on<DecrementEvent>((_) => setState(() => _counter--));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Loop System Bus')),
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

