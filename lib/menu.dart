import 'package:flutter/material.dart';
import 'main.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Dashed center line
          Positioned.fill(child: CustomPaint(painter: _MenuLinePainter())),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/banner.png', width: 350, height: 200),
                const Text(
                  'ZAEBALSYA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                ),
                const Text(
                  'PONG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '2 PLAYERS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 16,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 72),
                _MenuButton(
                  label: 'PLAY',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const PongGame()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Player side labels
          const Positioned(
            bottom: 24,
            left: 32,
            child: Text(
              'P1\nLeft side',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white24,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const Positioned(
            bottom: 24,
            right: 32,
            child: Text(
              'P2\nRight side',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white24,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.onTap});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
        decoration: BoxDecoration(
          color: _pressed ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _pressed ? Colors.black : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
        ),
      ),
    );
  }
}

class _MenuLinePainter extends CustomPainter {
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
  bool shouldRepaint(_MenuLinePainter _) => false;
}
