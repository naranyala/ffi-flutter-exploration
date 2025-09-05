// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const PrimitivesApp());

class PrimitivesApp extends StatelessWidget {
  const PrimitivesApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PrimitivesDemo(),
    );
  }
}

/* ----------  DEMO PAGE  ---------- */

class PrimitivesDemo extends StatelessWidget {
  const PrimitivesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: const Center(
        child: PrimitiveCircle(),
      ),
    );
  }
}

/* ----------  1. WIDGET (immutable) ---------- */

class PrimitiveCircle extends StatefulWidget {
  const PrimitiveCircle({super.key});

  @override
  State<PrimitiveCircle> createState() {
    debugPrint('Widget createState -> builds State instance');
    return _PrimitiveCircleState();
  }

  @override
  PrimitiveElement createElement() {
    debugPrint('Widget createElement -> returns Element');
    return PrimitiveElement(this);
  }
}

/* ---------- 2. ELEMENT (mutable tree node) ---------- */

class PrimitiveElement extends StatefulElement {
  PrimitiveElement(super.widget) {
    debugPrint('Element constructor -> $this');
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    debugPrint('Element mount -> attached to tree');
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    debugPrint('Element unmount -> leaving tree');
    super.unmount();
  }
}

/* ---------- 3. STATE (survives rebuilds) ---------- */

class _PrimitiveCircleState extends State<PrimitiveCircle> {
  Offset _position = Offset.zero;

  @override
  void initState() {
    super.initState();
    debugPrint('State initState -> first time only');
  }

  @override
  void didUpdateWidget(covariant PrimitiveCircle old) {
    super.didUpdateWidget(old);
    debugPrint('State didUpdateWidget -> Widget swapped');
  }

  @override
  void setState(VoidCallback fn) {
    debugPrint('State setState -> marks Element dirty');
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('State build -> returns lightweight Widget tree');
    return GestureDetector(
      onPanUpdate: (d) => setState(() => _position += d.delta),
      child: CustomPaint(
        painter: _CirclePainter(_position),
        size: const Size(200, 200),
      ),
    );
  }
}

/* ---------- 4. RENDER-OBJECT (paints & lays out) ---------- */

class _CirclePainter extends CustomPainter {
  final Offset center;

  _CirclePainter(this.center);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('RenderObject paint -> actual drawing');
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      size.center(center),
      40,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter old) {
    final r = old.center != center;
    debugPrint('RenderObject shouldRepaint -> $r');
    return r;
  }
}
