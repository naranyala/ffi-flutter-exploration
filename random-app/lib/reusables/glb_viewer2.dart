import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() {
  runApp(const GlbViewerApp());
}

class GlbViewerApp extends StatefulWidget {
  const GlbViewerApp({super.key});

  @override
  _GlbViewerAppState createState() => _GlbViewerAppState();
}

class _GlbViewerAppState extends State<GlbViewerApp> {
  bool _autoRotate = true;
  Object? _model;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native GLB Viewer'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: _error != null
                  ? Center(
                      child: Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  : Cube(
                      onSceneCreated: (Scene scene) {
                        try {
                          // Add the GLB model to the scene
                          _model = Object(
                            fileName: 'assets/truck_delivery.glb',
                            scale: Vector3(1.0, 1.0, 1.0),
                            position: Vector3(0, 0, 0),
                            rotation: _autoRotate ? Vector3(0, 45, 0) : Vector3(0, 0, 0),
                          );
                          scene.world.add(_model!);
                          // Configure camera
                          scene.camera.position.setValues(0, 1, 5);
                          scene.camera.fov = 50;
                          // Add lighting for better visibility
                          scene.world.add(PointLight(
                            color: Colors.white,
                            intensity: 1.0,
                            distance: 10,
                            position: Vector3(2, 2, 2),
                          ));
                        } catch (e) {
                          setState(() {
                            _error = e.toString();
                          });
                        }
                      },
                      onObjectCreated: (Object object) {
                        // Log when model is loaded
                        print('Model loaded: ${object.fileName}');
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _autoRotate = !_autoRotate;
                        if (_model != null) {
                          _model!.rotation = _autoRotate ? Vector3(0, 45, 0) : Vector3(0, 0, 0);
                          _model!.updateTransform();
                        }
                      });
                    },
                    child: Text(_autoRotate ? 'Stop Rotation' : 'Start Rotation'),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Drag to rotate, pinch to zoom',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
