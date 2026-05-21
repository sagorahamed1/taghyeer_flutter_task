import 'package:flutter_test/flutter_test.dart';
import 'package:spendar/features/transactions/data/models/transaction_model.dart';
import 'package:spendar/features/transactions/domain/entities/transaction.dart';

void main() {
  final tDate = DateTime(2024, 6, 15);

  final tModel = TransactionModel(
    id: 'model-1',
    title: 'Groceries',
    amount: 55.25,
    category: 'Shopping',
    date: tDate,
    isSynced: true,
  );

  final tJson = {
    'id': 'model-1',
    'title': 'Groceries',
    'amount': 55.25,
    'category': 'Shopping',
    'date': tDate.toIso8601String(),
    'is_synced': 1,
  };

  group('fromJson', () {
    test('creates correct model from sqflite row', () {
      final result = TransactionModel.fromJson(tJson);
      expect(result.id, 'model-1');
      expect(result.amount, 55.25);
      expect(result.isSynced, isTrue);
    });

    test('handles is_synced sent as bool from remote', () {
      final json = {...tJson, 'is_synced': true};
      final result = TransactionModel.fromJson(json);
      expect(result.isSynced, isTrue);
    });
  });

  group('toJson', () {
    test('serialises to correct sqflite map', () {
      final json = tModel.toJson();
      expect(json['id'], 'model-1');
      expect(json['amount'], 55.25);
      expect(json['is_synced'], 1); // booleans go in as int for sqflite
    });

    test('roundtrip: fromJson(toJson()) preserves all fields', () {
      final json = tModel.toJson();
      final restored = TransactionModel.fromJson(json);
      expect(restored, equals(tModel));
    });
  });

  test('fromEntity wraps a domain Transaction without data loss', () {
    final entity = Transaction(
      id: 'ent-1',
      title: 'Taxi',
      amount: 14.0,
      category: 'Transport',
      date: tDate,
    );
    final model = TransactionModel.fromEntity(entity);
    expect(model.id, entity.id);
    expect(model.title, entity.title);
    expect(model.amount, entity.amount);
    expect(model.isSynced, isFalse);
  });
}
