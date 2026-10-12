import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/network/token_store.dart';
import 'package:matibabu/data/push/firebase_notification_repository.dart';
import 'package:matibabu/data/realtime/chat_socket.dart';
import 'package:matibabu/data/repositories/appointment_repository_impl.dart';
import 'package:matibabu/data/repositories/auth_repository_impl.dart';
import 'package:matibabu/data/repositories/chat_repository_impl.dart';
import 'package:matibabu/data/repositories/doctor_repository_impl.dart';
import 'package:matibabu/data/repositories/user_repository_impl.dart';
import 'package:matibabu/data/social/social_auth.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';

class Dependencies {
  final AuthRepository auth;
  final UserRepository users;
  final DoctorRepository doctors;
  final AppointmentRepository appointments;
  final ChatRepository chats;
  final NotificationRepository notifications;

  const Dependencies({
    required this.auth,
    required this.users,
    required this.doctors,
    required this.appointments,
    required this.chats,
    required this.notifications,
  });

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://matibabu.muchogoc.com',
  );

  factory Dependencies.create() {
    final baseUrl = Uri.parse(apiBaseUrl);
    final api = ApiClient(
      baseUrl: baseUrl.resolve('/api/v1').toString(),
      tokens: SecureTokenStore(),
    );
    final socket = ChatSocket(
      url: baseUrl.replace(
        scheme: baseUrl.scheme == 'https' ? 'wss' : 'ws',
        path: '/api/v1/ws',
      ),
      token: api.freshAccessToken,
    );

    return Dependencies(
      auth: AuthRepositoryImpl(api: api, social: FirebaseSocialAuth()),
      users: UserRepositoryImpl(api),
      doctors: DoctorRepositoryImpl(api),
      appointments: AppointmentRepositoryImpl(api),
      chats: ChatRepositoryImpl(api: api, socket: socket),
      notifications: FirebaseNotificationRepository(api: api),
    );
  }
}
