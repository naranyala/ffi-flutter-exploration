import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
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
      title: 'Simple Audio Visualizer',
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {
          // Manually interpolate between values instead of using lerpDouble
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

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null) return;

    PlatformFile file = result.files.first;
    setState(() => _fileName = file.name);

    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(file.path!));
  }

  Future<void> _toggle() => _isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() => _fileName = null);
    _stopUpdates();
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
        title: const Text('Audio Pulse'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.deepPurple.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visualizer Circle
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
                : Icon(
                    Icons.music_off,
                    size: 40.0,
                    color: Colors.white.withOpacity(0.5),
                  ),
            ),
            
            const SizedBox(height: 40),
            
            // File name
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _fileName!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pick Audio Button
                FloatingActionButton(
                  onPressed: _pickAudio,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.audio_file),
                ),
                
                const SizedBox(width: 20),
                
                if (_fileName != null) ...[
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
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
