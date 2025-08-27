import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF0E0F12),
      ),
      home: const GamePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameConfig {
  final int rows;
  final int cols;
  final int tickMs;
  final bool showGrid;
  final Color boardColor;
  final Color gridColor;
  final Color snakeHeadColor;
  final Color snakeBodyColor;
  final Color foodColor;

  const GameConfig({
    this.rows = 20,
    this.cols = 20,
    this.tickMs = 140,
    this.showGrid = true,
    this.boardColor = const Color(0xFF111317),
    this.gridColor = const Color(0x221EEA62),
    this.snakeHeadColor = const Color(0xFF1EEA62),
    this.snakeBodyColor = const Color(0xFF0FB84A),
    this.foodColor = const Color(0xFFE53935),
  });
}

enum Direction { up, down, left, right }

extension on Direction {
  bool isOpposite(Direction other) {
    return (this == Direction.up && other == Direction.down) ||
        (this == Direction.down && other == Direction.up) ||
        (this == Direction.left && other == Direction.right) ||
        (this == Direction.right && other == Direction.left);
  }
}

class SnakeGame extends ChangeNotifier {
  SnakeGame(this.config) {
    reset();
  }

  final GameConfig config;
  final _rng = Random();

  late List<Point<int>> _snake; // head at index 0
  late Direction _dir;
  late Point<int> _food;

  int _score = 0;
  bool _running = false;
  bool _gameOver = false;
  Timer? _timer;

  // Ensures only one turn per tick
  bool _turnedThisTick = false;

  // Public read-only getters
  List<Point<int>> get snake => List.unmodifiable(_snake);
  Direction get dir => _dir;
  Point<int> get food => _food;
  int get score => _score;
  bool get isRunning => _running;
  bool get isGameOver => _gameOver;

  void start() {
    if (_running || _gameOver) return;
    _running = true;
    _timer = Timer.periodic(Duration(milliseconds: config.tickMs), (_) => _tick());
    notifyListeners();
  }

  void pause() {
    _running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _score = 0;
    _running = false;
    _gameOver = false;

    // Start snake centered with length 3, moving right
    final midR = (config.rows / 2).floor();
    final midC = (config.cols / 2).floor();
    _snake = [
      Point(midC, midR),
      Point(midC - 1, midR),
      Point(midC - 2, midR),
    ];
    _dir = Direction.right;
    _spawnFood();
    notifyListeners();
  }

  void turn(Direction next) {
    if (_gameOver || !_running) return;
    if (_turnedThisTick) return; // one change per tick
    if (next.isOpposite(_dir) && _snake.length > 1) return; // no reversal
    _dir = next;
    _turnedThisTick = true;
  }

  void _tick() {
    if (_gameOver || !_running) return;
    _turnedThisTick = false;

    final head = _snake.first;
    final nextHead = _nextPoint(head, _dir);

    // Wall collision
    if (nextHead.x < 0 ||
        nextHead.y < 0 ||
        nextHead.x >= config.cols ||
        nextHead.y >= config.rows) {
      _gameOver = true;
      pause();
      notifyListeners();
      return;
    }

    // Self collision (allow moving into last tail cell only if not growing)
    final willEat = nextHead == _food;
    final bodyToCheck = willEat ? _snake : _snake.sublist(0, _snake.length - 1);
    if (bodyToCheck.contains(nextHead)) {
      _gameOver = true;
      pause();
      notifyListeners();
      return;
    }

    // Move snake
    _snake = [nextHead, ..._snake];

    // Eat or advance
    if (willEat) {
      _score += 1;
      _spawnFood();
    } else {
      _snake.removeLast();
    }

    notifyListeners();
  }

  Point<int> _nextPoint(Point<int> p, Direction d) {
    switch (d) {
      case Direction.up:
        return Point(p.x, p.y - 1);
      case Direction.down:
        return Point(p.x, p.y + 1);
      case Direction.left:
        return Point(p.x - 1, p.y);
      case Direction.right:
        return Point(p.x + 1, p.y);
    }
  }

