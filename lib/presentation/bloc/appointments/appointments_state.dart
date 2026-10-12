part of 'appointments_bloc.dart';

List<Appointment> sortedByStart(Iterable<Appointment> appointments) =>
    appointments.toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt));

class AppointmentsState extends Equatable {
  final Status status;
  final List<Appointment> appointments;
  final Status action;
  final String message;

  const AppointmentsState({
    this.status = Status.initial,
    this.appointments = const [],
    this.action = Status.initial,
    this.message = '',
  });

  List<Appointment> upcomingAt(DateTime now) =>
      appointments.where((a) => a.isUpcomingAt(now)).toList();

  Appointment? byId(String id) =>
      appointments.where((a) => a.id == id).firstOrNull;

  AppointmentsState withAppointment(Appointment appointment) => copyWith(
    appointments: sortedByStart([
      ...appointments.where((a) => a.id != appointment.id),
      appointment,
    ]),
  );

  AppointmentsState copyWith({
    Status? status,
    List<Appointment>? appointments,
    Status? action,
    String? message,
  }) => AppointmentsState(
    status: status ?? this.status,
    appointments: appointments ?? this.appointments,
    action: action ?? this.action,
    message: message ?? this.message,
  );

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'appointments': appointments.map((a) => a.toJson()).toList(),
  };

  factory AppointmentsState.fromMap(Map<String, dynamic> map) =>
      AppointmentsState(
        status: Status.values.byName(map['status'] as String),
        appointments: listFromJson(map['appointments'], Appointment.fromJson),
      );

  @override
  List<Object?> get props => [status, appointments, action, message];
}
