import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransactionEvent>(_onAdd);
    on<DeleteTransactionEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await getTransactions(NoParams());
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (list) => emit(TransactionLoaded(list)),
    );
  }

  Future<void> _onAdd(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final before = state;

    /// ****  show the item immediately before the fatch data save ******
    if (before is TransactionLoaded) {
      emit(TransactionLoaded([event.transaction, ...before.transactions]));
    }

    final result = await addTransaction(AddTransactionParams(event.transaction));

    result.fold(
      (failure) {

        if (before is TransactionLoaded) {
          emit(TransactionLoaded(before.transactions));
        }
        emit(TransactionError(failure.message, previous: _currentList));
      },
      (saved) {

        final current = state;
        if (current is TransactionLoaded) {
          final updated = current.transactions
              .map((t) => t.id == saved.id ? saved : t)
              .toList();
          emit(TransactionLoaded(updated));
        }
      },
    );
  }

  Future<void> _onDelete(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final before = state;


    if (before is TransactionLoaded) {
      final removed =
          before.transactions.where((t) => t.id != event.id).toList();
      emit(TransactionLoaded(removed));
    }

    final result = await deleteTransaction(DeleteTransactionParams(event.id));

    result.fold(
      (failure) {

        if (before is TransactionLoaded) {
          emit(TransactionLoaded(before.transactions));
        }
        emit(TransactionError(failure.message));
      },
      (_) {},
    );
  }

  List<Transaction>? get _currentList {
    final s = state;
    return s is TransactionLoaded ? s.transactions : null;
  }
}
