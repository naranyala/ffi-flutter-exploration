// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const NebulaApp());

class NebulaApp extends StatelessWidget {
  const NebulaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const NebulaPage(),
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}

/* ----------  PAGE  ---------- */

class NebulaPage extends StatelessWidget {
  const NebulaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: NebulaBlob()),
    );
  }
}

/* ----------  BREATHING BLOB  ---------- */

class NebulaBlob extends StatefulWidget {
  const NebulaBlob({super.key});

  @override
  State<NebulaBlob> createState() => _NebulaBlobState();
}

class _NebulaBlobState extends State<NebulaBlob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = math.Random();
  final _trail = <TrailDot>[];

  double _x = 0;
  double _y = 0;
  double _vx = 1;
  double _vy = 1;
  Color _color = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController.unbounded(vsync: this)
      ..addListener(_tick)
      ..repeat();
  }

  void _tick() {
    // bounce off walls
    final size = MediaQuery.sizeOf(context);
    if (_x <= -size.width / 2 + 40 || _x >= size.width / 2 - 40) _vx *= -1;
    if (_y <= -size.height / 2 + 40 || _y >= size.height / 2 - 40) _vy *= -1;

    _x += _vx;
    _y += _vy;

    // random gentle curve
    _vx += (_rng.nextDouble() - 0.5) * 0.5;
    _vy += (_rng.nextDouble() - 0.5) * 0.5;
    _vx = _vx.clamp(-4, 4);
    _vy = _vy.clamp(-4, 4);

    // leave fading trail
    _trail.add(TrailDot(Offset(_x, _y), _color));
    if (_trail.length > 80) _trail.removeAt(0);

    // random color shift every second
    if (_ctrl.lastElapsedDuration?.inSeconds !=
        _ctrl.lastElapsedDuration?.inSeconds) {
      _color = Color.fromRGBO(
        100 + _rng.nextInt(155),
        100 + _rng.nextInt(155),
        100 + _rng.nextInt(155),
        1,
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // fading trail
        ..._trail.map(
          (d) => Positioned(
            left: d.pos.dx,
            top: d.pos.dy,
            child: Opacity(
              opacity: (_trail.indexOf(d) / _trail.length).clamp(0, 1),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: d.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: d.color.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // main blob
        Transform.translate(
          offset: Offset(_x, _y),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [_color.withOpacity(0.9), _color.withOpacity(0.1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _color.withOpacity(0.7),
                  blurRadius: 40,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TrailDot {
  final Offset pos;
  final Color color;
  TrailDot(this.pos, this.color);
}
