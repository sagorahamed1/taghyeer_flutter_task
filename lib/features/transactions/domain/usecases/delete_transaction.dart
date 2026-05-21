import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction extends UseCase<String, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteTransactionParams params) {
    return repository.deleteTransaction(params.id);
  }
}

class DeleteTransactionParams extends Equatable {
  final String id;

  // ignore: prefer_const_constructors_in_immutables — Equatable has no const ctor
  DeleteTransactionParams(this.id);

  @override
  List<Object?> get props => [id];
}
