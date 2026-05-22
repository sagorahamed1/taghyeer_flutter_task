import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';

/// *********All event define here. What will be do user it is repository level *******>>

abstract class TransactionRepository {

  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  Future<Either<Failure, String>> deleteTransaction(String id);

}
