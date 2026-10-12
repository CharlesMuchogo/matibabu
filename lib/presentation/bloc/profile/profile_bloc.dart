import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> with SafeHandler {
  final UserRepository _repository;

  ProfileBloc({required UserRepository repository})
    : _repository = repository,
      super(const ProfileState()) {
    on<ProfileUpdateSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileState(status: Status.loading, kind: event.kind));
    await guard(
      () async => emit(
        ProfileState(
          status: Status.loaded,
          kind: event.kind,
          user: await _repository.updateProfile(event.update),
        ),
      ),
      (message) => emit(
        ProfileState(
          status: Status.failure,
          kind: event.kind,
          message: message,
        ),
      ),
    );
  }
}
