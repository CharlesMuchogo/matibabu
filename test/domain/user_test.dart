import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/entities/user.dart';

import '../helpers/fixtures.dart';

void main() {
  test('doctors are shown with their title and specialty', () {
    expect(doctor.displayName, 'Dr. Jane Doe');
    expect(doctor.specialty, 'Dentist');
    expect(doctor.hospital, 'Aga Khan');
    expect(doctor.about, 'Teeth');
  });

  test('patients are shown by name only', () {
    expect(patient.displayName, 'Pat Ient');
    expect(patient.specialty, isEmpty);
  });

  test('parses the public profile shape that omits private fields', () {
    final user = User.fromJson({
      'id': 'doctor-2',
      'email': 'doc@example.com',
      'first_name': 'Jane',
      'last_name': 'Doe',
      'phone_number': '',
      'profile_photo': '',
      'user_type': 'doctor',
    });
    expect(user.address, isEmpty);
    expect(user.doctorProfile, isNull);
    expect(user.userType, UserType.doctor);
  });

  test('round trips through json', () {
    expect(User.fromJson(doctor.toJson()), doctor);
  });
}
