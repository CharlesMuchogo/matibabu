import 'package:matibabu/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> appointments();

  Future<Appointment> book(NewAppointment appointment);

  Future<Appointment> updateStatus(String id, AppointmentStatus status);

  Future<void> remove(String id);
}
