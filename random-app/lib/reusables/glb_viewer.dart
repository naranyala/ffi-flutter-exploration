import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

void main() => runApp(const CubeApp());

class CubeApp extends StatefulWidget {
  const CubeApp({super.key});

  @override
  _CubeAppState createState() => _CubeAppState();
}

class _CubeAppState extends State<CubeApp> {
  bool _autoRotate = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Cube GLB Viewer')),
        body: Column(
          children: [
            Expanded(
              child: Cube(
                onSceneCreated: (Scene scene) {
                  scene.world.add(Object(
                    fileName: 'assets/truck_delivery.glb',
                    scale: Vector3(1.0, 1.0, 1.0),
                    position: Vector3(0, 0, 0),
                    rotation: _autoRotate ? Vector3(0, 45, 0) : Vector3(0, 0, 0),
                  ));
                  scene.camera.position.z = 5;
                  scene.camera.fov = 50;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _autoRotate = !_autoRotate;
                  });
                },
                child: Text(_autoRotate ? 'Stop Rotation' : 'Start Rotation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
