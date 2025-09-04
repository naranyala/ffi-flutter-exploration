import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(const MarkdownEditorApp());
}

class MarkdownEditorApp extends StatelessWidget {
  const MarkdownEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MarkdownEditorScreen(),
    );
  }
}

class MarkdownEditorScreen extends StatefulWidget {
  const MarkdownEditorScreen({Key? key}) : super(key: key);

  @override
  _MarkdownEditorScreenState createState() => _MarkdownEditorScreenState();
}

class _MarkdownEditorScreenState extends State<MarkdownEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize with sample Markdown
    _controller.text = '# Welcome to Markdown Editor\n\nWrite your **Markdown** here!\n\n- List item 1\n- List item 2';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleView() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Editor'),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            tooltip: _isPreviewMode ? 'Edit' : 'Preview',
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isPreviewMode
            ? Markdown(
                data: _controller.text,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  p: const TextStyle(fontSize: 16),
                  listBullet: const TextStyle(fontSize: 16),
                ),
              )
            : TextField(
                controller: _controller,
                maxLines: null, // Allow multi-line input
                expands: true, // Expand to fill available space
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your Markdown here...',
                ),
                style: const TextStyle(
                  fontFamily: 'monospace', // Mimic code-like input
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
