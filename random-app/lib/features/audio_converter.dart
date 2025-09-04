import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class AudioConverterPage extends StatefulWidget {
  const AudioConverterPage({super.key});

  @override
  State<AudioConverterPage> createState() => _AudioConverterPageState();
}

class _AudioConverterPageState extends State<AudioConverterPage> {
  String? inputPath;
  String? outputPath;
  String sourceFormat = "MP3";
  String targetFormat = "WAV";
  String status = "Idle";

  final List<String> formats = ["MP3", "WAV", "AAC", "FLAC"];

  /// Swap source and target
  void swapFormats() {
    setState(() {
      final temp = sourceFormat;
      sourceFormat = targetFormat;
      targetFormat = temp;
    });
  }

  /// Pick input audio file
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        inputPath = result.files.single.path!;
        sourceFormat = inputPath!.split('.').last.toUpperCase();
      });
    }
  }

  /// Run conversion via ffmpeg
  Future<void> convertAudio() async {
    if (inputPath == null) {
      setState(() => status = "Please pick a file first.");
      return;
    }

    final outPath = inputPath!.replaceAll(
      RegExp(r'\.\w+$'),
      ".${targetFormat.toLowerCase()}",
    );

    setState(() {
      status = "Converting...";
      outputPath = outPath;
    });

    final command = "-i \"$inputPath\" \"$outPath\"";
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (returnCode.isValueSuccess()) {
      setState(() => status = "✅ Conversion complete: $outPath");
    } else {
      setState(() => status = "❌ Conversion failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Converter")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pick file
              ElevatedButton.icon(
                icon: const Icon(Icons.audio_file),
                label: const Text("Pick Audio File"),
                onPressed: pickFile,
              ),
              if (inputPath != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Input: $inputPath"),
                ),

              const SizedBox(height: 20),

              // Source format
              Text("Source: $sourceFormat", style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 10),

              // Swap button
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.swap_vert, color: Colors.black87),
                onPressed: swapFormats,
              ),

              // Target format (dropdown)
              DropdownButton<String>(
                value: targetFormat,
                items: formats.map((format) {
                  return DropdownMenuItem(
                    value: format,
                    child: Text(format),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => targetFormat = val);
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Start Convert"),
                onPressed: convertAudio,
              ),

              const SizedBox(height: 20),

              // Status message
              Text(
                status,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

