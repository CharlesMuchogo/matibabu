part of 'doctors_bloc.dart';

class DoctorsState extends Equatable {
  final Status status;
  final List<User> doctors;
  final String query;
  final String message;

  const DoctorsState({
    this.status = Status.initial,
    this.doctors = const [],
    this.query = '',
    this.message = '',
  });

  DoctorsState copyWith({
    Status? status,
    List<User>? doctors,
    String? query,
    String? message,
  }) => DoctorsState(
    status: status ?? this.status,
    doctors: doctors ?? this.doctors,
    query: query ?? this.query,
    message: message ?? this.message,
  );

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'doctors': doctors.map((d) => d.toJson()).toList(),
    'query': query,
  };

  factory DoctorsState.fromMap(Map<String, dynamic> map) => DoctorsState(
    status: Status.values.byName(map['status'] as String),
    doctors: listFromJson(map['doctors'], User.fromJson),
    query: map['query'] as String? ?? '',
  );

  @override
  List<Object?> get props => [status, doctors, query, message];
}
