part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}
