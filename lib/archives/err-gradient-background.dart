import 'package:flutter/material.dart';
import 'dart:math';

class RandomGradientBackground extends StatelessWidget {
  final Widget child;

  const RandomGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final colors = [
      Colors.primaries[random.nextInt(Colors.primaries.length)],
      Colors.primaries[random.nextInt(Colors.primaries.length)],
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0],
            colors[1],
          ],
        ),
      ),
      child: child,
    );
  }
}
