import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUnauthenticated()) {
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    if (!event.email.contains('@')) {
      emit(AuthFailure('Enter a valid email address'));
      return;
    }
    if (event.password.length < 6) {
      emit(AuthFailure('Password must be at least 6 characters'));
      return;
    }

    emit(AuthAuthenticated(event.email));
  }

  void _onLogout(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}
