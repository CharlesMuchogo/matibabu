part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingDateSelected extends BookingEvent {
  final DateTime date;

  const BookingDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

class BookingTimeSelected extends BookingEvent {
  final String time;

  const BookingTimeSelected(this.time);

  @override
  List<Object?> get props => [time];
}

class BookingSubmitted extends BookingEvent {
  const BookingSubmitted();
}
