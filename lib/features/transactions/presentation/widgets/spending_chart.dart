import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SpendingChart extends StatelessWidget {
  final List<double> data; // 7 daily values, oldest first

  const SpendingChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        size: const Size(double.infinity, 100),
        painter: _ChartPainter(data: data),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;

  const _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final maxVal = data.reduce(max);
    if (maxVal == 0) return;

    const topPad = 8.0;
    const bottomPad = 4.0;

    final points = <Offset>[];
    final stepX = size.width / (data.length - 1);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalised = data[i] / maxVal;
      final y = size.height - bottomPad - normalised * (size.height - topPad - bottomPad);
      points.add(Offset(x, y));
    }

    // gradient fill under the curve
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    _addCurve(fillPath, points);
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // the actual line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    _addCurve(linePath, points);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF6C63FF)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // dots
    for (final p in points) {
      canvas.drawCircle(
        p,
        3.5,
        Paint()..color = const Color(0xFF6C63FF),
      );
      canvas.drawCircle(
        p,
        3.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  // smooth bezier through all points
  void _addCurve(Path path, List<Offset> pts) {
    for (var i = 1; i < pts.length; i++) {
      final midX = (pts[i - 1].dx + pts[i].dx) / 2;
      path.cubicTo(
        midX, pts[i - 1].dy,
        midX, pts[i].dy,
        pts[i].dx, pts[i].dy,
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) => !listEquals(old.data, data);
}
