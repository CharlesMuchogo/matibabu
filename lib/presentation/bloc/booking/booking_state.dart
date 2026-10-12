part of 'booking_bloc.dart';

class BookingState extends Equatable {
  final DateTime? date;
  final Status slotsStatus;
  final List<Slot> slots;
  final String? time;
  final Status submitStatus;
  final String message;
  final Appointment? appointment;

  const BookingState({
    this.date,
    this.slotsStatus = Status.initial,
    this.slots = const [],
    this.time,
    this.submitStatus = Status.initial,
    this.message = '',
    this.appointment,
  });

  BookingState copyWith({
    Status? slotsStatus,
    List<Slot>? slots,
    String? time,
    Status? submitStatus,
    String? message,
    Appointment? appointment,
  }) => BookingState(
    date: date,
    slotsStatus: slotsStatus ?? this.slotsStatus,
    slots: slots ?? this.slots,
    time: time ?? this.time,
    submitStatus: submitStatus ?? this.submitStatus,
    message: message ?? this.message,
    appointment: appointment ?? this.appointment,
  );

  @override
  List<Object?> get props => [
    date,
    slotsStatus,
    slots,
    time,
    submitStatus,
    message,
    appointment,
  ];
}
