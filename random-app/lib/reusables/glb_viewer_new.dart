import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GLB Model Viewer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GLBViewer(
        glbUrl:
            'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Duck/glTF-Binary/Duck.glb',
      ),
    );
  }
}

class GLBViewer extends StatefulWidget {
  final String glbUrl; // GLB file URL passed as a parameter

  const GLBViewer({Key? key, required this.glbUrl}) : super(key: key);

  @override
  _GLBViewerState createState() => _GLBViewerState();
}

class _GLBViewerState extends State<GLBViewer> {
  late final WebViewController _controller;

  // HTML content with a placeholder for the GLB URL
  static const String _htmlTemplate = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GLB Model Viewer</title>
  <style>
    body { margin: 0; overflow: hidden; }
    canvas { width: 100%; height: 100%; }
  </style>
</head>
<body>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r134/three.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.134.0/examples/js/controls/OrbitControls.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.134.0/examples/js/loaders/GLTFLoader.js"></script>
  <script>
    // Set up the scene, camera, and renderer
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(window.innerWidth, window.innerHeight);
    document.body.appendChild(renderer.domElement);

    // Add lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);
    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
    directionalLight.position.set(0, 1, 1);
    scene.add(directionalLight);

    // Add orbit controls
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.screenSpacePanning = false;
    controls.minDistance = 1;
    controls.maxDistance = 100;

    // Load the GLB model
    const loader = new THREE.GLTFLoader();
    loader.load(
      '{{GLB_URL}}', // Placeholder for the GLB URL
      (gltf) => {
        const model = gltf.scene;
        scene.add(model);

        // Center the model
        const box = new THREE.Box3().setFromObject(model);
        const center = box.getCenter(new THREE.Vector3());
        model.position.sub(center);
        camera.position.z = box.getSize(new THREE.Vector3()).length() * 1.5;
      },
      (xhr) => {
        console.log((xhr.loaded / xhr.total * 100) + '% loaded');
      },
      (error) => {
        console.error('Error loading GLB model:', error);
      }
    );

    // Handle window resize
    window.addEventListener('resize', () => {
      camera.aspect = window.innerWidth / window.innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // Animation loop
    function animate() {
      requestAnimationFrame(animate);
      controls.update();
      renderer.render(scene, camera);
    }
    animate();
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController with platform-specific parameters
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{}, // Corrected to use Set<PlaybackMediaTypes>
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      );

    // Load the HTML content with the GLB URL
    _loadHtmlContent();
  }

  Future<void> _loadHtmlContent() async {
    // Replace the placeholder with the actual GLB URL
    final String htmlContent = _htmlTemplate.replaceAll('{{GLB_URL}}', widget.glbUrl);

    // Encode the HTML content as a data URI
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(htmlContent));
    final String dataUrl = 'data:text/html;base64,$contentBase64';

    // Load the HTML content in the WebView
    await _controller.loadRequest(Uri.parse(dataUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GLB Model Viewer'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
