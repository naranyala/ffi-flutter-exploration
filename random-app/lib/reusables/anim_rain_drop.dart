// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

void main() => runApp(const RainApp());

class RainApp extends StatelessWidget {
  const RainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Scaffold(backgroundColor: Colors.black, body: DigitalRain()),
    );
  }
}

/* ----------  FULL-SCREEN DIGITAL RAIN  ---------- */

class DigitalRain extends StatefulWidget {
  const DigitalRain({super.key});

  @override
  State<DigitalRain> createState() => _DigitalRainState();
}

class _DigitalRainState extends State<DigitalRain> {
  static const _chars = '0123456789ABCDEF';
  final _rng = math.Random();
  final _columns = <_Column>[];
  late Timer _timer;
  late int _colCount;
  double _colWidth = 24;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  void _setup() {
    final width = MediaQuery.sizeOf(context).width;
    _colCount = (width / _colWidth).ceil();
    for (int i = 0; i < _colCount; i++) {
      _columns.add(_Column(index: i, rng: _rng));
    }
    _timer = Timer.periodic(const Duration(milliseconds: 60), (_) => _tick());
  }

  void _tick() {
    for (final c in _columns) c.tick(_chars);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_columns.isEmpty) return const SizedBox.expand();
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          children: [
            for (final c in _columns)
              Positioned(
                left: c.index * _colWidth,
                top: 0,
                width: _colWidth,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in c.drops)
                      SizedBox(
                        height: d.height,
                        child: Center(
                          child: Text(
                            d.char,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 18,
                              color: d.glow
                                  ? Colors.white
                                  : Colors.greenAccent
                                      .withOpacity(d.alpha),
                              shadows: d.glow
                                  ? [
                                      const Shadow(
                                        color: Colors.lightGreenAccent,
                                        blurRadius: 8,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        ),
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

/* ----------  COLUMN & DROP HELPERS  ---------- */

class _Column {
  final int index;
  final math.Random rng;
  final drops = <_Drop>[];

  _Column({required this.index, required this.rng});

  void tick(String chars) {
    // random spawn
    if (rng.nextDouble() < 0.25) {
      drops.add(_Drop.create(chars, rng, true));
    }
    // move & fade
    for (final d in drops) {
      d.y += d.speed;
      d.alpha = (1 - d.y / 600).clamp(0, 1).toDouble();
    }
    // remove off-screen
    drops.removeWhere((d) => d.y > 600 || d.alpha <= 0);
  }
}

class _Drop {
  late String char;
  late double y;
  late double speed;
  late double height;
  late double alpha;
  late bool glow;

  _Drop.create(String chars, math.Random rng, bool isHead) {
    char = chars[rng.nextInt(chars.length)];
    y = -20;
    speed = 10 + rng.nextDouble() * 15;
    height = 22;
    alpha = 1;
    glow = isHead;
  }
}
