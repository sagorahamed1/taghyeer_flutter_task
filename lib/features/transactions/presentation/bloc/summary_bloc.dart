import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_bloc.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final TransactionBloc transactionBloc;
  late final StreamSubscription<TransactionState> _txSub;

  SummaryBloc({required this.transactionBloc}) : super(const SummaryState()) {
    on<_TransactionsUpdated>(_onUpdate);
    on<SetBudget>(_onBudget);

    _txSub = transactionBloc.stream.listen((txState) {
      if (txState is TransactionLoaded) {
        add(_TransactionsUpdated(txState.transactions));
      }
    });
  }

  void _onUpdate(
    _TransactionsUpdated event,
    Emitter<SummaryState> emit,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);

    double monthIncome = 0;
    double monthExpense = 0;
    final dailyIncome = List.filled(7, 0.0);
    final dailyExpense = List.filled(7, 0.0);

    for (final tnx in event.transactions) {
      final isIncome = tnx.type == TransactionType.income;

      /// ***** monthly

      if (tnx.date.isAfter(monthStart)) {
        if (isIncome) {
          monthIncome += tnx.amount;
        } else {
          monthExpense += tnx.amount;
        }
      }

      /// last 7 days

      final diff = now.difference(tnx.date).inDays;
      if (diff >= 0 && diff < 7) {
        final idx = 6 - diff;
        if (isIncome) {
          dailyIncome[idx] += tnx.amount;
        } else {
          dailyExpense[idx] += tnx.amount;
        }
      }
    }

    emit(state.copyWith(
      totalIncome: monthIncome,
      totalSpent: monthExpense,
      last7DaysIncome: dailyIncome,
      last7DaysExpense: dailyExpense,
    ));
  }

  void _onBudget(SetBudget event, Emitter<SummaryState> emit) {
    emit(state.copyWith(budget: event.budget));
  }

  @override
  Future<void> close() {
    _txSub.cancel();
    return super.close();
  }
}
