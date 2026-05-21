import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SpendingChart extends StatelessWidget {
  final List<double> income;   // 7 daily values, oldest → newest
  final List<double> expenses;

  const SpendingChart({
    super.key,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: CustomPaint(
        size: const Size(double.infinity, 110),
        painter: _ChartPainter(income: income, expenses: expenses),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> income;
  final List<double> expenses;

  static const _incomeColor = Color(0xFF06D6A0);  // green
  static const _expenseColor = Color(0xFFFF6B6B); // red

  const _ChartPainter({required this.income, required this.expenses});

  @override
  void paint(Canvas canvas, Size size) {
    if (income.length < 2 || expenses.length < 2) return;

    final allValues = [...income, ...expenses];
    final maxVal = allValues.reduce(max);
    if (maxVal == 0) return;

    _drawSeries(canvas, size, income, _incomeColor, maxVal);
    _drawSeries(canvas, size, expenses, _expenseColor, maxVal);
  }

  void _drawSeries(
    Canvas canvas,
    Size size,
    List<double> data,
    Color color,
    double maxVal,
  ) {
    const topPad = 8.0;
    const bottomPad = 6.0;
    final stepX = size.width / (data.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height -
          bottomPad -
          (data[i] / maxVal) * (size.height - topPad - bottomPad);
      points.add(Offset(x, y));
    }

    // gradient fill under curve
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
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    _addCurve(linePath, points);

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // dots
    for (final p in points) {
      canvas.drawCircle(p, 3.5, Paint()..color = color);
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
  bool shouldRepaint(_ChartPainter old) {
    return !listEquals(old.income, income) ||
        !listEquals(old.expenses, expenses);
  }
}
