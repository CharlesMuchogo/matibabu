import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> with SafeHandler {
  final DoctorRepository _doctors;
  final AppointmentRepository _appointments;
  final User doctor;

  BookingBloc({
    required DoctorRepository doctorRepository,
    required AppointmentRepository appointmentRepository,
    required this.doctor,
  }) : _doctors = doctorRepository,
       _appointments = appointmentRepository,
       super(const BookingState()) {
    on<BookingDateSelected>(_onDateSelected, transformer: restartable());
    on<BookingTimeSelected>(
      (event, emit) => emit(state.copyWith(time: event.time)),
    );
    on<BookingSubmitted>(_onSubmitted, transformer: droppable());
  }

  Future<void> _onDateSelected(
    BookingDateSelected event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingState(date: event.date, slotsStatus: Status.loading));
    await _loadSlots(emit);
  }

  Future<void> _loadSlots(Emitter<BookingState> emit) => guard(
    () async {
      final slots = await _doctors.availability(
        doctorId: doctor.id,
        date: state.date!,
      );
      emit(
        state.copyWith(
          slotsStatus: Status.loaded,
          slots: slots.where((s) => s.available).toList(),
        ),
      );
    },
    (message) =>
        emit(state.copyWith(slotsStatus: Status.failure, message: message)),
  );

  Future<void> _onSubmitted(
    BookingSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    final date = state.date;
    final time = state.time;
    if (date == null || time == null) {
      return emit(
        state.copyWith(
          submitStatus: Status.failure,
          message: 'Pick both a date and a time.',
        ),
      );
    }

    emit(state.copyWith(submitStatus: Status.loading, message: ''));
    await guard(
      () async {
        final appointment = await _appointments.book(
          NewAppointment(
            doctorId: doctor.id,
            date: apiDate(date),
            time: time,
            address: doctor.hospital,
          ),
        );
        emit(
          state.copyWith(submitStatus: Status.loaded, appointment: appointment),
        );
      },
      (message) => emit(
        BookingState(
          date: date,
          slotsStatus: Status.loading,
          submitStatus: Status.failure,
          message: message,
        ),
      ),
    );
    if (state.appointment == null) await _loadSlots(emit);
  }
}
