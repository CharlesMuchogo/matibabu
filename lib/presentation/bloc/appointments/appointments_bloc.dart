import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'appointments_event.dart';
part 'appointments_state.dart';

class AppointmentsBloc
    extends HydratedBloc<AppointmentsEvent, AppointmentsState>
    with SafeHandler {
  final AppointmentRepository _repository;

  AppointmentsBloc({required AppointmentRepository repository})
    : _repository = repository,
      super(const AppointmentsState()) {
    on<AppointmentsRequested>(_onRequested, transformer: restartable());
    on<AppointmentBooked>(
      (event, emit) => emit(state.withAppointment(event.appointment)),
    );
    on<AppointmentCancelRequested>(_onCancel, transformer: droppable());
    on<AppointmentRemoveRequested>(_onRemove, transformer: droppable());
  }

  @override
  String get storagePrefix => 'AppointmentsBloc';

  Future<void> _onRequested(
    AppointmentsRequested event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state.appointments.isEmpty) {
      emit(state.copyWith(status: Status.loading));
    }
    await guard(
      () async => emit(
        state.copyWith(
          status: Status.loaded,
          appointments: sortedByStart(await _repository.appointments()),
          message: '',
        ),
      ),
      (message) =>
          emit(state.copyWith(status: Status.failure, message: message)),
    );
  }

  Future<void> _onCancel(
    AppointmentCancelRequested event,
    Emitter<AppointmentsState> emit,
  ) => _runAction(emit, () async {
    final updated = await _repository.updateStatus(
      event.id,
      AppointmentStatus.cancelled,
    );
    return state.withAppointment(updated);
  });

  Future<void> _onRemove(
    AppointmentRemoveRequested event,
    Emitter<AppointmentsState> emit,
  ) => _runAction(emit, () async {
    await _repository.remove(event.id);
    return state.copyWith(
      appointments: state.appointments.where((a) => a.id != event.id).toList(),
    );
  });

  Future<void> _runAction(
    Emitter<AppointmentsState> emit,
    Future<AppointmentsState> Function() action,
  ) async {
    emit(state.copyWith(action: Status.loading, message: ''));
    await guard(
      () async => emit((await action()).copyWith(action: Status.loaded)),
      (message) =>
          emit(state.copyWith(action: Status.failure, message: message)),
    );
  }

  @override
  AppointmentsState? fromJson(Map<String, dynamic> json) =>
      AppointmentsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(AppointmentsState state) =>
      state.status == Status.loaded ? state.toMap() : null;
}
