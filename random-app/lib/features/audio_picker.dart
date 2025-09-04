// flutter_audio_metadata.dart
// Single-file Flutter app demonstrating audio file picker with metadata details
// Add dependencies to pubspec.yaml:
//   file_picker: ^5.2.7
//   just_audio: ^0.9.36
//   flutter_media_metadata: ^1.0.1

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

void main() {
  runApp(const AudioMetadataApp());
}

class AudioMetadataApp extends StatelessWidget {
  const AudioMetadataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Metadata Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AudioMetadataPage(),
    );
  }
}

class AudioMetadataPage extends StatefulWidget {
  const AudioMetadataPage({super.key});

  @override
  State<AudioMetadataPage> createState() => _AudioMetadataPageState();
}

class _AudioMetadataPageState extends State<AudioMetadataPage> {
  Metadata? _metadata;
  String? _filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Metadata Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Pick Audio File',
            onPressed: _pickAudioFile,
          ),
        ],
      ),
      body: _metadata == null
          ? const Center(child: Text('Pick an audio file to view metadata'))
          : _buildMetadataDetails(),
    );
  }

  Widget _buildMetadataDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_metadata!.albumArt != null)
            Center(
              child: Image.memory(
                _metadata!.albumArt!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text('File: ${_filePath ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          Text('Title: ${_metadata!.trackName ?? 'Unknown'}'),
          Text('Artist: ${_metadata!.artistName ?? 'Unknown'}'),
          Text('Album: ${_metadata!.albumName ?? 'Unknown'}'),
          Text('Genre: ${_metadata!.genre ?? 'Unknown'}'),
          Text('Year: ${_metadata!.year ?? 'Unknown'}'),
          Text('Track #: ${_metadata!.trackNumber ?? 'Unknown'}'),
          Text('Disc #: ${_metadata!.discNumber ?? 'Unknown'}'),
          Text('Duration: ${_formatDuration(_metadata!.trackDuration ?? 0)}'),
        ],
      ),
    );
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'flac'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final metadata = await MetadataRetriever.fromFile(file);

      setState(() {
        _metadata = metadata;
        _filePath = path;
      });
    }
  }

  String _formatDuration(int milliseconds) {
    final seconds = (milliseconds / 1000).truncate();
    final minutes = (seconds / 60).truncate();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

