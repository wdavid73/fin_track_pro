part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to Firebase auth state changes on app start.
class AuthStarted extends AuthEvent {}

/// Internal: dispatched when Firebase emits a new auth state.
class AuthUserChanged extends AuthEvent {
  final UserEntity? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const AuthSignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}
