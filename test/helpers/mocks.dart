import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockStorage extends Mock implements Storage {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockDoctorRepository extends Mock implements DoctorRepository {}

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

Storage mockHydratedStorage() {
  final storage = MockStorage();
  when(() => storage.read(any())).thenReturn(null);
  when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
  when(() => storage.delete(any())).thenAnswer((_) async {});
  when(() => storage.clear()).thenAnswer((_) async {});
  HydratedBloc.storage = storage;
  return storage;
}
