part of 'appointments_bloc.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();

  @override
  List<Object?> get props => [];
}

class AppointmentsRequested extends AppointmentsEvent {
  const AppointmentsRequested();
}

class AppointmentBooked extends AppointmentsEvent {
  final Appointment appointment;

  const AppointmentBooked(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

class AppointmentCancelRequested extends AppointmentsEvent {
  final String id;

  const AppointmentCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class AppointmentRemoveRequested extends AppointmentsEvent {
  final String id;

  const AppointmentRemoveRequested(this.id);

  @override
  List<Object?> get props => [id];
}
