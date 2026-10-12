part of 'profile_bloc.dart';

enum ProfileUpdateKind { details, photo }

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileUpdateSubmitted extends ProfileEvent {
  final ProfileUpdate update;

  const ProfileUpdateSubmitted(this.update);

  ProfileUpdateKind get kind => update.photoPath == null
      ? ProfileUpdateKind.details
      : ProfileUpdateKind.photo;

  @override
  List<Object?> get props => [update];
}
