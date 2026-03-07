import 'package:flutter/material.dart';
import 'main.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final bannerH = h * 0.42;
          final subSize = h * 0.038;
          final gap = h * 0.08;
          final labelSize = h * 0.055;

          return Stack(
            children: [
              // Dashed center line
              Positioned.fill(child: CustomPaint(painter: _MenuLinePainter())),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/banner.png', height: bannerH),
                    SizedBox(height: h * 0.02),
                    Text(
                      '2 PLAYERS',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: subSize,
                        letterSpacing: subSize * 0.35,
                      ),
                    ),
                    SizedBox(height: gap),
                    _MenuButton(
                      label: 'START',
                      fontSize: labelSize,
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
              Positioned(
                bottom: h * 0.06,
                left: h * 0.08,
                child: Text(
                  'P1\nLeft side',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: h * 0.045,
                    height: 1.6,
                  ),
                ),
              ),
              Positioned(
                bottom: h * 0.06,
                right: h * 0.08,
                child: Text(
                  'P2\nRight side',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: h * 0.045,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _MenuButton({
    required this.label,
    required this.onTap,
    required this.fontSize,
  });

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
            fontSize: widget.fontSize,
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
