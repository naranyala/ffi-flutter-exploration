// flutter_srt_import_export.dart
// Single-file Flutter app demonstrating import/export of SRT files (lyrics)
// Add these dependencies to your pubspec.yaml:
//   file_picker: ^5.2.7
//   path_provider: ^2.0.12
// (Replace versions with the latest compatible ones.)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRT Import / Export',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SrtEditorPage(),
    );
  }
}

class LyricLine {
  int index;
  Duration start;
  Duration end;
  String text;

  LyricLine({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });
}

class SrtEditorPage extends StatefulWidget {
  const SrtEditorPage({super.key});

  @override
  State<SrtEditorPage> createState() => _SrtEditorPageState();
}

class _SrtEditorPageState extends State<SrtEditorPage> {
  List<LyricLine> _lyrics = [];
  String? _loadedFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SRT Import / Export'),
        actions: [
          IconButton(
            tooltip: 'Import .srt',
            icon: const Icon(Icons.folder_open),
            onPressed: _importSrt,
          ),
          IconButton(
            tooltip: 'Export .srt',
            icon: const Icon(Icons.save),
            onPressed: _lyrics.isEmpty ? null : _exportSrt,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  _loadedFilePath == null
                      ? 'No file loaded'
                      : 'Loaded: ${_loadedFilePath!.split(Platform.pathSeparator).last}',
                  style: const TextStyle(fontSize: 14),
                )),
                ElevatedButton.icon(
                  onPressed: _addEmptyLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add line'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _lyrics.isEmpty ? null : _exportSrt,
        icon: const Icon(Icons.upload_file),
        label: const Text('Export SRT'),
      ),
    );
  }

  Widget _buildList() {
    if (_lyrics.isEmpty) {
      return const Center(child: Text('No lyrics. Import an .srt or add lines.'));
    }

    return ReorderableListView.builder(
      itemCount: _lyrics.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _lyrics.removeAt(oldIndex);
          _lyrics.insert(newIndex, item);
          _reindex();
        });
      },
      itemBuilder: (context, idx) {
        final line = _lyrics[idx];
        return Card(
          key: ValueKey(line.index),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${line.index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTimeField(
                              initial: _formatDuration(line.start),
                              hint: 'start (HH:MM:SS,mmm)',
                              onChanged: (v) {
                                final d = _tryParseDuration(v);
                                if (d != null) setState(() => line.start = d);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('-->'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildTimeField(
                              initial: _formatDuration(line.end),
                              hint: 'end (HH:MM:SS,mmm)',
                              onChanged: (v) {
                                final d = _tryParseDuration(v);
                                if (d != null) setState(() => line.end = d);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _lyrics.removeAt(idx);
                          _reindex();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  controller: TextEditingController(text: line.text),
                  maxLines: null,
                  onChanged: (v) => line.text = v,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeField({required String initial, required String hint, required void Function(String) onChanged}) {
    final controller = TextEditingController(text: initial);
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder(), isDense: true),
      onSubmitted: onChanged,
      onChanged: (_) {},
    );
  }

  Future<void> _importSrt() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt'],
      );
      if (result == null) return; // user cancelled
      final path = result.files.single.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      final parsed = _parseSrt(content);
      setState(() {
        _lyrics = parsed;
        _loadedFilePath = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SRT imported')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  List<LyricLine> _parseSrt(String content) {
    final lines = content.replaceAll('\r\n', '\n').split('\n');
    final List<LyricLine> result = [];
    int i = 0;
    while (i < lines.length) {
      final raw = lines[i].trim();
      if (raw.isEmpty) {
        i++;
        continue;
      }

      // parse index
      final idx = int.tryParse(raw) ?? (result.length + 1);
      i++;

      // parse times
      if (i >= lines.length) break;
      final timeLine = lines[i].trim();
      i++;
      final times = timeLine.split(RegExp(r'\s+-->\s+'));
      Duration start = Duration.zero;
      Duration end = Duration.zero;
      if (times.length >= 2) {
        final s = _tryParseDuration(times[0]);
        final e = _tryParseDuration(times[1]);
        if (s != null) start = s;
        if (e != null) end = e;
      }

      // collect text
      final buffer = StringBuffer();
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        buffer.writeln(lines[i]);
        i++;
      }

      result.add(LyricLine(index: idx, start: start, end: end, text: buffer.toString().trim()));

      // skip the blank line
      i++;
    }

    // ensure indices are sequential
    for (var j = 0; j < result.length; j++) {
      result[j].index = j + 1;
    }

    return result;
  }

  Duration? _tryParseDuration(String time) {
    // Accept formats: HH:MM:SS,mmm  or H:MM:SS,mmm or MM:SS,mmm
    final t = time.trim();
    final regex = RegExp(r"(?:(\d{1,2}):)?(\d{1,2}):(\d{1,2})[,\.](\d{1,3})");
    final m = regex.firstMatch(t);
    if (m == null) return null;
    final g1 = m.group(1); // hours (optional)
    final hours = g1 != null ? int.parse(g1) : 0;
    final minutes = int.parse(m.group(2)!);
    final seconds = int.parse(m.group(3)!);
    var millis = int.parse(m.group(4)!);
    if (m.group(4)!.length == 1) millis *= 100;
    if (m.group(4)!.length == 2) millis *= 10;
    return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: millis);
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final millis = d.inMilliseconds.remainder(1000);
    return '${two(hours)}:${two(minutes)}:${two(seconds)},${three(millis)}';
  }

  Future<void> _exportSrt() async {
    try {
      final srt = _buildSrtContent(_lyrics);
      final dir = await getApplicationDocumentsDirectory();
      final outFile = File('${dir.path}${Platform.pathSeparator}lyrics_export.srt');
      await outFile.writeAsString(srt);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to ${outFile.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  String _buildSrtContent(List<LyricLine> list) {
    final buffer = StringBuffer();
    for (var i = 0; i < list.length; i++) {
      final line = list[i];
      buffer.writeln('${i + 1}');
      buffer.writeln('${_formatDuration(line.start)} --> ${_formatDuration(line.end)}');
      buffer.writeln(line.text);
      buffer.writeln();
    }
    return buffer.toString();
  }

  void _addEmptyLine() {
    setState(() {
      final lastEnd = _lyrics.isNotEmpty ? _lyrics.last.end : Duration.zero;
      final defaultDuration = const Duration(seconds: 3);
      _lyrics.add(LyricLine(
        index: _lyrics.length + 1,
        start: lastEnd,
        end: lastEnd + defaultDuration,
        text: 'New lyric',
      ));
    });
  }

  void _reindex() {
    for (var i = 0; i < _lyrics.length; i++) {
      _lyrics[i].index = i + 1;
    }
  }
}

