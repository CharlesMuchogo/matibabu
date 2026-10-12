import 'package:equatable/equatable.dart';
import 'package:matibabu/domain/entities/user.dart';

class ProfileUpdate extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? address;
  final String? photoPath;

  const ProfileUpdate({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.photoPath,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phoneNumber,
    address,
    photoPath,
  ];
}

abstract class UserRepository {
  Future<User> me();

  Future<User> updateProfile(ProfileUpdate update);
}
