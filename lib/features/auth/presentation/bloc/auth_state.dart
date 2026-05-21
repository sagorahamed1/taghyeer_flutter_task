part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String email;
  AuthAuthenticated(this.email);
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
