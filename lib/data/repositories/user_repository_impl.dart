import 'package:dio/dio.dart';
import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiClient _api;

  UserRepositoryImpl(this._api);

  @override
  Future<User> me() async =>
      User.fromJson(await _api.get('/users/me') as Map<String, dynamic>);

  @override
  Future<User> updateProfile(ProfileUpdate update) async {
    final fields = {
      'first_name': update.firstName,
      'last_name': update.lastName,
      'phone_number': update.phoneNumber,
      'address': update.address,
    }..removeWhere((_, value) => value == null);

    final photo = update.photoPath;
    final body = photo == null
        ? fields
        : FormData.fromMap({
            ...fields,
            'photo': await MultipartFile.fromFile(photo),
          });

    return User.fromJson(
      await _api.put('/users/me', data: body) as Map<String, dynamic>,
    );
  }
}