  void _spawnFood() {
    final free = <Point<int>>[];
    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        final p = Point(c, r);
        if (!_snake.contains(p)) free.add(p);
      }
    }
    _food = free[_rng.nextInt(free.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final SnakeGame game;

  @override
  void initState() {
    super.initState();
    game = SnakeGame(const GameConfig(rows: 22, cols: 22, tickMs: 120));
  }

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  void _handlePan(DragUpdateDetails d) {
    final dx = d.delta.dx;
    final dy = d.delta.dy;
    // Only accept clear intent swipes
    if (dx.abs() < 6 && dy.abs() < 6) return;

    if (dx.abs() > dy.abs()) {
      game.turn(dx > 0 ? Direction.right : Direction.left);
    } else {
      game.turn(dy > 0 ? Direction.down : Direction.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake'),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: game.reset,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedBuilder(
              animation: game,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top bar: score + status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text('Score: ${game.score}', style: const TextStyle(fontSize: 16)),
                          const Spacer(),
                          if (game.isGameOver)
                            const Text('Game Over', style: TextStyle(color: Colors.redAccent)),
                          if (!game.isGameOver && !game.isRunning)
                            const Text('Paused', style: TextStyle(color: Colors.amber)),
                        ],
                      ),
                    ),

                    // Board
                    LayoutBuilder(builder: (context, constraints) {
                      final size = min(constraints.maxWidth, MediaQuery.of(context).size.height * 0.55);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanUpdate: _handlePan,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0F13),
                            border: Border.all(color: color.primary.withOpacity(0.3), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomPaint(
                            painter: SnakePainter(game),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Controls
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: game.isRunning ? game.pause : game.start,
                          icon: Icon(game.isRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(game.isRunning ? 'Pause' : 'Start'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: game.reset,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Arrow pad
                    _ArrowPad(
                      onUp: () => game.turn(Direction.up),
                      onDown: () => game.turn(Direction.down),
                      onLeft: () => game.turn(Direction.left),
                      onRight: () => game.turn(Direction.right),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  SnakePainter(this.game);
  final SnakeGame game;

  @override
  void paint(Canvas canvas, Size size) {
    final cfg = game.config;
    final cols = cfg.cols.toDouble();
    final rows = cfg.rows.toDouble();
    final cell = Offset(size.width / cols, size.height / rows);

    final boardPaint = Paint()..color = cfg.boardColor;
    canvas.drawRect(Offset.zero & size, boardPaint);

    if (cfg.showGrid) {
      final gridPaint = Paint()
        ..color = cfg.gridColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (int c = 1; c < cfg.cols; c++) {
        final x = cell.dx * c;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (int r = 1; r < cfg.rows; r++) {
        final y = cell.dy * r;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Food
    _drawCell(canvas, cell, game.food, cfg.foodColor, radiusFactor: 0.3);

    // Snake
    for (int i = game.snake.length - 1; i >= 0; i--) {
      final isHead = (i == 0);
      final color = isHead ? cfg.snakeHeadColor : cfg.snakeBodyColor;
      _drawCell(canvas, cell, game.snake[i], color, radiusFactor: isHead ? 0.2 : 0.25);
    }
  }

  void _drawCell(Canvas canvas, Offset cell, Point<int> p, Color color, {double radiusFactor = 0.25}) {
    final rect = Rect.fromLTWH(p.x * cell.dx, p.y * cell.dy, cell.dx, cell.dy);
    final r = Radius.circular(min(cell.dx, cell.dy) * radiusFactor);
    final paint = Paint()..color = color;
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.2), r), paint);
  }

  @override
  bool shouldRepaint(covariant SnakePainter oldDelegate) {
    return oldDelegate.game != game ||
        oldDelegate.game.snake != game.snake ||
        oldDelegate.game.food != game.food ||
        oldDelegate.game.score != game.score ||
        oldDelegate.game.isRunning != game.isRunning ||
        oldDelegate.game.isGameOver != game.isGameOver;
  }
}

class _ArrowPad extends StatelessWidget {
  const _ArrowPad({
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  });

  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    final btnStyle = FilledButton.styleFrom(minimumSize: const Size(64, 48));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton(onPressed: onUp, style: btnStyle, child: const Icon(Icons.keyboard_arrow_up)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(onPressed: onLeft, style: btnStyle, child: const Icon(Icons.keyboard_arrow_left)),
            const SizedBox(width: 10),
            FilledButton(onPressed: onRight, style: btnStyle, child: const Icon(Icons.keyboard_arrow_right)),
          ],
        ),
        FilledButton(onPressed: onDown, style: btnStyle, child: const Icon(Icons.keyboard_arrow_down)),
      ],
    );
  }
}

