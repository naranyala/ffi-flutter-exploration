import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class LyricEntry {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  LyricEntry({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });

  LyricEntry copyWith({
    int? index,
    Duration? start,
    Duration? end,
    String? text,
  }) {
    return LyricEntry(
      index: index ?? this.index,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
    );
  }

  @override
  String toString() {
    String formatTime(Duration d) {
      String two(int n) => n.toString().padLeft(2, '0');
      String three(int n) => n.toString().padLeft(3, '0');
      return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)},${three(d.inMilliseconds % 1000)}";
    }
    return "$index\n${formatTime(start)} --> ${formatTime(end)}\n$text\n";
  }
}

List<LyricEntry> parseSrt(String content) {
  final lines = content.split(RegExp(r'\r?\n'));
  final entries = <LyricEntry>[];
  int i = 0;

  while (i < lines.length) {
    // Skip empty lines
    if (lines[i].trim().isEmpty) {
      i++;
      continue;
    }

    // Parse index
    int index = int.tryParse(lines[i].trim()) ?? 0;
    i++;

    // Check bounds and parse times
    if (i >= lines.length) break;
    final times = lines[i].split('-->');
    if (times.length < 2) {
      i++;
      continue;
    }

    Duration parseDuration(String s) {
      try {
        final parts = s.trim().split(RegExp(r'[:,]'));
        if (parts.length < 4) return Duration.zero;
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(parts[2]),
          milliseconds: int.parse(parts[3]),
        );
      } catch (e) {
        return Duration.zero;
      }
    }

    final start = parseDuration(times[0]);
    final end = parseDuration(times[1]);
    i++;

    // Parse text lines
    final buffer = StringBuffer();
    while (i < lines.length && lines[i].trim().isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(lines[i]);
      i++;
    }

    if (buffer.isNotEmpty) {
      entries.add(LyricEntry(
        index: index,
        start: start,
        end: end,
        text: buffer.toString(),
      ));
    }
  }

  return entries;
}

String exportSrt(List<LyricEntry> entries) {
  return entries.map((e) => e.toString()).join("\n");
}

class TimeEditor extends StatefulWidget {
  final Duration initialValue;
  final Function(Duration) onChanged;

  const TimeEditor({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatDuration(widget.initialValue));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)},${three(d.inMilliseconds % 1000)}";
  }

  Duration _parseDuration(String s) {
    try {
      final parts = s.trim().split(RegExp(r'[:,]'));
      if (parts.length < 4) return widget.initialValue;
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
        milliseconds: int.parse(parts[3]),
      );
    } catch (e) {
      return widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextFormField(
        controller: _controller,
        style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          final duration = _parseDuration(value);
          widget.onChanged(duration);
        },
        onEditingComplete: () {
          // Reformat the text when editing is complete
          final duration = _parseDuration(_controller.text);
          _controller.text = _formatDuration(duration);
        },
      ),
    );
  }
}

class LyricsEditor extends StatefulWidget {
  const LyricsEditor({super.key});

  @override
  _LyricsEditorState createState() => _LyricsEditorState();
}

class _LyricsEditorState extends State<LyricsEditor> {
  List<LyricEntry> entries = [];
  bool _hasUnsavedChanges = false;

  void _markAsModified() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> importSrt() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['srt'],
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        setState(() {
          entries = parseSrt(content);
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imported ${entries.length} entries")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error importing file: $e")),
      );
    }
  }

  Future<void> exportSrtFile() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save SRT file',
        fileName: 'exported.srt',
        type: FileType.custom,
        allowedExtensions: ['srt'],
      );
      if (result != null) {
        final file = File(result);
        await file.writeAsString(exportSrt(entries));
        setState(() {
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Exported to ${file.path}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error exporting file: $e")),
      );
    }
  }

  void _addNewEntry() {
    final newIndex = entries.length + 1;
    final lastEnd = entries.isNotEmpty ? entries.last.end : Duration.zero;
    
    setState(() {
      entries.add(LyricEntry(
        index: newIndex,
        start: lastEnd,
        end: lastEnd + Duration(seconds: 3),
        text: "",
      ));
      _markAsModified();
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
      // Renumber entries
      for (int i = 0; i < entries.length; i++) {
        entries[i] = entries[i].copyWith(index: i + 1);
      }
      _markAsModified();
    });
  }

  void _updateEntry(int index, LyricEntry newEntry) {
    setState(() {
      entries[index] = newEntry;
      _markAsModified();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SRT Editor${_hasUnsavedChanges ? ' *' : ''}"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.file_open),
            onPressed: importSrt,
            tooltip: 'Import SRT file',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: entries.isNotEmpty ? exportSrtFile : null,
            tooltip: 'Export SRT file',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewEntry,
            tooltip: 'Add new entry',
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.subtitles_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No SRT file loaded',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Import an SRT file to start editing'),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "#${entry.index}",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.delete, size: 20),
                              onPressed: () => _deleteEntry(index),
                              color: Colors.red,
                              padding: EdgeInsets.all(4),
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            TimeEditor(
                              initialValue: entry.start,
                              onChanged: (newStart) {
                                _updateEntry(index, entry.copyWith(start: newStart));
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("→"),
                            ),
                            TimeEditor(
                              initialValue: entry.end,
                              onChanged: (newEnd) {
                                _updateEntry(index, entry.copyWith(end: newEnd));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          initialValue: entry.text,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "Enter subtitle text...",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                          onChanged: (value) {
                            _updateEntry(index, entry.copyWith(text: value));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SRT Editor',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: LyricsEditor(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
