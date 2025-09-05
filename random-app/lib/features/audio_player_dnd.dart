import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const AudioVisualizerApp());
}

class AudioVisualizerApp extends StatelessWidget {
  const AudioVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linux Audio Visualizer',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const AudioVisualizerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AudioVisualizerPage extends StatefulWidget {
  const AudioVisualizerPage({super.key});

  @override
  State<AudioVisualizerPage> createState() => _AudioVisualizerPageState();
}

class _AudioVisualizerPageState extends State<AudioVisualizerPage> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  
  late AnimationController _animationController;
  Timer? _updateTimer;

  bool _isPlaying = false;
  String? _fileName;
  double _audioLevel = 0.0;
  double _targetLevel = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {
          _audioLevel = _audioLevel + (_targetLevel - _audioLevel) * _animationController.value;
        });
      });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
      if (_isPlaying) {
        _startUpdates();
      } else {
        _stopUpdates();
      }
    });
  }

  void _startUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateAudioLevel();
    });
  }

  void _stopUpdates() {
    _updateTimer?.cancel();
    _targetLevel = 0.0;
    _animationController.forward(from: 0.0);
  }

  void _updateAudioLevel() {
    // Simulate audio levels with a more natural pattern
    final double baseLevel = 0.3 + 0.7 * _random.nextDouble();
    final double smoothLevel = _targetLevel * 0.6 + baseLevel * 0.4;
    
    setState(() {
      _targetLevel = smoothLevel;
    });
    
    _animationController.forward(from: 0.0);
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
      });

      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(result.files.single.path!));
    }
  }

  Future<void> _toggle() => _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() => _fileName = null);
    _stopUpdates();
  }

  // Simulate drag and drop with button press
  void _simulateDragStart() {
    setState(() => _isDragging = true);
    // Simulate a short drag operation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isDragging = false);
        _pickAudioFile();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double circleSize = 150.0 + 100.0 * _audioLevel;
    final Color circleColor = Colors.primaries[((_audioLevel * 10) % Colors.primaries.length).floor()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linux Audio Visualizer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: _fileName == null ? _simulateDragStart : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                _isDragging ? Colors.blueAccent.withOpacity(0.5) : Colors.deepPurple.withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Visualizer Circle with drag indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor.withOpacity(0.7),
                      boxShadow: [
                        BoxShadow(
                          color: circleColor.withOpacity(0.5),
                          blurRadius: 20.0 + 30.0 * _audioLevel,
                          spreadRadius: 5.0 * _audioLevel,
                        ),
                      ],
                    ),
                    child: _isPlaying 
                      ? Icon(
                          Icons.music_note,
                          size: 40.0,
                          color: Colors.white.withOpacity(0.8),
                        )
                      : _fileName == null
                        ? Icon(
                            Icons.upload_file,
                            size: 40.0,
                            color: Colors.white.withOpacity(0.5),
                          )
                        : Icon(
                            Icons.music_off,
                            size: 40.0,
                            color: Colors.white.withOpacity(0.5),
                          ),
                  ),
                  
                  // Dragging overlay
                  if (_isDragging)
                    Container(
                      width: circleSize * 1.2,
                      height: circleSize * 1.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 3.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Icon(
                        Icons.file_download,
                        size: 50.0,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Instructions or file name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _fileName != null
                  ? Text(
                      _fileName!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : Column(
                      children: [
                        Text(
                          'Click here to select an audio file',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported formats: MP3, WAV, OGG',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Note: Direct file drag & drop is not supported on Linux',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              ),
              
              const SizedBox(height: 30),
              
              // Controls - Fixed the conditional rendering issue
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _fileName != null
                  ? [
                      // Play/Pause Button
                      FloatingActionButton(
                        onPressed: _toggle,
                        backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // Stop Button
                      FloatingActionButton(
                        onPressed: _stop,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.stop),
                      ),
                    ]
                  : [
                      // Select file button as alternative
                      ElevatedButton.icon(
                        onPressed: _pickAudioFile,
                        icon: const Icon(Icons.audio_file),
                        label: const Text('Select Audio File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
