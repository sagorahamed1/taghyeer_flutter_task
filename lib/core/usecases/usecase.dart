import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failure.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

///***** use when a use case needs no input *****
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
