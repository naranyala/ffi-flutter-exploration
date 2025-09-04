import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart' as three;
import 'package:three_dart_jsm/three_dart_jsm.dart' as jsm;

void main() => runApp(const ThreeDartApp());

class ThreeDartApp extends StatefulWidget {
  const ThreeDartApp({super.key});

  @override
  _ThreeDartAppState createState() => _ThreeDartAppState();
}

class _ThreeDartAppState extends State<ThreeDartApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ThreeDart GLB Viewer')),
        body: three.ThreeWidget(
          onSceneCreated: (three.Scene scene, three.WebGLRenderer renderer, three.PerspectiveCamera camera) async {
            camera.position.z = 5;
            final loader = jsm.GLTFLoader(null);
            final model = await loader.loadAsync('assets/truck_delivery.glb');
            scene.add(model.scene);
            renderer.render(scene, camera);
          },
        ),
      ),
    );
  }
}
