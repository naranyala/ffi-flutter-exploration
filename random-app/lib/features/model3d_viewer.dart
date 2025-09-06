// main.dart - Add initialization
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

Future<void> main() async {  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Model Viewer',
      home: Model3DView(),
    );
  }
}

class Model3DView extends StatelessWidget {
  const Model3DView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Viewer')),
        body: const ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          alt: 'A 3D model of an astronaut',
          ar: true,
          autoRotate: true,
          iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
          disableZoom: true,
        ),
      ),
    );
  }
}


// class Model3DView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("3D Model Viewer")),
//       body: ModelViewer(
//         src: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
//         alt: "A 3D duck model",
//         autoRotate: true,
//         cameraControls: true,
//         backgroundColor: Color(0xFF222222),
//         // Optional: AR support
//         ar: true,
//         disableZoom: false,
//       ),
//     );
//   }
// }
