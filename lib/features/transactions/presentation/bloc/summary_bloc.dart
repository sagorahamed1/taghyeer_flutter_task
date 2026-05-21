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

    // inter-bloc communication: react whenever transactions change
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

    final monthTotal = event.transactions
        .where((t) => t.date.isAfter(monthStart))
        .fold(0.0, (sum, t) => sum + t.amount);

    // bucket transactions into the last 7 days (index 0 = 6 days ago, 6 = today)
    final daily = List.filled(7, 0.0);
    for (final t in event.transactions) {
      final diff = now.difference(t.date).inDays;
      if (diff >= 0 && diff < 7) {
        daily[6 - diff] += t.amount;
      }
    }

    emit(state.copyWith(totalSpent: monthTotal, last7Days: daily));
  }

  void _onBudget(SetBudget event, Emitter<SummaryState> emit) {
    emit(state.copyWith(budget: event.budget));
  }

  @override
  Future<void> close() {
    // must cancel or the stream keeps the bloc alive after disposal
    _txSub.cancel();
    return super.close();
  }
}
