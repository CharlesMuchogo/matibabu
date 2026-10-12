import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/realtime/chat_socket.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  static const _chatsPageSize = 100;
  static const _messagesPageSize = 50;

  final ApiClient _api;
  final ChatSocket _socket;

  ChatRepositoryImpl({required ApiClient api, required ChatSocket socket})
    : _api = api,
      _socket = socket;

  @override
  Stream<ChatEvent> get events => _socket.events;

  @override
  void connect() => _socket.connect();

  @override
  Future<void> disconnect() => _socket.disconnect();

  @override
  Future<List<Chat>> chats() async => parseList(
    await _api.get('/chats', query: {'limit': _chatsPageSize}),
    Chat.fromJson,
  );

  @override
  Future<Chat> chat(String id) async =>
      Chat.fromJson(await _api.get('/chats/$id') as Map<String, dynamic>);

  @override
  Future<Chat> open(String userId) async => Chat.fromJson(
    await _api.post('/chats', data: {'user_id': userId})
        as Map<String, dynamic>,
  );

  @override
  Future<List<ChatMessage>> messages(String chatId, {String? before}) async =>
      parseList(
        await _api.get(
          '/chats/$chatId/messages',
          query: {'limit': _messagesPageSize, 'before': ?before},
        ),
        ChatMessage.fromJson,
      );

  @override
  Future<ChatMessage> send(String chatId, String text) async =>
      ChatMessage.fromJson(
        await _api.post('/chats/$chatId/messages', data: {'text': text})
            as Map<String, dynamic>,
      );

  @override
  Future<void> markRead(String chatId) => _api.post('/chats/$chatId/read');
}
