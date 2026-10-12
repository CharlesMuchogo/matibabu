import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserType { doctor, patient }

@JsonSerializable()
class Category extends Equatable {
  final String id;
  final String name;
  final String photo;

  const Category({required this.id, required this.name, this.photo = ''});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  List<Object?> get props => [id, name, photo];
}

@JsonSerializable()
class DoctorProfile extends Equatable {
  final String? categoryId;
  final String hospital;
  final String description;
  final Category? category;

  const DoctorProfile({
    this.categoryId,
    this.hospital = '',
    this.description = '',
    this.category,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) =>
      _$DoctorProfileFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorProfileToJson(this);

  @override
  List<Object?> get props => [categoryId, hospital, description, category];
}

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;
  final String profilePhoto;
  @JsonKey(unknownEnumValue: UserType.patient)
  final UserType userType;
  final DoctorProfile? doctorProfile;

  const User({
    required this.id,
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.address = '',
    this.profilePhoto = '',
    this.userType = UserType.patient,
    this.doctorProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName'.trim();

  String get displayName =>
      userType == UserType.doctor ? 'Dr. $fullName' : fullName;

  String get specialty => doctorProfile?.category?.name ?? '';

  String get hospital => doctorProfile?.hospital ?? '';

  String get about => doctorProfile?.description ?? '';

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    address,
    profilePhoto,
    userType,
    doctorProfile,
  ];
}
