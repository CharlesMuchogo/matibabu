import 'package:equatable/equatable.dart';
import 'package:matibabu/domain/entities/user.dart';

class Registration extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;

  const Registration({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phoneNumber,
    address,
    password,
  ];
}

enum SocialProvider { google, apple }

abstract class AuthRepository {
  Stream<void> get sessionExpired;

  Future<bool> hasSession();

  Future<User> login({required String email, required String password});

  Future<User> register(Registration registration);

  Future<User?> socialLogin(SocialProvider provider);

  Future<void> logout();

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
}
