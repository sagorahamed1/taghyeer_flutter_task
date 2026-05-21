import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getAll();
  Future<TransactionModel> save(TransactionModel t);
  Future<void> delete(String id);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final http.Client client;

  // using jsonplaceholder as a stand-in — swap with real backend
  static const _base = 'https://jsonplaceholder.typicode.com';

  TransactionRemoteDataSourceImpl({required this.client});

  static const _categories = [
    'Food', 'Transport', 'Shopping', 'Health', 'Entertainment',
  ];

  @override
  Future<List<TransactionModel>> getAll() async {
    final res = await client
        .get(Uri.parse('$_base/posts?_limit=15'))
        .timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) {
      throw Exception('Remote fetch failed: ${res.statusCode}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final post = entry.value as Map<String, dynamic>;
      return TransactionModel(
        id: post['id'].toString(),
        title: (post['title'] as String).split(' ').take(4).join(' '),
        amount: (i + 1) * 8.75,
        category: _categories[i % _categories.length],
        date: DateTime.now().subtract(Duration(days: i)),
        isSynced: true,
      );
    }).toList();
  }

  @override
  Future<TransactionModel> save(TransactionModel t) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 400));
    return t.copyWith(isSynced: true);
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
