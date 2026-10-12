import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:matibabu/domain/entities/chat.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef ChannelFactory = WebSocketChannel Function(Uri uri);

class ChatSocket {
  final Uri _url;
  final Future<String?> Function() _token;
  final ChannelFactory _connect;
  final Duration _maxBackoff;
  final _events = StreamController<ChatEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _retry;
  bool _active = false;
  int _attempt = 0;

  ChatSocket({
    required Uri url,
    required Future<String?> Function() token,
    ChannelFactory? connect,
    Duration maxBackoff = const Duration(seconds: 30),
  }) : _url = url,
       _token = token,
       _connect = connect ?? WebSocketChannel.connect,
       _maxBackoff = maxBackoff;

  Stream<ChatEvent> get events => _events.stream;

  void connect() {
    if (_active) return;
    _active = true;
    _open();
  }

  Future<void> disconnect() async {
    _active = false;
    _retry?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }

  Future<void> _open() async {
    final token = await _token();
    if (!_active || token == null) return;

    final channel = _connect(_url.replace(queryParameters: {'token': token}));
    _channel = channel;
    try {
      await channel.ready;
    } catch (_) {
      return _scheduleRetry();
    }

    if (!_active) {
      await channel.sink.close();
      return;
    }

    _attempt = 0;
    _subscription = channel.stream.listen(
      _onData,
      onError: (_) {},
      onDone: _scheduleRetry,
    );
    _events.add(const ChatConnected());
  }

  void _onData(dynamic data) {
    final event = decodeChatEvent(data);
    if (event != null) _events.add(event);
  }

  void _scheduleRetry() {
    if (!_active || (_retry?.isActive ?? false)) return;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    final seconds = min(1 << min(_attempt, 5), _maxBackoff.inSeconds);
    _attempt++;
    _retry = Timer(Duration(seconds: seconds), _open);
  }
}

ChatEvent? decodeChatEvent(dynamic data) {
  if (data is! String) return null;
  final Object? json;
  try {
    json = jsonDecode(data);
  } on FormatException {
    return null;
  }
  if (json is! Map<String, dynamic>) return null;

  return switch (json['type']) {
    'message' => ChatMessageReceived(
      ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
    ),
    'read' => ChatReadReceived(
      chatId: json['chat_id'] as String,
      userId: json['user_id'] as String,
    ),
    _ => null,
  };
}
