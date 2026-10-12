import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/entities/user.dart';

abstract class DoctorRepository {
  Future<List<Category>> categories();

  Future<List<User>> doctors({String? categoryId, String query = ''});

  Future<List<Slot>> availability({
    required String doctorId,
    required DateTime date,
  });
}
