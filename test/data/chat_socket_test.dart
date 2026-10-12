import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/data/realtime/chat_socket.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../helpers/fixtures.dart';

class MockChannel extends Mock implements WebSocketChannel {}

class MockSink extends Mock implements WebSocketSink {}

class FakeServer {
  final uris = <Uri>[];
  final connections = <StreamController<dynamic>>[];
  bool fail = false;

  WebSocketChannel connect(Uri uri) {
    uris.add(uri);
    final incoming = StreamController<dynamic>();
    connections.add(incoming);
    final sink = MockSink();
    when(() => sink.close()).thenAnswer((_) async {});
    final channel = MockChannel();
    when(() => channel.ready).thenAnswer(
      (_) => fail
          ? Future.error(WebSocketChannelException('down'))
          : Future.value(),
    );
    when(() => channel.stream).thenAnswer((_) => incoming.stream);
    when(() => channel.sink).thenReturn(sink);
    return channel;
  }
}

void main() {
  group('decodeChatEvent', () {
    test('decodes messages and read receipts', () {
      final m = message();
      expect(
        decodeChatEvent(
          jsonEncode({
            'type': 'message',
            'chat_id': 'chat-5',
            'message': m.toJson(),
          }),
        ),
        ChatMessageReceived(m),
      );
      expect(
        decodeChatEvent(
          jsonEncode({
            'type': 'read',
            'chat_id': 'chat-5',
            'user_id': 'doctor-2',
          }),
        ),
        const ChatReadReceived(chatId: 'chat-5', userId: 'doctor-2'),
      );
    });

    test('ignores errors, unknown events and malformed frames', () {
      expect(
        decodeChatEvent(jsonEncode({'type': 'error', 'error': 'nope'})),
        isNull,
      );
      expect(decodeChatEvent('{not json'), isNull);
      expect(decodeChatEvent([1, 2, 3]), isNull);
    });
  });

  test('connects with the access token and forwards events', () {
    fakeAsync((async) {
      final server = FakeServer();
      final socket = ChatSocket(
        url: Uri.parse('ws://api.test/api/v1/ws'),
        token: () async => 'access-1',
        connect: server.connect,
      );
      final events = <ChatEvent>[];
      socket.events.listen(events.add);

      socket.connect();
      async.flushMicrotasks();
      server.connections.single.add(
        jsonEncode({
          'type': 'read',
          'chat_id': 'chat-5',
          'user_id': 'doctor-2',
        }),
      );
      async.flushMicrotasks();

      expect(server.uris.single.queryParameters, {'token': 'access-1'});
      expect(events, const [
        ChatConnected(),
        ChatReadReceived(chatId: 'chat-5', userId: 'doctor-2'),
      ]);
    });
  });

  test('reconnects with backoff after the connection drops', () {
    fakeAsync((async) {
      final server = FakeServer();
      final socket = ChatSocket(
        url: Uri.parse('ws://api.test/api/v1/ws'),
        token: () async => 'access',
        connect: server.connect,
      );
      final events = <ChatEvent>[];
      socket.events.listen(events.add);

      socket.connect();
      async.flushMicrotasks();
      server.fail = true;
      server.connections.single.close();
      async.elapse(const Duration(seconds: 1));
      expect(server.uris, hasLength(2));

      server.fail = false;
      async.elapse(const Duration(seconds: 2));
      expect(server.uris, hasLength(3));
      expect(events.whereType<ChatConnected>(), hasLength(2));
    });
  });

  test('stays disconnected without a session or after disconnect', () {
    fakeAsync((async) {
      final server = FakeServer();
      String? token;
      final socket = ChatSocket(
        url: Uri.parse('ws://api.test/api/v1/ws'),
        token: () async => token,
        connect: server.connect,
      );

      socket.connect();
      async.flushMicrotasks();
      expect(server.uris, isEmpty);

      token = 'access';
      socket.disconnect();
      socket.connect();
      async.flushMicrotasks();
      socket.disconnect();
      server.connections.single.close();
      async.elapse(const Duration(minutes: 1));
      expect(server.uris, hasLength(1));
    });
  });
}
