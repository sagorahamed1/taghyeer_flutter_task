import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.category,
    required super.date,
    super.type,
    super.isSynced,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      type: (json['type'] as String?) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      isSynced: json['is_synced'] == 1 || json['is_synced'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type == TransactionType.income ? 'income' : 'expense',
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory TransactionModel.fromEntity(Transaction t) {
    return TransactionModel(
      id: t.id,
      title: t.title,
      amount: t.amount,
      category: t.category,
      date: t.date,
      type: t.type,
      isSynced: t.isSynced,
    );
  }

  @override
  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    TransactionType? type,
    bool? isSynced,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
