import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendar/core/error/failure.dart';
import 'package:spendar/core/usecases/usecase.dart';
import 'package:spendar/features/transactions/domain/entities/transaction.dart';
import 'package:spendar/features/transactions/domain/usecases/add_transaction.dart';
import 'package:spendar/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:spendar/features/transactions/domain/usecases/get_transactions.dart';
import 'package:spendar/features/transactions/presentation/bloc/transaction_bloc.dart';

class MockGetTransactions extends Mock implements GetTransactions {}

class MockAddTransaction extends Mock implements AddTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

void main() {
  late TransactionBloc bloc;
  late MockGetTransactions mockGet;
  late MockAddTransaction mockAdd;
  late MockDeleteTransaction mockDelete;

  final tTransaction = Transaction(
    id: 'tx-1',
    title: 'Coffee',
    amount: 4.5,
    category: 'Food',
    date: DateTime(2024, 5, 1),
  );

  setUp(() {
    mockGet = MockGetTransactions();
    mockAdd = MockAddTransaction();
    mockDelete = MockDeleteTransaction();

    registerFallbackValue(NoParams());
    registerFallbackValue(AddTransactionParams(tTransaction));
    registerFallbackValue(DeleteTransactionParams('tx-1'));

    bloc = TransactionBloc(
      getTransactions: mockGet,
      addTransaction: mockAdd,
      deleteTransaction: mockDelete,
    );
  });

  tearDown(() => bloc.close());

  test('initial state is TransactionInitial', () {
    expect(bloc.state, isA<TransactionInitial>());
  });

  blocTest<TransactionBloc, TransactionState>(
    'LoadTransactions emits [Loading, Loaded] on success',
    build: () {
      when(() => mockGet(any()))
          .thenAnswer((_) async => Right([tTransaction]));
      return bloc;
    },
    act: (b) => b.add(LoadTransactions()),
    expect: () => [
      isA<TransactionLoading>(),
      isA<TransactionLoaded>().having(
        (s) => s.transactions,
        'transactions',
        [tTransaction],
      ),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'AddTransactionEvent applies optimistic update then confirms with isSynced',
    build: () {
      // remote save returns the same item but with isSynced = true
      final confirmed = Transaction(
        id: tTransaction.id,
        title: tTransaction.title,
        amount: tTransaction.amount,
        category: tTransaction.category,
        date: tTransaction.date,
        isSynced: true,
      );
      when(() => mockAdd(any())).thenAnswer((_) async => Right(confirmed));
      return bloc;
    },
    seed: () => TransactionLoaded(const []),
    act: (b) => b.add(AddTransactionEvent(tTransaction)),
    expect: () => [
      // optimistic: isSynced is false
      isA<TransactionLoaded>().having(
        (s) => s.transactions.first.isSynced,
        'optimistic isSynced',
        isFalse,
      ),
      // confirmed: isSynced flipped to true
      isA<TransactionLoaded>().having(
        (s) => s.transactions.first.isSynced,
        'confirmed isSynced',
        isTrue,
      ),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'AddTransactionEvent rolls back on repository failure',
    build: () {
      when(() => mockAdd(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));
      return bloc;
    },
    seed: () => TransactionLoaded(const []),
    act: (b) => b.add(AddTransactionEvent(tTransaction)),
    expect: () => [
      // optimistic insert
      isA<TransactionLoaded>().having(
        (s) => s.transactions,
        'optimistic',
        contains(tTransaction),
      ),
      // rolled back to empty list
      isA<TransactionLoaded>().having(
        (s) => s.transactions,
        'rolled back',
        isEmpty,
      ),
      // error shown to user
      isA<TransactionError>(),
    ],
  );

  blocTest<TransactionBloc, TransactionState>(
    'DeleteTransactionEvent removes item optimistically',
    build: () {
      when(() => mockDelete(any()))
          .thenAnswer((_) async => const Right('tx-1'));
      return bloc;
    },
    seed: () => TransactionLoaded([tTransaction]),

    act: (b) => b.add(DeleteTransactionEvent('tx-1')),
    expect: () => [
      isA<TransactionLoaded>().having(
        (s) => s.transactions,
        'item removed',
        isEmpty,
      ),
    ],
  );
}
