import 'dart:math';
import 'package:flutter/material.dart';

class ArcMeter extends StatefulWidget {
  final double progress; // 0.0 → 1.0
  final double spent;
  final double budget;

  const ArcMeter({
    super.key,
    required this.progress,
    required this.spent,
    required this.budget,
  });

  @override
  State<ArcMeter> createState() => _ArcMeterState();
}

class _ArcMeterState extends State<ArcMeter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ArcMeter old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(260, 150),
        painter: _ArcPainter(
          progress: _anim.value * widget.progress,
          color: _arcColor(widget.progress),
        ),
        child: SizedBox(
          width: 260,
          height: 150,
          child: Align(
            alignment: const Alignment(0, 0.55),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${widget.spent.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'of \$${widget.budget.toStringAsFixed(0)} budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _arcColor(double p) {
    if (p < 0.6) return const Color(0xFF6C63FF);
    if (p < 0.85) return Colors.orange;
    return Colors.red;
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final radius = size.width / 2 - 16;

    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: radius * 2,
      height: radius * 2,
    );

    final trackPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, pi, pi, false, trackPaint);

    if (progress > 0.01) {
      final fillPaint = Paint()
        ..color = color
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, pi, pi * progress, false, fillPaint);
    }
  }

  // only repaint when values that affect drawing change
  @override
  bool shouldRepaint(_ArcPainter old) {
    return old.progress != progress || old.color != color;
  }
}
