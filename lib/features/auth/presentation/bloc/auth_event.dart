part of 'auth_bloc.dart';

abstract class AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}
