import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: AppBar(
          title: const Text('🎮 GLB Model Viewer'),
          centerTitle: true,
          backgroundColor: const Color(0xFF111111),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        body: const GLBViewerModelViewer(),
      ),
    );
  }
}

class GLBViewerModelViewer extends StatefulWidget {
  const GLBViewerModelViewer({super.key});

  @override
  State<GLBViewerModelViewer> createState() => _GLBViewerModelViewerState();
}

class _GLBViewerModelViewerState extends State<GLBViewerModelViewer> {
  bool isLoading = true;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 500,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Stack(
        children: [
          ModelViewer(
            // Model URL - supports both local and remote files
            src: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
            
            // Alternative: Local asset
            // src: 'assets/models/duck.glb',
            
            // Viewer configuration
            alt: '3D Duck Model',
            ar: true, // Enable AR on supported devices
            autoRotate: true,
            autoRotateDelay: 3000,
            rotationPerSecond: '30deg',
            cameraControls: true,
            touchAction: TouchAction.panY,
            interactionPrompt: InteractionPrompt.whenFocused,
            
            // Lighting and environment
            environmentImage: 'https://modelviewer.dev/assets/whipple_creek_regional_park_04_1k.hdr',
            shadowIntensity: 0.7,
            shadowSoftness: 0.5,
            
            // Camera settings
            cameraOrbit: '45deg 55deg 4m',
            minCameraOrbit: 'auto auto 2m',
            maxCameraOrbit: 'auto auto 10m',
            
            // Performance
            loading: Loading.eager,
            reveal: Reveal.auto,
            
            // Background
            backgroundColor: const Color(0xFF111111),
            
            // Callbacks
            onWebViewCreated: (controller) {
              debugPrint('Model Viewer WebView created');
            },
            
            // onProgress: (progress) {
            //   if (progress == 1.0 && isLoading) {
            //     setState(() {
            //       isLoading = false;
            //     });
            //   }
            // },
            
            // onError: (error) {
            //   setState(() {
            //     errorMessage = error;
            //     isLoading = false;
            //   });
            // },
          ),
          
          // Loading overlay
          if (isLoading)
            Container(
              color: const Color(0xFF111111),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading 3D Model...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error overlay
          if (errorMessage != null)
            Container(
              color: const Color(0xFF111111),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load model',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          // Control overlay
          if (!isLoading && errorMessage == null)
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "reset",
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () {
                      // Reset camera position
                      // Note: Direct camera reset requires JavaScript injection
                    },
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "ar",
                    mini: true,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    onPressed: () {
                      // AR functionality is automatically handled by ModelViewer
                    },
                    child: const Icon(Icons.view_in_ar, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
