import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'core/network/network_info.dart';
import 'features/transactions/data/datasources/transaction_local_ds.dart';
import 'features/transactions/data/datasources/transaction_remote_ds.dart';
import 'features/transactions/data/repositories/transaction_repo_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/transactions/domain/usecases/add_transaction.dart';
import 'features/transactions/domain/usecases/delete_transaction.dart';
import 'features/transactions/domain/usecases/get_transactions.dart';
import 'features/transactions/presentation/bloc/summary_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => TransactionBloc(
        getTransactions: sl(),
        addTransaction: sl(),
        deleteTransaction: sl(),
      ));

  sl.registerLazySingleton(() => SummaryBloc(transactionBloc: sl()));

  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      local: sl(),
      remote: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(db: sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  final db = await _openDatabase();
  sl.registerLazySingleton(() => db);
}

Future<Database> _openDatabase() async {
  final dbPath = await getDatabasesPath();
  return openDatabase(
    join(dbPath, 'spendar.db'),
    version: 2,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE transactions(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date TEXT NOT NULL,
          type TEXT NOT NULL DEFAULT 'expense',
          is_synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE pending_ops(
          id TEXT PRIMARY KEY,
          op_type TEXT NOT NULL,
          payload TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          "ALTER TABLE transactions ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'",
        );
      }
    },
  );
}
