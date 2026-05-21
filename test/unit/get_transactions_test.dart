import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendar/core/error/failure.dart';
import 'package:spendar/core/usecases/usecase.dart';
import 'package:spendar/features/transactions/domain/entities/transaction.dart';
import 'package:spendar/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:spendar/features/transactions/domain/usecases/get_transactions.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late GetTransactions useCase;
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = GetTransactions(mockRepo);
  });

  final tList = [
    Transaction(
      id: '1',
      title: 'Coffee',
      amount: 4.5,
      category: 'Food',
      date: DateTime(2024, 5, 1),
    ),
  ];

  test('returns list of transactions from repository', () async {
    when(() => mockRepo.getTransactions())
        .thenAnswer((_) async => Right(tList));

    final result = await useCase(NoParams());

    expect(result, Right(tList));
    verify(() => mockRepo.getTransactions()).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('returns CacheFailure when repository throws', () async {
    when(() => mockRepo.getTransactions())
        .thenAnswer((_) async => const Left(CacheFailure()));

    final result = await useCase(NoParams());

    expect(result, const Left(CacheFailure()));
  });
}
