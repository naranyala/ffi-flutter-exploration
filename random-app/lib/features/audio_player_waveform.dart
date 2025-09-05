import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path/path.dart' as p;
import 'package:fftea/fftea.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const AudioVisualizerApp());
}

class AudioVisualizerApp extends StatelessWidget {
  const AudioVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Visualizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AudioVisualizerPage(),
    );
  }
}

class AudioVisualizerPage extends StatefulWidget {
  const AudioVisualizerPage({super.key});

  @override
  State<AudioVisualizerPage> createState() => _AudioVisualizerPageState();
}

class _AudioVisualizerPageState extends State<AudioVisualizerPage>
    with TickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  Float64List _fftData = Float64List(512);
  
  // Animation and timing controllers
  late AnimationController _animationController;
  Timer? _updateTimer;
  bool _isPlaying = false;
  String? _currentFileName;
  
  // FFT processor
  late FFT _fft;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _configureAudioSession();
    _initializeAnimation();
    _initializeFFT();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // Start continuous animation loop
    _animationController.repeat();
  }

  void _initializeFFT() {
    _fft = FFT(1024);
    // Initialize with empty data
    _fftData = Float64List(512);
  }

  Future<void> _configureAudioSession() async {
    final audioSession = await AudioSession.instance;
    await audioSession.configure(const AudioSessionConfiguration.music());
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
      
      if (_isPlaying) {
        _startVisualizationUpdates();
      } else {
        _stopVisualizationUpdates();
      }
    });
  }

  void _startVisualizationUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateFFTData();
    });
  }

  void _stopVisualizationUpdates() {
    _updateTimer?.cancel();
    // Gradually fade out the visualization
    _fadeOutVisualization();
  }

  void _updateFFTData() {
    if (!_isPlaying) return;

    // Generate realistic-looking frequency data
    // This simulates what real FFT data might look like
    final newData = Float64List(512);
    
    for (int i = 0; i < newData.length; i++) {
      // Create frequency response that looks more realistic
      double baseAmplitude = _generateFrequencyAmplitude(i);
      
      // Add some randomness for animation effect
      double randomFactor = 0.8 + (_random.nextDouble() * 0.4);
      
      // Apply smoothing to previous frame for more natural movement
      double smoothing = 0.3;
      double previousValue = i < _fftData.length ? _fftData[i] : 0.0;
      
      newData[i] = (baseAmplitude * randomFactor * (1 - smoothing)) + 
                   (previousValue * smoothing);
    }

    setState(() {
      _fftData = newData;
    });
  }

  double _generateFrequencyAmplitude(int frequencyBin) {
    // Simulate realistic frequency distribution
    double frequency = frequencyBin.toDouble();
    double normalizedFreq = frequency / 512.0;
    
    // Bass frequencies (0-0.1) - higher amplitude
    if (normalizedFreq < 0.1) {
      return 30.0 + (_random.nextDouble() * 40.0);
    }
    // Mid frequencies (0.1-0.4) - moderate amplitude
    else if (normalizedFreq < 0.4) {
      return 15.0 + (_random.nextDouble() * 25.0);
    }
    // High frequencies (0.4-1.0) - lower amplitude
    else {
      return 5.0 + (_random.nextDouble() * 15.0);
    }
  }

  void _fadeOutVisualization() {
    // Create a fade-out effect when music stops
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying) {
        timer.cancel();
        return;
      }
      
      bool hasData = false;
      final newData = Float64List(_fftData.length);
      
      for (int i = 0; i < _fftData.length; i++) {
        newData[i] = _fftData[i] * 0.8; // Fade factor
        if (newData[i] > 0.5) hasData = true;
      }
      
      setState(() {
        _fftData = newData;
      });
      
      // Stop fading when data is nearly zero
      if (!hasData) {
        timer.cancel();
      }
    });
  }

  Future<void> _selectAndPlayAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String filePath = file.path!;

      try {
        setState(() {
          _currentFileName = file.name;
        });
        
        await _audioPlayer.play(DeviceFileSource(filePath));
        
      } catch (e) {
        debugPrint("Error playing audio: $e");
        setState(() {
          _currentFileName = null;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentFileName = null;
      _fftData = Float64List(512);
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Visualizer'),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: Column(
          children: [
            // File info display
            if (_currentFileName != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          _isPlaying ? Icons.music_note : Icons.music_off,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _currentFileName!,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Visualizer
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _VisualizerPainter(
                          fftData: _fftData,
                          animationValue: _animationController.value,
                          isPlaying: _isPlaying,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Control buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectAndPlayAudio,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  
                  if (_currentFileName != null) ...[
                    ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    ElevatedButton.icon(
                      onPressed: _stopAudio,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
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

class _VisualizerPainter extends CustomPainter {
  final Float64List fftData;
  final double animationValue;
  final bool isPlaying;

  _VisualizerPainter({
    required this.fftData,
    required this.animationValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fftData.isEmpty) {
      _drawIdleState(canvas, size);
      return;
    }

    // Background
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.deepPurple.shade900, Colors.black87],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final numBars = (fftData.length / 4).round(); // Use fewer bars for better visibility
    final barWidth = size.width / numBars;
    final maxHeight = size.height * 0.8;

    for (int i = 0; i < numBars; i++) {
      final double magnitude = fftData[i * 4]; // Sample every 4th element
      final double normalizedHeight = (magnitude / 100.0).clamp(0.0, 1.0);
      final double barHeight = maxHeight * normalizedHeight;

      // Create gradient colors based on frequency
      final double hue = (i / numBars) * 300; // Purple to blue spectrum
      final double saturation = 0.8 + (normalizedHeight * 0.2);
      final double brightness = 0.4 + (normalizedHeight * 0.6);
      
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            HSVColor.fromAHSV(1.0, hue, saturation, brightness * 0.6).toColor(),
            HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor(),
          ],
        ).createShader(Rect.fromLTWH(
          i * barWidth,
          size.height - barHeight,
          barWidth * 0.8,
          barHeight,
        ));

      // Draw bar with rounded corners
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth + (barWidth * 0.1),
          size.height - barHeight,
          barWidth * 0.8,
          barHeight,
        ),
        const Radius.circular(2),
      );
      
      canvas.drawRRect(rect, barPaint);

      // Add glow effect for active bars
      if (normalizedHeight > 0.1) {
        final glowPaint = Paint()
          ..color = HSVColor.fromAHSV(
            0.3, hue, saturation, brightness
          ).toColor()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawRRect(rect, glowPaint);
      }
    }
  }

  void _drawIdleState(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw a simple waveform placeholder
    final path = Path();
    path.moveTo(0, size.height / 2);
    
    for (int i = 0; i < size.width.toInt(); i += 10) {
      final y = size.height / 2 + (sin(i * 0.1 + animationValue * 2 * pi) * 20);
      path.lineTo(i.toDouble(), y);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw "Select Audio" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Select an audio file to begin visualization',
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 + 40,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
