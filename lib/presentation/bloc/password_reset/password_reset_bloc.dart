import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState>
    with SafeHandler {
  final AuthRepository _repository;

  PasswordResetBloc({required AuthRepository repository})
    : _repository = repository,
      super(const PasswordResetState()) {
    on<PasswordResetCodeRequested>(_onCodeRequested, transformer: droppable());
    on<PasswordResetSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onCodeRequested(
    PasswordResetCodeRequested event,
    Emitter<PasswordResetState> emit,
  ) => _run(emit, () async {
    await _repository.requestPasswordReset(event.email);
    return PasswordResetState(
      step: PasswordResetStep.code,
      email: event.email.trim(),
    );
  });

  Future<void> _onSubmitted(
    PasswordResetSubmitted event,
    Emitter<PasswordResetState> emit,
  ) => _run(emit, () async {
    await _repository.resetPassword(
      email: state.email,
      code: event.code,
      newPassword: event.newPassword,
    );
    return state.copyWith(step: PasswordResetStep.done);
  });

  Future<void> _run(
    Emitter<PasswordResetState> emit,
    Future<PasswordResetState> Function() action,
  ) async {
    emit(state.copyWith(status: Status.loading, message: ''));
    await guard(
      () async => emit((await action()).copyWith(status: Status.loaded)),
      (message) =>
          emit(state.copyWith(status: Status.failure, message: message)),
    );
  }
}
