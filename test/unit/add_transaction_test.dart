import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendar/core/error/failure.dart';
import 'package:spendar/features/transactions/domain/entities/transaction.dart';
import 'package:spendar/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:spendar/features/transactions/domain/usecases/add_transaction.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late AddTransaction useCase;
  late MockTransactionRepository mockRepo;

  final tTransaction = Transaction(
    id: 'abc-123',
    title: 'Lunch',
    amount: 12.0,
    category: 'Food',
    date: DateTime(2024, 5, 10),
  );

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = AddTransaction(mockRepo);
    registerFallbackValue(tTransaction);
  });

  test('returns the saved transaction on success', () async {
    when(() => mockRepo.addTransaction(any()))
        .thenAnswer((_) async => Right(tTransaction));

    final result = await useCase(AddTransactionParams(tTransaction));

    expect(result, Right(tTransaction));
    verify(() => mockRepo.addTransaction(tTransaction)).called(1);
  });

  test('returns CacheFailure when local save fails', () async {
    when(() => mockRepo.addTransaction(any()))
        .thenAnswer((_) async => const Left(CacheFailure('DB write failed')));

    final result = await useCase(AddTransactionParams(tTransaction));

    expect(result, const Left(CacheFailure('DB write failed')));
  });
}
