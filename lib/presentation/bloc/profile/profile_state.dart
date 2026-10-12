part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final Status status;
  final ProfileUpdateKind kind;
  final User? user;
  final String message;

  const ProfileState({
    this.status = Status.initial,
    this.kind = ProfileUpdateKind.details,
    this.user,
    this.message = '',
  });

  bool isLoading(ProfileUpdateKind kind) =>
      status.isLoading && this.kind == kind;

  @override
  List<Object?> get props => [status, kind, user, message];
}
