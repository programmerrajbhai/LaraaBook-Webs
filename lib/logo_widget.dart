import 'package:flutter/material.dart';
import 'dart:math' as math;

class LarabookLogo extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final bool animate; // Toggle animation

  const LarabookLogo({
    Key? key,
    this.size = 100,
    this.backgroundColor = const Color(0xFF1877F2), // Classic Social Blue
    this.iconColor = Colors.white,
    this.animate = true,
  }) : super(key: key);

  @override
  State<LarabookLogo> createState() => _LarabookLogoState();
}

class _LarabookLogoState extends State<LarabookLogo> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The Main Logo Icon
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor,
                widget.backgroundColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.size * 0.22),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.4),
                blurRadius: widget.size * 0.2,
                offset: Offset(0, widget.size * 0.1),
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: Size(widget.size * 0.55, widget.size * 0.55),
              painter: _LogoPainter(color: widget.iconColor),
            ),
          ),
        ),

        // The "Loading" Dots (Blinking effect)
        if (widget.animate) ...[
          SizedBox(height: widget.size * 0.15),
          SizedBox(
            width: widget.size * 0.6,
            height: widget.size * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return _BlinkingDot(
                  controller: _controller,
                  index: index,
                  color: widget.backgroundColor,
                  size: widget.size * 0.12,
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

// Painter for the "L" Book Shape
class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round; // Smooth edges

    final Path path = Path();

    // Modern, fluid "L" shape
    // Start top of vertical bar
    path.moveTo(size.width * 0.25, 0);

    // Draw down
    path.lineTo(size.width * 0.25, size.height * 0.85);

    // Curve for the bottom page
    path.quadraticBezierTo(
        size.width * 0.25, size.height, // Control point
        size.width * 0.45, size.height  // End point
    );

    // Bottom line extending right
    path.lineTo(size.width, size.height);

    // Right edge going up slightly (perspective)
    path.lineTo(size.width, size.height * 0.75);

    // Top line of bottom bar coming back left
    path.lineTo(size.width * 0.45, size.height * 0.75);

    // Inner curve connecting vertical and horizontal
    path.quadraticBezierTo(
        size.width * 0.40, size.height * 0.75,
        size.width * 0.40, size.height * 0.60
    );

    // Back up the vertical bar
    path.lineTo(size.width * 0.40, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget for a single blinking dot
class _BlinkingDot extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Color color;
  final double size;

  const _BlinkingDot({
    required this.controller,
    required this.index,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Stagger the animation based on index (0, 1, 2)
    final double start = index * 0.2;
    final double end = start + 0.4;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Create an opacity curve for blinking effect
        final double opacity = _getOpacity(controller.value, start, end);

        return Opacity(
          opacity: opacity,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  double _getOpacity(double value, double start, double end) {
    if (value >= start && value <= end) {
      // Sine wave for smooth fade in/out
      double t = (value - start) / (end - start);
      return 0.3 + 0.7 * math.sin(t * math.pi);
    }
    return 0.3; // Resting opacity
  }
}