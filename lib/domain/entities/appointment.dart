import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:matibabu/domain/entities/user.dart';

part 'appointment.g.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed;

  bool get isActive => this == pending || this == confirmed;
}

@JsonSerializable()
class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String date;
  final String time;
  @JsonKey(unknownEnumValue: AppointmentStatus.pending)
  final AppointmentStatus status;
  final String address;
  final String notes;
  final User? doctor;
  final User? patient;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.time,
    this.status = AppointmentStatus.pending,
    this.address = '',
    this.notes = '',
    this.doctor,
    this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);

  DateTime get startsAt {
    final day = DateTime.parse(date);
    final [hour, minute] = time.split(':').map(int.parse).toList();
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  bool get isCancelled => status == AppointmentStatus.cancelled;

  bool isUpcomingAt(DateTime now) => status.isActive && startsAt.isAfter(now);

  bool isCompletedAt(DateTime now) =>
      status == AppointmentStatus.completed ||
      (status.isActive && !startsAt.isAfter(now));

  AppointmentStatus displayStatusAt(DateTime now) =>
      isCompletedAt(now) ? AppointmentStatus.completed : status;

  bool canCancelAt(DateTime now) => isUpcomingAt(now);

  bool canRemoveAt(DateTime now) => !isUpcomingAt(now);

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
    id: id,
    patientId: patientId,
    doctorId: doctorId,
    date: date,
    time: time,
    status: status ?? this.status,
    address: address,
    notes: notes,
    doctor: doctor,
    patient: patient,
  );

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    date,
    time,
    status,
    address,
    notes,
    doctor,
    patient,
  ];
}

class NewAppointment extends Equatable {
  final String doctorId;
  final String date;
  final String time;
  final String address;

  const NewAppointment({
    required this.doctorId,
    required this.date,
    required this.time,
    this.address = '',
  });

  Map<String, dynamic> toJson() => {
    'doctor_id': doctorId,
    'date': date,
    'time': time,
    'address': address,
  };

  @override
  List<Object?> get props => [doctorId, date, time, address];
}

@JsonSerializable()
class Slot extends Equatable {
  final String time;
  final bool available;

  const Slot({required this.time, required this.available});

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);

  Map<String, dynamic> toJson() => _$SlotToJson(this);

  @override
  List<Object?> get props => [time, available];
}

String apiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
