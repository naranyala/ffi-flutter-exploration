import 'package:flutter/material.dart';
import 'dart:math';

class RandomColorContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const RandomColorContainer({
    super.key,
    this.width = 100,
    this.height = 100,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final color = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
