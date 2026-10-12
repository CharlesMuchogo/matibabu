import 'package:matibabu/domain/entities/push_message.dart';

abstract class NotificationRepository {
  Stream<PushMessage> get foregroundMessages;

  Stream<String> get openedChats;

  Future<void> register();

  Future<void> unregister();
}
