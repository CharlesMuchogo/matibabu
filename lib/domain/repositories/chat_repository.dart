import 'package:matibabu/domain/entities/chat.dart';

abstract class ChatRepository {
  Stream<ChatEvent> get events;

  void connect();

  Future<void> disconnect();

  Future<List<Chat>> chats();

  Future<Chat> chat(String id);

  Future<Chat> open(String userId);

  Future<List<ChatMessage>> messages(String chatId, {String? before});

  Future<ChatMessage> send(String chatId, String text);

  Future<void> markRead(String chatId);
}
