import 'package:flutter/material.dart';

class DriveInfo {
  final String name;
  final int sizeBytes;
  final List<DriveInfo> children;

  DriveInfo(this.name, this.sizeBytes, this.children);
}

class DriveExplorer extends StatefulWidget {
  final DriveInfo root;
  const DriveExplorer({required this.root, super.key});

  @override
  State<DriveExplorer> createState() => _DriveExplorerState();
}

class _DriveExplorerState extends State<DriveExplorer> {
  late List<DriveInfo> stack;

  @override
  void initState() {
    super.initState();
    stack = [widget.root];
  }

  void goBack() {
    if (stack.length > 1) {
      setState(() => stack.removeLast());
    }
  }

  void goDeeper(DriveInfo child) {
    if (child.children.isNotEmpty) {
      setState(() => stack.add(child));
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = stack.last;
    return Column(
      children: [
        // Top Navigation Bar
        Container(
          color: Colors.grey[300],
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              if (stack.length > 1)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: goBack,
                ),
              Text(
                "Current: ${current.name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Drive Painter
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              final tapped = DrivePainter.hitTestChild(
                current,
                details.localPosition,
                context.size!,
              );
              if (tapped != null) goDeeper(tapped);
            },
            child: CustomPaint(
              painter: DrivePainter(current),
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }
}

class DrivePainter extends CustomPainter {
  final DriveInfo drive;
  static const double parentHeight = 60;
  static const double childHeight = 40;

  DrivePainter(this.drive);

  @override
  void paint(Canvas canvas, Size size) {
    final paintParent = Paint()..color = Colors.blue.withOpacity(0.3);
    final paintChild = Paint()..color = Colors.orange.withOpacity(0.3);

    // Draw parent box (top level)
    final parentRect = Rect.fromLTWH(10, 10, size.width - 20, parentHeight);
    canvas.drawRect(parentRect, paintParent);
    _drawText(canvas, drive.name, parentRect);

    // Draw children boxes (second level)
    double x = 10;
    final y = 10 + parentHeight + 20;
    for (var child in drive.children) {
      final width = (child.sizeBytes / drive.sizeBytes) * (size.width - 20);
      final rect = Rect.fromLTWH(x, y, width, childHeight);
      canvas.drawRect(rect, paintChild);
      _drawText(canvas, child.name, rect);
      _childRects[child] = rect; // store for hit-testing
      x += width + 4;
    }
  }

  void _drawText(Canvas canvas, String text, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.black)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: "...",
    );
    textPainter.layout(maxWidth: rect.width - 4);
    textPainter.paint(
        canvas, Offset(rect.left + 2, rect.top + (rect.height - textPainter.height) / 2));
  }

  // Store child rects for hit-testing
  static final Map<DriveInfo, Rect> _childRects = {};

  static DriveInfo? hitTestChild(DriveInfo parent, Offset pos, Size size) {
    for (var entry in _childRects.entries) {
      if (entry.value.contains(pos)) return entry.key;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

