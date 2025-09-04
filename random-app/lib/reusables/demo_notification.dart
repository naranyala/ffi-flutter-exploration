import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MultiNotificationDemo(),
    );
  }
}

class MultiNotificationDemo extends StatefulWidget {
  const MultiNotificationDemo({super.key});

  @override
  State<MultiNotificationDemo> createState() => _MultiNotificationDemoState();
}

class _MultiNotificationDemoState extends State<MultiNotificationDemo> {
  final List<_NotificationData> _notifications = [];
  static const Duration _displayDuration = Duration(seconds: 3);

  void _addNotification() {
    final id = DateTime.now().millisecondsSinceEpoch;
    final notification = _NotificationData(
      id: id,
      message: '🔔 Notification #${_notifications.length + 1}',
    );

    setState(() => _notifications.add(notification));

    // Auto-remove after timeout
    Timer(_displayDuration, () {
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
      }
    });
  }

  void _removeNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: ElevatedButton(
              onPressed: _addNotification,
              child: const Text('Show Notification'),
            ),
          ),

          // Notifications overlay
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Column(
              children: _notifications.map((n) {
                return Container(
                  key: ValueKey(n.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: ListTile(
                    title: Text(n.message),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeNotification(n.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationData {
  final int id;
  final String message;
  _NotificationData({required this.id, required this.message});
}

