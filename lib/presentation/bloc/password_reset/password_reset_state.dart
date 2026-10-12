part of 'password_reset_bloc.dart';

enum PasswordResetStep { email, code, done }

class PasswordResetState extends Equatable {
  final PasswordResetStep step;
  final Status status;
  final String email;
  final String message;

  const PasswordResetState({
    this.step = PasswordResetStep.email,
    this.status = Status.initial,
    this.email = '',
    this.message = '',
  });

  PasswordResetState copyWith({
    PasswordResetStep? step,
    Status? status,
    String? message,
  }) => PasswordResetState(
    step: step ?? this.step,
    status: status ?? this.status,
    email: email,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [step, status, email, message];
}
