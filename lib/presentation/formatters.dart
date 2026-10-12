import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matibabu/domain/entities/appointment.dart';

String formatDate(DateTime date) => DateFormat.yMMMd().format(date);

String formatTime(DateTime date) => DateFormat.jm().format(date);

String formatSlot(DateTime date, String time) {
  final [hour, minute] = time.split(':').map(int.parse).toList();
  return formatTime(DateTime(date.year, date.month, date.day, hour, minute));
}

String statusLabel(AppointmentStatus status) =>
    '${status.name[0].toUpperCase()}${status.name.substring(1)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String chatDayLabel(BuildContext context, DateTime date) {
  final now = DateTime.now();
  if (isSameDay(date, now)) return "Today";
  if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return "Yesterday";
  }
  return MaterialLocalizations.of(context).formatMediumDate(date);
}

String chatTimeLabel(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(date));

String chatListTimeLabel(BuildContext context, DateTime date) =>
    isSameDay(date, DateTime.now())
    ? chatTimeLabel(context, date)
    : chatDayLabel(context, date);
