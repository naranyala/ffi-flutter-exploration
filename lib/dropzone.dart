import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DropzoneDemo(),
  ));
}

class DropzoneDemo extends StatefulWidget {
  const DropzoneDemo({super.key});

  @override
  State<DropzoneDemo> createState() => _DropzoneDemoState();
}

class _DropzoneDemoState extends State<DropzoneDemo> {
  late DropzoneViewController controller;
  String message = 'Drop files here';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Dropzone')),
      body: Stack(
        children: [
          // Dropzone area
          DropzoneView(
            onCreated: (ctrl) => controller = ctrl,
            onDrop: _handleDrop,
            onHover: () => setState(() => message = 'Release to upload'),
            onLeave: () => setState(() => message = 'Drop files here'),
          ),

          // Overlay UI
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDrop(dynamic event) async {
    final name = await controller.getFilename(event);
    final size = await controller.getFileSize(event);
    final mime = await controller.getFileMIME(event);

    setState(() {
      message = 'Dropped: $name\nSize: $size bytes\nType: $mime';
    });

    // If you want to read file bytes:
    // final bytes = await controller.getFileData(event);
    // Do something with bytes...
  }
}

