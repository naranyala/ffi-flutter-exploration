import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Manual Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => const AppManualScreen(),
              ),
            );
          },
          child: const Text("Open App Manual"),
        ),
      ),
    );
  }
}

class AppManualScreen extends StatelessWidget {
  const AppManualScreen({super.key});

  final List<Map<String, String>> sections = const [
    {"title": "Getting Started", "content": "This app helps you manage tasks efficiently. Start by creating your first project and adding tasks."},
    {"title": "Navigation", "content": "Use the bottom navigation bar to switch between Home, Tasks, and Settings. The back button always goes back."},
    {"title": "Task Management", "content": "Tap the '+' button to add tasks. Long-press to edit or delete a task."},
    {"title": "Settings", "content": "Change themes, enable notifications, and adjust synchronization preferences here."},
    {"title": "Support", "content": "If you encounter issues, visit our support page or email support@example.com."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("App Manual"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final item = sections[index];
          return ListTile(
            title: Text(item["title"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => ManualDetailScreen(
                    title: item["title"]!,
                    content: item["content"]!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManualDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const ManualDetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

