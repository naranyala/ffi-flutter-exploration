import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
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
      title: 'Speaker Visualizer',
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

class _AudioVisualizerPageState extends State<AudioVisualizerPage> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  Float64List _fftData = Float64List(64); // Reduced size for better performance

  late AnimationController _animationController;
  late AnimationController _scaleController;
  Timer? _updateTimer;

  bool _isPlaying = false;
  String? _fileName;

  double _currentScale = 1.0;
  List<double> _audioLevels = List.filled(64, 0.0); // Store audio levels for visualization

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() => setState(() => _currentScale = _scaleController.value));

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
      _updateFFT();
      _updateVisualScale();
    });
  }

  void _stopUpdates() {
    _updateTimer?.cancel();
    _scaleController.animateTo(1.0, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
  }

  void _updateFFT() {
    // Simulate audio data with a more realistic pattern
    final data = Float64List(64);
    
    // Create a base frequency pattern that simulates music
    for (int i = 0; i < data.length; i++) {
      // Different frequency bands respond differently
      double baseLevel;
      if (i < 10) {
        // Bass frequencies - slower changes
        baseLevel = 20 + 15 * sin(_animationController.value * 2 * pi + i * 0.2);
      } else if (i < 30) {
        // Mid frequencies - more active
        baseLevel = 15 + 10 * sin(_animationController.value * 4 * pi + i * 0.3);
      } else {
        // High frequencies - very active
        baseLevel = 10 + 8 * sin(_animationController.value * 6 * pi + i * 0.4);
      }
      
      // Add some randomness to make it look more natural
      double noise = 0.8 + _random.nextDouble() * 0.4;
      
      // Smooth transitions with previous values
      double prev = i < _audioLevels.length ? _audioLevels[i] * 0.4 : 0;
      
      data[i] = baseLevel * noise + prev;
      _audioLevels[i] = data[i]; // Store for visualization
    }
    
    setState(() {
      _fftData = data;
    });
  }

  void _updateVisualScale() {
    // Calculate average power from the bass frequencies (first 10 bins)
    double power = _fftData.take(10).map((v) => v * v).reduce((a, b) => a + b) / 10;
    double target = 1.0 + sqrt(power) / 40; // Adjusted scaling factor
    
    // Limit the scale to reasonable values
    target = target.clamp(1.0, 1.8);

    _scaleController.animateTo(
      target,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
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
    _scaleController.dispose();
    _audioPlayer.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speaker Bounce')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.black],
          ),
        ),
        child: Column(
          children: [
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Icon(_isPlaying ? Icons.music_note : Icons.music_off, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fileName!,
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Speaker Visualizer
            Expanded(
              child: CustomPaint(
                painter: _SpeakerPainter(
                  scale: _currentScale,
                  isPlaying: _isPlaying,
                  animationValue: _animationController.value,
                  fftData: _fftData,
                ),
                size: Size.infinite,
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickAudio,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Pick Audio'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  ),
                  if (_fileName != null) ...[
                    ElevatedButton.icon(
                      onPressed: _toggle,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: _stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeakerPainter extends CustomPainter {
  final double scale;
  final bool isPlaying;
  final double animationValue;
  final Float64List fftData;

  _SpeakerPainter({
    required this.scale, 
    required this.isPlaying, 
    required this.animationValue,
    required this.fftData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) * 0.25;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.deepPurple, Colors.black],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    if (!isPlaying) {
      _drawIdle(canvas, size);
      return;
    }

    // Draw frequency bars around the speaker
    _drawFrequencyBars(canvas, size, center);

    // Outer rim (static)
    canvas.drawCircle(center, baseRadius * 1.4, Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10);

    // Glow shadow
    canvas.drawCircle(center, baseRadius * scale, Paint()
      ..color = Colors.deepPurple.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Main speaker cone
    final speakerPaint = Paint()
      ..shader = RadialGradient(colors: [
        Colors.deepPurple.shade200,
        Colors.deepPurple.shade700,
        Colors.deepPurple.shade900,
      ]).createShader(
        Rect.fromCircle(center: center, radius: baseRadius * scale),
      );
    canvas.drawCircle(center, baseRadius * scale, speakerPaint);

    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(
      Offset(center.dx - baseRadius * 0.3 * scale, center.dy - baseRadius * 0.3 * scale),
      baseRadius * 0.2 * scale,
      highlightPaint,
    );
  }

  void _drawFrequencyBars(Canvas canvas, Size size, Offset center) {
    final int barCount = fftData.length;
    final double maxRadius = min(size.width, size.height) * 0.4;
    final double barWidth = (2 * pi * maxRadius) / barCount * 0.7;
    
    for (int i = 0; i < barCount; i++) {
      final double angle = 2 * pi * i / barCount;
      final double barHeight = fftData[i] * 1.5;
      
      final Paint barPaint = Paint()
        ..color = Colors.primaries[i % Colors.primaries.length].withOpacity(0.7)
        ..style = PaintingStyle.fill;
      
      final Offset start = Offset(
        center.dx + maxRadius * cos(angle),
        center.dy + maxRadius * sin(angle),
      );
      
      final Offset end = Offset(
        center.dx + (maxRadius + barHeight) * cos(angle),
        center.dy + (maxRadius + barHeight) * sin(angle),
      );
      
      canvas.drawLine(start, end, barPaint..strokeWidth = barWidth);
    }
  }

  void _drawIdle(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) * 0.2;

    final idlePaint = Paint()..color = Colors.deepPurple.withOpacity(0.5);
    canvas.drawCircle(center, baseRadius, idlePaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Pick Audio',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      center.dx - textPainter.width / 2,
      center.dy + baseRadius + 10,
    ));
  }

  @override
  bool shouldRepaint(covariant _SpeakerPainter oldDelegate) {
    return oldDelegate.scale != scale ||
           oldDelegate.isPlaying != isPlaying ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.fftData != fftData;
  }
}
