import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connected Timeline',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ConnectedTimelinePage(),
    );
  }
}

class Task {
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;

  Task({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
  });
}

class ConnectedTimelinePage extends StatelessWidget {
  const ConnectedTimelinePage({super.key});

  List<Task> get tasks => [
        Task(
          title: "Research",
          description: "Gather requirements and analyze the market.",
          start: DateTime(2025, 8, 1),
          end: DateTime(2025, 8, 10),
        ),
        Task(
          title: "Design",
          description: "Create wireframes and design mockups.",
          start: DateTime(2025, 8, 11),
          end: DateTime(2025, 8, 20),
        ),
        Task(
          title: "Development",
          description: "Implement core features and logic.",
          start: DateTime(2025, 8, 21),
          end: DateTime(2025, 9, 10),
        ),
        Task(
          title: "Testing",
          description: "QA and bug fixing before release.",
          start: DateTime(2025, 9, 11),
          end: DateTime(2025, 9, 20),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.MMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Task Timeline"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Continuous vertical line
            Positioned(
              left: 40,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final dateRange =
                    "${dateFormat.format(task.start)} → ${dateFormat.format(task.end)}";

                return Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator area
                      SizedBox(
                        width: 80,
                        child: Column(
                          children: [
                            // Dot indicator aligned with the line
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(1, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Task card
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(index),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      task.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Colors.indigo,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.indigo.shade600,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      dateRange,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.indigo.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int index) {
    if (index == 0) return Colors.green;
    if (index == tasks.length - 1) return Colors.orange;
    return Colors.indigo;
  }
}

