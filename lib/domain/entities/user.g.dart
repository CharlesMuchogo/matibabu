// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String,
  name: json['name'] as String,
  photo: json['photo'] as String? ?? '',
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'photo': instance.photo,
};

DoctorProfile _$DoctorProfileFromJson(Map<String, dynamic> json) =>
    DoctorProfile(
      categoryId: json['category_id'] as String?,
      hospital: json['hospital'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DoctorProfileToJson(DoctorProfile instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'hospital': instance.hospital,
      'description': instance.description,
      'category': instance.category?.toJson(),
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String? ?? '',
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  phoneNumber: json['phone_number'] as String? ?? '',
  address: json['address'] as String? ?? '',
  profilePhoto: json['profile_photo'] as String? ?? '',
  userType:
      $enumDecodeNullable(
        _$UserTypeEnumMap,
        json['user_type'],
        unknownValue: UserType.patient,
      ) ??
      UserType.patient,
  doctorProfile: json['doctor_profile'] == null
      ? null
      : DoctorProfile.fromJson(json['doctor_profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone_number': instance.phoneNumber,
  'address': instance.address,
  'profile_photo': instance.profilePhoto,
  'user_type': _$UserTypeEnumMap[instance.userType]!,
  'doctor_profile': instance.doctorProfile?.toJson(),
};

const _$UserTypeEnumMap = {
  UserType.doctor: 'doctor',
  UserType.patient: 'patient',
};
