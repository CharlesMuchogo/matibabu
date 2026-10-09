import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// A patient's appointment, as stored under `Patient/{uid}/My appointments`.
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String consultation;
  final String address;
  final String date;
  final String time;
  final String status;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.consultation,
    required this.address,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return Appointment(
      id: doc.id,
      doctorId: data["Doctor Id"] ?? "",
      doctorName: data["Doctor Name"] ?? "",
      consultation: data["Consultation"] ?? "",
      address: data["Address"] ?? "",
      date: data["Date"] ?? "",
      time: data["Time"] ?? "",
      status: data["Status"] ?? "Pending",
    );
  }

  /// Dates are stored as `DateFormat.yMMMd` (e.g. "Oct 8, 2026") and times as
  /// "h:mm a" (e.g. "2:30 PM"), so they have to be parsed to sort correctly.
  DateTime? get dateTime {
    try {
      final day = DateFormat.yMMMd("en_US").parse(date);
      final t = DateFormat("h:mm a", "en_US").parse(time);
      return DateTime(day.year, day.month, day.day, t.hour, t.minute);
    } catch (_) {
      return null;
    }
  }

  bool get isCancelled => status == "Cancelled";

  /// Upcoming = not cancelled and scheduled for later today or after.
  bool get isUpcoming {
    final dt = dateTime;
    return !isCancelled && dt != null && dt.isAfter(DateTime.now());
  }

  /// Past appointments that weren't cancelled count as completed visits.
  bool get isCompleted => !isCancelled && !isUpcoming;

  /// Status to show the user — a past pending/confirmed visit reads "Completed".
  String get displayStatus => isCompleted ? "Completed" : status;

  static List<Appointment> fromQuery(QuerySnapshot snapshot) {
    final list = snapshot.docs.map(Appointment.fromDoc).toList();
    list.sort((a, b) {
      final ad = a.dateTime, bd = b.dateTime;
      if (ad == null || bd == null) return 0;
      return ad.compareTo(bd);
    });
    return list;
  }
}
