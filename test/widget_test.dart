import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:matibabu/models/appointment.dart';

Appointment _appt(DateTime day, String time, {String status = "Pending"}) =>
    Appointment(
      id: "x",
      doctorId: "d",
      doctorName: "Dr. Test",
      consultation: "Dentist",
      address: "Nairobi",
      date: DateFormat.yMMMd("en_US").format(day),
      time: time,
      status: status,
    );

void main() {
  test('parses stored date and time strings', () {
    final a = _appt(DateTime(2026, 10, 8), "2:30 PM");
    expect(a.dateTime, DateTime(2026, 10, 8, 14, 30));
  });

  test('classifies upcoming, completed and cancelled', () {
    final future = DateTime.now().add(const Duration(days: 3));
    final past = DateTime.now().subtract(const Duration(days: 3));

    final upcoming = _appt(future, "09:00 AM");
    expect(upcoming.isUpcoming, isTrue);
    expect(upcoming.displayStatus, "Pending");

    final completed = _appt(past, "09:00 AM", status: "Confirmed");
    expect(completed.isCompleted, isTrue);
    expect(completed.displayStatus, "Completed");

    final cancelled = _appt(future, "09:00 AM", status: "Cancelled");
    expect(cancelled.isCancelled, isTrue);
    expect(cancelled.isUpcoming, isFalse);
    expect(cancelled.isCompleted, isFalse);
  });

  test('unparseable dates are neither upcoming nor crash', () {
    const a = Appointment(
      id: "x",
      doctorId: "d",
      doctorName: "n",
      consultation: "c",
      address: "a",
      date: "garbage",
      time: "??",
      status: "Pending",
    );
    expect(a.dateTime, isNull);
    expect(a.isUpcoming, isFalse);
  });
}
