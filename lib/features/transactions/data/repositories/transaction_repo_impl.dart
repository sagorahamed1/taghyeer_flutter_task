import 'dart:isolate';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_ds.dart';
import '../datasources/transaction_remote_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource local;
  final TransactionRemoteDataSource remote;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.local,
    required this.remote,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {

      /// load from local immediately so there's no loading flash

      final localData = await local.getAll();

      if (await networkInfo.isConnected) {

        /// fire-and-forget: sync in background without blocking the caller

        _backgroundSync(localData);

      }

      return Right(localData);

    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    Transaction transaction,
  ) async {
    final model = TransactionModel.fromEntity(transaction);
    try {

      /// write locally first (offline-first write)

      await local.save(model);

      if (await networkInfo.isConnected) {
        final synced = await remote.save(model);
        await local.save(synced); // update isSynced flag
        return Right(synced);
      } else {

        /// ****** Call later when we're back online ******

        await local.enqueuePendingOp('add', model.toJson());

        return Right(model);

      }
    } catch (e) {
      await local.delete(model.id);
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteTransaction(String id) async {
    try {
      await local.delete(id);

      if (await networkInfo.isConnected) {
        await remote.delete(id);
      } else {
        await local.enqueuePendingOp('delete', {'id': id});
      }

      return Right(id);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<void> _backgroundSync(List<TransactionModel> localData) async {
    try {
      final remoteData = await remote.getAll();

      /// ****** heavy diff runs in an isolate to avoid jank on the main thread

       final merged = await Isolate.run(
        () => _diffTransactions(localData, remoteData),
      );

      await local.saveAll(merged);
    } catch (_) {

    }
  }
}

/// *********** top-level so Isolate.run can serialize it *******

List<TransactionModel> _diffTransactions(
  List<TransactionModel> local,
  List<TransactionModel> remote,
) {
  final localById = {for (final t in local) t.id: t};

  final result = <TransactionModel>[];

  /// keep local entries that have not fetch yet (pending writes)

  for (final t in local) {
    if (!t.isSynced) result.add(t);
  }


  for (final t in remote) {
    final existing = localById[t.id];
    if (existing != null && !existing.isSynced) continue; // keep local
    result.add(t);
  }

  result.sort((a, b) => b.date.compareTo(a.date));
  return result;
}
