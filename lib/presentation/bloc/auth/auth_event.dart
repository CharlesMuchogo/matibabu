part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final Registration registration;

  const RegisterRequested(this.registration);

  @override
  List<Object?> get props => [registration];
}

class SocialLoginRequested extends AuthEvent {
  final SocialProvider provider;

  const SocialLoginRequested(this.provider);

  @override
  List<Object?> get props => [provider];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class AuthUserChanged extends AuthEvent {
  final User user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class _SessionExpired extends AuthEvent {
  const _SessionExpired();
}
