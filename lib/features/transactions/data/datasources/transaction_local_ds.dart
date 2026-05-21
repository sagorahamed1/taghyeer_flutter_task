import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<void> save(TransactionModel t);
  Future<void> delete(String id);
  Future<void> saveAll(List<TransactionModel> list);
  Future<void> enqueuePendingOp(String opType, Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getPendingOps();
  Future<void> removePendingOp(String id);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Database db;

  TransactionLocalDataSourceImpl({required this.db});

  @override
  Future<List<TransactionModel>> getAll() async {
    final rows = await db.query('transactions', orderBy: 'date DESC');
    return rows.map((r) => TransactionModel.fromJson(r)).toList();
  }

  @override
  Future<void> save(TransactionModel t) async {
    await db.insert(
      'transactions',
      t.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveAll(List<TransactionModel> list) async {
    final batch = db.batch();
    for (final t in list) {
      batch.insert(
        'transactions',
        t.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> enqueuePendingOp(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    await db.insert('pending_ops', {
      'id': '${opType}_${payload['id']}_${DateTime.now().millisecondsSinceEpoch}',
      'op_type': opType,
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingOps() {
    return db.query('pending_ops', orderBy: 'created_at ASC');
  }

  @override
  Future<void> removePendingOp(String id) async {
    await db.delete('pending_ops', where: 'id = ?', whereArgs: [id]);
  }
}
