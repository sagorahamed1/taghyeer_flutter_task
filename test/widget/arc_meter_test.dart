import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendar/features/transactions/presentation/widgets/arc_meter.dart';

void main() {
  testWidgets('ArcMeter displays spent and budget amounts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ArcMeter(
              progress: 0.6,
              spent: 600,
              budget: 1000,
            ),
          ),
        ),
      ),
    );


    await tester.pumpAndSettle();

    expect(find.text('\$600'), findsOneWidget);
    expect(find.text('of \$1000 budget'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('ArcMeter shows zero state without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ArcMeter(
            progress: 0,
            spent: 0,
            budget: 500,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('\$0'), findsOneWidget);
  });
}
