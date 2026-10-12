// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: json['id'] as String,
  patientId: json['patient_id'] as String,
  doctorId: json['doctor_id'] as String,
  date: json['date'] as String,
  time: json['time'] as String,
  status:
      $enumDecodeNullable(
        _$AppointmentStatusEnumMap,
        json['status'],
        unknownValue: AppointmentStatus.pending,
      ) ??
      AppointmentStatus.pending,
  address: json['address'] as String? ?? '',
  notes: json['notes'] as String? ?? '',
  doctor: json['doctor'] == null
      ? null
      : User.fromJson(json['doctor'] as Map<String, dynamic>),
  patient: json['patient'] == null
      ? null
      : User.fromJson(json['patient'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'doctor_id': instance.doctorId,
      'date': instance.date,
      'time': instance.time,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'address': instance.address,
      'notes': instance.notes,
      'doctor': instance.doctor?.toJson(),
      'patient': instance.patient?.toJson(),
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.pending: 'pending',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.completed: 'completed',
};

Slot _$SlotFromJson(Map<String, dynamic> json) =>
    Slot(time: json['time'] as String, available: json['available'] as bool);

Map<String, dynamic> _$SlotToJson(Slot instance) => <String, dynamic>{
  'time': instance.time,
  'available': instance.available,
};
