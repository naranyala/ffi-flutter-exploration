import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fullscreen Modal Demo',
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
                fullscreenDialog: true, // makes it modal-like
                builder: (context) => const FullscreenModal(),
              ),
            );
          },
          child: const Text("Open Fullscreen Modal"),
        ),
      ),
    );
  }
}

class FullscreenModal extends StatelessWidget {
  const FullscreenModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("Fullscreen Modal"),
      ),
      body: const Center(
        child: Text("This is fullscreen with back navigation"),
      ),
    );
  }
}

