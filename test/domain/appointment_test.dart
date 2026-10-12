import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/entities/appointment.dart';

import '../helpers/fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 14, 12);

  test('combines the date and time into a local start time', () {
    expect(
      appointment(date: '2026-10-08', time: '14:30').startsAt,
      DateTime(2026, 10, 8, 14, 30),
    );
  });

  test('classifies upcoming, completed and cancelled appointments', () {
    final upcoming = appointment(date: '2026-10-15');
    expect(upcoming.isUpcomingAt(now), isTrue);
    expect(upcoming.canCancelAt(now), isTrue);
    expect(upcoming.displayStatusAt(now), AppointmentStatus.pending);

    final past = appointment(
      date: '2026-10-13',
      status: AppointmentStatus.confirmed,
    );
    expect(past.isCompletedAt(now), isTrue);
    expect(past.canRemoveAt(now), isTrue);
    expect(past.displayStatusAt(now), AppointmentStatus.completed);

    final cancelled = appointment(
      date: '2026-10-15',
      status: AppointmentStatus.cancelled,
    );
    expect(cancelled.isCancelled, isTrue);
    expect(cancelled.isUpcomingAt(now), isFalse);
    expect(cancelled.isCompletedAt(now), isFalse);
    expect(cancelled.canRemoveAt(now), isTrue);
  });

  test('an appointment later today is still upcoming', () {
    expect(
      appointment(date: '2026-10-14', time: '14:00').isUpcomingAt(now),
      isTrue,
    );
    expect(
      appointment(date: '2026-10-14', time: '11:30').isUpcomingAt(now),
      isFalse,
    );
  });

  test('round trips through json', () {
    final original = appointment();
    expect(Appointment.fromJson(original.toJson()), original);
  });

  test('parses the API shape and tolerates unknown statuses', () {
    final parsed = Appointment.fromJson({
      'id': 'appointment-1',
      'patient_id': 'patient-1',
      'doctor_id': 'doctor-2',
      'date': '2026-10-14',
      'time': '09:30',
      'status': 'rescheduled',
      'address': 'Clinic',
      'notes': '',
      'created_at': '2026-10-12T21:45:02.303861+03:00',
    });
    expect(parsed.status, AppointmentStatus.pending);
    expect(parsed.doctor, isNull);
  });

  test('formats dates for the API with zero padding', () {
    expect(apiDate(DateTime(2026, 3, 7)), '2026-03-07');
  });

  test('new appointments serialise in the shape the API expects', () {
    expect(
      const NewAppointment(
        doctorId: 'doctor-2',
        date: '2026-10-14',
        time: '09:30',
        address: 'Clinic',
      ).toJson(),
      {
        'doctor_id': 'doctor-2',
        'date': '2026-10-14',
        'time': '09:30',
        'address': 'Clinic',
      },
    );
  });
}
