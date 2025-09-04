import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Textarea with Scroll & Fullscreen',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextAreaWithFullscreen(),
          ),
        ),
      ),
    );
  }
}

class TextAreaWithFullscreen extends StatefulWidget {
  const TextAreaWithFullscreen({super.key});

  @override
  State<TextAreaWithFullscreen> createState() => _TextAreaWithFullscreenState();
}

class _TextAreaWithFullscreenState extends State<TextAreaWithFullscreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _controller.text = List.generate(
      20,
      (i) => "This is dummy line number ${i + 1}. "
          "You can scroll inside this text area to see the scrollbar in action.",
    ).join("\n");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  Widget _buildTextArea({required bool fullscreen}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          // Scrollable text field
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  right: 40, left: 8, top: 8, bottom: 8), // space for button
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Fullscreen toggle button inside the text area
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                size: 20,
              ),
              onPressed: _toggleFullscreen,
              tooltip: fullscreen ? 'Exit fullscreen' : 'Enter fullscreen',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullscreen) {
      return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildTextArea(fullscreen: true),
          ),
        ),
      );
    }

    return _buildTextArea(fullscreen: false);
  }
}

