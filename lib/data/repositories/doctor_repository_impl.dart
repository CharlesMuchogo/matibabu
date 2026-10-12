import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  static const _pageSize = 100;

  final ApiClient _api;

  DoctorRepositoryImpl(this._api);

  @override
  Future<List<Category>> categories() async =>
      parseList(await _api.get('/categories'), Category.fromJson);

  @override
  Future<List<User>> doctors({String? categoryId, String query = ''}) async {
    final params = <String, dynamic>{
      'limit': _pageSize,
      'category_id': ?categoryId,
      if (query.trim().isNotEmpty) 'q': query.trim(),
    };
    return parseList(await _api.get('/doctors', query: params), User.fromJson);
  }

  @override
  Future<List<Slot>> availability({
    required String doctorId,
    required DateTime date,
  }) async {
    final json =
        await _api.get(
              '/doctors/$doctorId/availability',
              query: {'date': apiDate(date)},
            )
            as Map<String, dynamic>;
    return parseList(json['slots'], Slot.fromJson);
  }
}
