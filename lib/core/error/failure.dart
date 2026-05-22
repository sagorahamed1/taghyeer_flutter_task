import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// ************Cache Error *****************

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

/// ************Network Error *****************

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}


/// ************Server Error *****************

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}
