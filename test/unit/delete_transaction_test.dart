import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendar/core/error/failure.dart';
import 'package:spendar/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:spendar/features/transactions/domain/usecases/delete_transaction.dart';

class MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  late DeleteTransaction useCase;
  late MockTransactionRepository mockRepo;

  setUp(() {
    mockRepo = MockTransactionRepository();
    useCase = DeleteTransaction(mockRepo);
  });

  const tId = 'tx-999';

  test('returns deleted id on success', () async {
    when(() => mockRepo.deleteTransaction(tId))
        .thenAnswer((_) async => const Right(tId));

    final result = await useCase(DeleteTransactionParams(tId));

    expect(result, const Right(tId));
    verify(() => mockRepo.deleteTransaction(tId)).called(1);
  });

  test('returns CacheFailure when delete fails', () async {
    when(() => mockRepo.deleteTransaction(tId))
        .thenAnswer((_) async => const Left(CacheFailure('delete failed')));

    final result = await useCase(const DeleteTransactionParams(tId));

    expect(result, const Left(CacheFailure('delete failed')));
  });
}
