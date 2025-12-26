import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SpaceBackground extends StatefulWidget {
  final Widget child;

  const SpaceBackground({super.key, required this.child});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize stars
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.4,
        size: 0.5 + _random.nextDouble() * 1.5,
        opacity: 0.3 + _random.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Starfield
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: StarFieldPainter(
                stars: _stars,
                progress: _controller.value,
              ),
              child: Container(),
            );
          },
        ),

        // Content
        widget.child,

        // Rocket ship - only show on larger screens
        if (MediaQuery.of(context).size.width >= 768)
          Positioned(
            right: 40,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Gentle Bobbing
                final offset = sin(_controller.value * 2 * pi) * 20;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: Transform.rotate(
                    angle: -pi / 4, // 45 degrees
                    child: Opacity(
                      opacity: 0.8,
                      child: SvgPicture.asset(
                        'assets/images/rocket_ship.svg',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class Star {
  double x;
  double y;
  double speed;
  double size;
  double opacity;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  StarFieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      // Move stars vertically (top to bottom) to simulate moving forward/up?
      // Or horizontally? Let's do diagonal or just vertical drift.
      // Let's do simple vertical scrolling downwards = moving upwards

      // Update position based on progress is tricky in stateless painter.
      // We usually update state. BUT, here we can just use progress as a global time shifter.

      // We will calc actual Y based on (initialY + progress * speed) % 1.0
      // BUT progress 0->1 loops.

      // Better: Since progress loops 0->1, we can just use it directly.
      // To prevent all moving in sync, we need individual offsets.
      // Current sim: Infinite scroll down (moving up)

      // Let's simulate typical "moving forward":
      // Usually stars come from center (warp) or move fast.
      // Simple parallax: move Left to Right or Right to Left?
      // Let's do Bottom-Right to Top-Left diagonal (moving towards top right).

      double currentX = (star.x - (progress * star.speed)) % 1.0;
      double currentY = (star.y + (progress * star.speed)) % 1.0;

      // Wrap around
      if (currentX < 0) currentX += 1.0;

      canvas.drawCircle(
        Offset(currentX * size.width, currentY * size.height),
        star.size,
        paint..color = Colors.white.withValues(alpha: star.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}
