import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_out.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateChanges _getAuthStateChanges;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({
    required GetAuthStateChanges getAuthStateChanges,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
  }) : _getAuthStateChanges = getAuthStateChanges,
       _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signOut = signOut,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInWithEmailRequested>(_onSignInWithEmail);
    on<AuthSignUpWithEmailRequested>(_onSignUpWithEmail);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignOutRequested>(_onSignOut);
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _authSubscription?.cancel();
    _authSubscription = _getAuthStateChanges().listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      event.user != null
          ? AuthState(status: AuthStatus.authenticated, user: event.user)
          : const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      LoggerService().error(e.toString(), tag: 'AuthBloc');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signUpWithEmail(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signInWithGoogle();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
