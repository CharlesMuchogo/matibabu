import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  static const _pageSize = 100;

  final ApiClient _api;

  AppointmentRepositoryImpl(this._api);

  @override
  Future<List<Appointment>> appointments() async => parseList(
    await _api.get('/appointments', query: {'limit': _pageSize}),
    Appointment.fromJson,
  );

  @override
  Future<Appointment> book(NewAppointment appointment) async =>
      Appointment.fromJson(
        await _api.post('/appointments', data: appointment.toJson())
            as Map<String, dynamic>,
      );

  @override
  Future<Appointment> updateStatus(String id, AppointmentStatus status) async =>
      Appointment.fromJson(
        await _api.patch(
              '/appointments/$id/status',
              data: {'status': status.name},
            )
            as Map<String, dynamic>,
      );

  @override
  Future<void> remove(String id) => _api.delete('/appointments/$id');
}
