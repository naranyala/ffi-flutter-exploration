// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TapConfettiPage(),
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}

/* ----------  SINGLE-TAP CONFETTI PAGE  ---------- */

class TapConfettiPage extends StatelessWidget {
  const TapConfettiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (_, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _spawn(context, d.localPosition, constraints),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _spawn(BuildContext context, Offset localPos, BoxConstraints constraints) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _BurstWidget(
        key: ValueKey(DateTime.now().microsecondsSinceEpoch),
        origin: localPos,
        constraints: constraints,
      ),
    );
    overlay.insert(entry);

    // auto-remove after animation
    Future.delayed(const Duration(milliseconds: 1300), entry.remove);
  }
}

/* ----------  SELF-DESTRUCTING BURST  ---------- */

class _BurstWidget extends StatefulWidget {
  final Offset origin;
  final BoxConstraints constraints;

  const _BurstWidget({required Key key, required this.origin, required this.constraints})
      : super(key: key);

  @override
  State<_BurstWidget> createState() => _BurstWidgetState();
}

class _BurstWidgetState extends State<_BurstWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Stack(
          children: List.generate(30, (i) {
            final angle = _rng.nextDouble() * 2 * pi;
            final speed = 120 + _rng.nextDouble() * 250;
            final dist = _ctrl.value * speed;
            final dx = cos(angle) * dist;
            final dy = sin(angle) * dist + 0.5 * 300 * _ctrl.value * _ctrl.value;
            final hue = _rng.nextDouble() * 360;
            return AnimatedPositioned(
              duration: Duration.zero,
              left: widget.origin.dx + dx,
              top: widget.origin.dy + dy,
              child: Opacity(
                opacity: 1 - (_ctrl.value * 1.5).clamp(0, 1),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: HSVColor.fromAHSV(1, hue, 0.9, 0.95).toColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
