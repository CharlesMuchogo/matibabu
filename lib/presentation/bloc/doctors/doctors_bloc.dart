import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'doctors_event.dart';
part 'doctors_state.dart';

class DoctorsBloc extends HydratedBloc<DoctorsEvent, DoctorsState>
    with SafeHandler {
  final DoctorRepository _repository;
  final String? categoryId;
  final String _id;
  final Duration _debounce;

  DoctorsBloc({
    required DoctorRepository repository,
    required String storageId,
    this.categoryId,
    Duration debounce = const Duration(milliseconds: 350),
  }) : _repository = repository,
       _id = storageId,
       _debounce = debounce,
       super(const DoctorsState()) {
    on<DoctorsRequested>(
      (event, emit) => _fetch(emit),
      transformer: restartable(),
    );
    on<DoctorsQueryChanged>(_onQueryChanged, transformer: restartable());
  }

  @override
  String get storagePrefix => 'DoctorsBloc';

  @override
  String get id => _id;

  Future<void> _onQueryChanged(
    DoctorsQueryChanged event,
    Emitter<DoctorsState> emit,
  ) async {
    emit(state.copyWith(query: event.query));
    await Future<void>.delayed(_debounce);
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<DoctorsState> emit) async {
    if (state.doctors.isEmpty) emit(state.copyWith(status: Status.loading));
    await guard(
      () async {
        final doctors = await _repository.doctors(
          categoryId: categoryId,
          query: state.query,
        );
        emit(
          state.copyWith(status: Status.loaded, doctors: doctors, message: ''),
        );
      },
      (message) =>
          emit(state.copyWith(status: Status.failure, message: message)),
    );
  }

  @override
  DoctorsState? fromJson(Map<String, dynamic> json) =>
      DoctorsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(DoctorsState state) =>
      state.status == Status.loaded ? state.toMap() : null;
}
