import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/transaction.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel> save(TransactionModel t);
  Future<void> delete(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  static const _base = 'https://jsonplaceholder.typicode.com';

  TransactionRemoteDataSourceImpl({required this.client});

  static const _expenseCategories = [
    'Food', 'Transport', 'Shopping', 'Health', 'Entertainment',
  ];
  static const _incomeCategories = [
    'Salary', 'Freelance', 'Investment', 'Gift',
  ];

  @override
  Future<List<TransactionModel>> getAll() async {
    final res = await client
        .get(Uri.parse('$_base/posts?_limit=14'))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Remote fetch failed: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final post = entry.value as Map<String, dynamic>;

      // every 3rd entry is income, rest are expenses
      final isIncome = i % 3 == 2;
      final type = isIncome ? TransactionType.income : TransactionType.expense;
      final category = isIncome
          ? _incomeCategories[i % _incomeCategories.length]
          : _expenseCategories[i % _expenseCategories.length];

      return TransactionModel(
        id: post['id'].toString(),
        title: (post['title'] as String).split(' ').take(4).join(' '),
        amount: isIncome ? (i + 1) * 45.0 : (i + 1) * 8.75,
        category: category,
        type: type,
        date: DateTime.now().subtract(Duration(days: i)),
        isSynced: true,
      );
    }).toList();
  }

  @override
  Future<TransactionModel> save(TransactionModel t) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return t.copyWith(isSynced: true);
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
