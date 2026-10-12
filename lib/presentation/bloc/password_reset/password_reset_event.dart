part of 'password_reset_bloc.dart';

sealed class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

class PasswordResetCodeRequested extends PasswordResetEvent {
  final String email;

  const PasswordResetCodeRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordResetSubmitted extends PasswordResetEvent {
  final String code;
  final String newPassword;

  const PasswordResetSubmitted({required this.code, required this.newPassword});

  @override
  List<Object?> get props => [code, newPassword];
}
