import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const PongApp());
}

class PongApp extends StatelessWidget {
  const PongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pong',
      debugShowCheckedModeBanner: false,
      home: PongGame(),
    );
  }
}

class PongGame extends StatefulWidget {
  const PongGame({super.key});

  @override
  State<PongGame> createState() => _PongGameState();
}

class _PongGameState extends State<PongGame> with SingleTickerProviderStateMixin {
  static const double _paddleW = 14.0;
  static const double _paddleH = 90.0;
  static const double _ballR = 20.0; // ball radius
  static const double _margin = 20.0;
  static const double _initSpeed = 340.0;
  static const double _maxSpeed = 700.0;
  static const double _speedMult = 1.04;

  double _width = 0, _height = 0;
  bool _ready = false;

  // Ball center and velocity
  double _bx = 0, _by = 0, _bvx = 0, _bvy = 0;

  // Paddle center Y
  double _p1y = 0, _p2y = 0;

  int _s1 = 0, _s2 = 0;

  late Ticker _ticker;
  Duration? _prev;

  // Multi-touch: pointer id -> local Y
  final _leftTouches = <int, double>{};
  final _rightTouches = <int, double>{};

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/ball.png'), context);
  }

  void _init(double w, double h) {
    if (_ready) return;
    _width = w;
    _height = h;
    _p1y = h / 2;
    _p2y = h / 2;
    _launchBall();
    _ready = true;
    _ticker.start();
  }

  void _launchBall() {
    _bx = _width / 2;
    _by = _height / 2;
    final angle = (Random().nextDouble() * pi / 3) - pi / 6;
    final dir = Random().nextBool() ? 1.0 : -1.0;
    _bvx = _initSpeed * dir * cos(angle);
    _bvy = _initSpeed * sin(angle);
  }

  void _tick(Duration elapsed) {
    final prev = _prev;
    _prev = elapsed;
    if (prev == null) return;
    final dt = (elapsed - prev).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.05) return;

    setState(() {
      // Snap paddles to touch Y, clamped within screen
      if (_leftTouches.isNotEmpty) {
        _p1y = _leftTouches.values.last.clamp(_paddleH / 2, _height - _paddleH / 2);
      }
      if (_rightTouches.isNotEmpty) {
        _p2y = _rightTouches.values.last.clamp(_paddleH / 2, _height - _paddleH / 2);
      }

      // Move ball
      _bx += _bvx * dt;
      _by += _bvy * dt;

      // Top/bottom walls
      if (_by - _ballR < 0) {
        _by = _ballR;
        _bvy = _bvy.abs();
      } else if (_by + _ballR > _height) {
        _by = _height - _ballR;
        _bvy = -_bvy.abs();
      }

      // --- Left paddle ---
      final p1Left = _margin;
      final p1Right = _margin + _paddleW;
      final p1Top = _p1y - _paddleH / 2;
      final p1Bot = _p1y + _paddleH / 2;

      if (_bvx < 0 &&
          _bx - _ballR <= p1Right &&
          _bx + _ballR >= p1Left &&
          _by + _ballR >= p1Top &&
          _by - _ballR <= p1Bot &&
          _bx > p1Left) {
        _bx = p1Right + _ballR;
        final t = ((_by - _p1y) / (_paddleH / 2)).clamp(-1.0, 1.0);
        final spd = (sqrt(_bvx * _bvx + _bvy * _bvy) * _speedMult).clamp(0.0, _maxSpeed);
        final ang = t * (pi / 3);
        _bvx = spd * cos(ang);
        _bvy = spd * sin(ang);
      }

      // --- Right paddle ---
      final p2Left = _width - _margin - _paddleW;
      final p2Right = _width - _margin;
      final p2Top = _p2y - _paddleH / 2;
      final p2Bot = _p2y + _paddleH / 2;

      if (_bvx > 0 &&
          _bx + _ballR >= p2Left &&
          _bx - _ballR <= p2Right &&
          _by + _ballR >= p2Top &&
          _by - _ballR <= p2Bot &&
          _bx < p2Right) {
        _bx = p2Left - _ballR;
        final t = ((_by - _p2y) / (_paddleH / 2)).clamp(-1.0, 1.0);
        final spd = (sqrt(_bvx * _bvx + _bvy * _bvy) * _speedMult).clamp(0.0, _maxSpeed);
        final ang = pi - t * (pi / 3);
        _bvx = spd * cos(ang);
        _bvy = spd * sin(ang);
      }

      // Scoring
      if (_bx + _ballR < 0) {
        _s2++;
        _launchBall();
      } else if (_bx - _ballR > _width) {
        _s1++;
        _launchBall();
      }
    });
  }

  void _onDown(PointerDownEvent e) {
    if (e.localPosition.dx < _width / 2) {
      _leftTouches[e.pointer] = e.localPosition.dy;
    } else {
      _rightTouches[e.pointer] = e.localPosition.dy;
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (_leftTouches.containsKey(e.pointer)) {
      _leftTouches[e.pointer] = e.localPosition.dy;
    } else if (_rightTouches.containsKey(e.pointer)) {
      _rightTouches[e.pointer] = e.localPosition.dy;
    }
  }

  void _onUp(PointerUpEvent e) {
    _leftTouches.remove(e.pointer);
    _rightTouches.remove(e.pointer);
  }

  void _onCancel(PointerCancelEvent e) {
    _leftTouches.remove(e.pointer);
    _rightTouches.remove(e.pointer);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (_, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (!_ready && w > 0 && h > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _init(w, h));
          }

          if (!_ready) return const SizedBox.expand();

          final p1DrawLeft = _margin;
          final p2DrawLeft = _width - _margin - _paddleW;

          return Listener(
            onPointerDown: _onDown,
            onPointerMove: _onMove,
            onPointerUp: _onUp,
            onPointerCancel: _onCancel,
            child: SizedBox.expand(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Dashed center line
                  Positioned.fill(
                    child: CustomPaint(painter: _CenterLinePainter()),
                  ),

                  // Score
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_s1',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 72),
                        Text(
                          '$_s2',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Player labels
                  const Positioned(
                    top: 12,
                    left: 16,
                    child: Text('P1', style: TextStyle(color: Colors.white30, fontSize: 14)),
                  ),
                  const Positioned(
                    top: 12,
                    right: 16,
                    child: Text('P2', style: TextStyle(color: Colors.white30, fontSize: 14)),
                  ),

                  // Paddle 1
                  Positioned(
                    left: p1DrawLeft,
                    top: _p1y - _paddleH / 2,
                    width: _paddleW,
                    height: _paddleH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_paddleW / 2),
                      ),
                    ),
                  ),

                  // Paddle 2
                  Positioned(
                    left: p2DrawLeft,
                    top: _p2y - _paddleH / 2,
                    width: _paddleW,
                    height: _paddleH,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(_paddleW / 2),
                      ),
                    ),
                  ),

                  // Ball (image asset)
                  Positioned(
                    left: _bx - _ballR,
                    top: _by - _ballR,
                    width: _ballR * 2,
                    height: _ballR * 2,
                    child: Image.asset('assets/ball.png', fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CenterLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;
    const dashH = 12.0;
    const gap = 8.0;
    final x = size.width / 2;
    for (double y = 0; y < size.height; y += dashH + gap) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dashH), paint);
    }
  }

  @override
  bool shouldRepaint(_CenterLinePainter _) => false;
}
