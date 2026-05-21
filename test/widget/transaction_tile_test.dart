import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendar/features/transactions/domain/entities/transaction.dart';
import 'package:spendar/features/transactions/presentation/widgets/transaction_tile.dart';

void main() {
  final tTransaction = Transaction(
    id: 'tile-1',
    title: 'Netflix',
    amount: 15.99,
    category: 'Entertainment',
    date: DateTime(2024, 5, 20),
  );

  testWidgets('shows title, amount and category icon', (tester) async {
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionTile(
            transaction: tTransaction,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('Netflix'), findsOneWidget);
    // expense shows with a minus prefix
    expect(find.text('-\$15.99'), findsOneWidget);
    expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    expect(deleted, isFalse);
  });

  testWidgets('income shows + prefix in green', (tester) async {
    final income = Transaction(
      id: 'income-1',
      title: 'Salary',
      amount: 2000,
      category: 'Salary',
      type: TransactionType.income,
      date: DateTime(2024, 5, 20),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionTile(transaction: income, onDelete: () {}),
        ),
      ),
    );

    expect(find.text('+\$2000.00'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
  });

  testWidgets('swipe left reveals delete background', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionTile(
            transaction: tTransaction,
            onDelete: () {},
          ),
        ),
      ),
    );

    // drag left, red hint should appear
    await tester.drag(find.text('Netflix'), const Offset(-60, 0));
    await tester.pump();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });
}
