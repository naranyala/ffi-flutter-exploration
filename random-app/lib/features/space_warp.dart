import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Added: Required for RenderRepaintBoundary
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

void main() => runApp(const WarpApp());

class WarpApp extends StatelessWidget {
  const WarpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WarpScreen());
  }
}

class WarpScreen extends StatefulWidget {
  const WarpScreen({super.key});

  @override
  State<WarpScreen> createState() => _WarpScreenState();
}

class _WarpScreenState extends State<WarpScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = List.generate(200, (_) => Star());
  final GlobalKey repaintKey = GlobalKey();

  bool _isExporting = false;
  int _frameCount = 0;
  final int _totalFrames = 60; // 6 seconds at 10 FPS
  final double _frameDuration = 1.0 / 10.0; // 10 FPS = 0.1 seconds per frame

  @override
  void initState() {
    super.initState();
    // Fixed: Match animation duration to export duration (6 seconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..addListener(() {
        if (mounted) {
          setState(() {
            for (var star in _stars) {
              star.update();
            }
          });
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureFrame(int index) async {
    try {
      // Add small delay to ensure frame is rendered
      await Future.delayed(const Duration(milliseconds: 16));
      
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary not found');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to bytes');
      }

      final buffer = byteData.buffer.asUint8List();
      
      // Fixed: Use temporary directory for better reliability
      final tempDir = await getTemporaryDirectory();
      final framesDir = Directory('${tempDir.path}/warp_frames');
      if (!await framesDir.exists()) {
        await framesDir.create(recursive: true);
      }
      
      final file = File('${framesDir.path}/frame_${index.toString().padLeft(4, '0')}.png');
      await file.writeAsBytes(buffer);
      debugPrint('✅ Captured frame $index');
      
      // Cleanup image to prevent memory leaks
      image.dispose();
    } catch (e) {
      debugPrint('❌ Frame capture failed: $e');
      rethrow;
    }
  }

  Future<void> _exportToMp4() async {
    if (_isExporting) return;
    
    try {
      setState(() => _isExporting = true);

      final tempDir = await getTemporaryDirectory();
      final framesDir = Directory('${tempDir.path}/warp_frames');
      final outputDir = await getApplicationDocumentsDirectory();
      
      // Clean up any existing frames
      if (await framesDir.exists()) {
        await framesDir.delete(recursive: true);
      }
      await framesDir.create(recursive: true);

      _frameCount = 0;

      // Fixed: Better frame capture synchronization
      await _captureFramesSequentially();
      
      debugPrint('🎬 Capturing complete. Starting FFmpeg export...');
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${outputDir.path}/warp_animation_$timestamp.mp4';
      
      // Fixed: Improved FFmpeg command with better error handling
      final command = '-y -framerate 10 -i ${framesDir.path}/frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 23 -preset medium "$outputPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();
      
      if (returnCode?.isValueSuccess() ?? false) {
        debugPrint('✅ Export successful: $outputPath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to: $outputPath'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        debugPrint('❌ Export failed: $logs');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export failed. Check console for details.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      // Cleanup frame files
      if (await framesDir.exists()) {
        await framesDir.delete(recursive: true);
      }
      
    } catch (e) {
      debugPrint('❌ Export process failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  // Fixed: Sequential frame capture for better synchronization
  Future<void> _captureFramesSequentially() async {
    for (int i = 0; i < _totalFrames; i++) {
      // Reset animation to specific frame
      final progress = i / (_totalFrames - 1);
      _controller.reset();
      _controller.animateTo(progress);
      
      // Wait for animation to reach target
      await Future.delayed(const Duration(milliseconds: 50));
      
      await _captureFrame(i);
      _frameCount = i + 1;
      
      // Update UI to show progress
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Export Options', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.movie),
                title: const Text('Export animation as MP4'),
                subtitle: Text(_isExporting 
                    ? 'Exporting... ($_frameCount/$_totalFrames frames)'
                    : 'Export 6-second warp animation'),
                enabled: !_isExporting,
                onTap: _isExporting ? null : () {
                  Navigator.pop(context);
                  _exportToMp4();
                },
              ),
              if (_isExporting) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _frameCount / _totalFrames,
                ),
                const SizedBox(height: 8),
                Text('${((_frameCount / _totalFrames) * 100).toInt()}% complete'),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RepaintBoundary(
            key: repaintKey,
            child: CustomPaint(
              painter: WarpPainter(_stars),
              child: Container(),
            ),
          ),
          if (_isExporting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Exporting Animation...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isExporting ? null : () => _showExportSheet(context),
        backgroundColor: _isExporting ? Colors.grey : null,
        child: _isExporting 
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.share),
      ),
    );
  }
}

class Star {
  double x = 0, y = 0, z = 0;
  final Random rand = Random();

  Star() {
    reset();
  }

  void reset() {
    x = rand.nextDouble() * 2 - 1;
    y = rand.nextDouble() * 2 - 1;
    z = rand.nextDouble() * 0.8 + 0.2; // Fixed: Prevent z from being too close to 0
  }

  void update() {
    z -= 0.02;
    if (z < 0.01) reset();
  }

  Offset project(Size size) {
    final scale = 0.5 / z;
    final px = x * scale * size.width + size.width / 2;
    final py = y * scale * size.height + size.height / 2;
    return Offset(px, py);
  }
}

class WarpPainter extends CustomPainter {
  final List<Star> stars;
  WarpPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (var star in stars) {
      final p = star.project(size);
      // Fixed: Add bounds checking to prevent drawing off-screen
      if (p.dx >= 0 && p.dx <= size.width && p.dy >= 0 && p.dy <= size.height) {
        // Fixed: Variable star size based on depth for better warp effect
        final radius = (1.0 - star.z) * 2.0 + 0.5;
        canvas.drawCircle(p, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
