import 'package:flutter/material.dart';
import 'package:flutter_three/flutter_three.dart';
import 'package:three/three.dart' as three;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GLB Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text("3D GLB Viewer")),
        body: const Center(
          child: GLBViewer(),
        ),
      ),
    );
  }
}

class GLBViewer extends StatefulWidget {
  const GLBViewer({super.key});

  @override
  State<GLBViewer> createState() => _GLBViewerState();
}

class _GLBViewerState extends State<GLBViewer> {
  late three.Scene scene;
  late three.Camera camera;
  three.Object3D? model;

  final String glbUrl =
      'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Scene
    scene = three.Scene()..setClearColor(three.Color.fromHex(0xeeeeee), 1.0);

    // Camera
    camera = three.PerspectiveCamera(75, 800 / 600, 0.1, 1000);
    camera.position.set(0, 0, 5);

    // Lights
    scene.add(three.AmbientLight(0x404040));
    final directionalLight = three.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(1, 1, 1);
    scene.add(directionalLight);

    // Load GLB
    try {
      model = await three.GLTFLoader.loadFromUrl(glbUrl);
      model!.scale.set(0.5, 0.5, 0.5);
      model!.rotation.set(0, 0, 0);
      scene.add(model!);
    } catch (e) {
      print('Failed to load GLB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 600,
      child: ThreeDart(
        scene: scene,
        camera: camera,
        animate: (time) {
          if (model != null) {
            model!.rotation.y = time / 1000; // Slow auto-rotation
          }
        },
        onResize: (size) {
          camera.aspect = size.width / size.height;
          camera.updateProjectionMatrix();
        },
      ),
    );
  }

  @override
  void dispose() {
    scene.dispose();
    super.dispose();
  }
}
