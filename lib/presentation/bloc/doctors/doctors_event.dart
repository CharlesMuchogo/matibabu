part of 'doctors_bloc.dart';

sealed class DoctorsEvent extends Equatable {
  const DoctorsEvent();

  @override
  List<Object?> get props => [];
}

class DoctorsRequested extends DoctorsEvent {
  const DoctorsRequested();
}

class DoctorsQueryChanged extends DoctorsEvent {
  final String query;

  const DoctorsQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
