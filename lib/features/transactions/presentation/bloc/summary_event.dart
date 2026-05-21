part of 'summary_bloc.dart';

abstract class SummaryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class _TransactionsUpdated extends SummaryEvent {
  final List<Transaction> transactions;

  _TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class SetBudget extends SummaryEvent {
  final double budget;

  SetBudget(this.budget);

  @override
  List<Object?> get props => [budget];
}
