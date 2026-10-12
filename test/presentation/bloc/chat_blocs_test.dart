import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/presentation/bloc/chat/chat_bloc.dart';
import 'package:matibabu/presentation/bloc/chats/chats_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late StreamController<ChatEvent> events;

  setUp(() {
    mockHydratedStorage();
    repository = MockChatRepository();
    events = StreamController<ChatEvent>.broadcast();
    when(() => repository.events).thenAnswer((_) => events.stream);
    when(() => repository.disconnect()).thenAnswer((_) async {});
    when(() => repository.markRead(any())).thenAnswer((_) async {});
  });

  tearDown(() => events.close());

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  group('ChatsBloc', () {
    final existing = chat(lastMessage: 'hi');

    ChatsBloc build() => ChatsBloc(repository: repository, userId: patient.id);

    blocTest<ChatsBloc, ChatsState>(
      'connects and loads chats on start',
      setUp: () =>
          when(() => repository.chats()).thenAnswer((_) async => [existing]),
      build: build,
      act: (bloc) => bloc.add(const ChatsStarted()),
      expect: () => [
        const ChatsState(status: Status.loading),
        ChatsState(status: Status.loaded, chats: [existing]),
      ],
      verify: (_) => verify(() => repository.connect()).called(1),
    );

    blocTest<ChatsBloc, ChatsState>(
      'moves a chat to the top and counts unread when a message arrives',
      setUp: () => when(() => repository.chats()).thenAnswer(
        (_) async => [chat(id: 'chat-9', lastMessage: 'old'), existing],
      ),
      build: build,
      act: (bloc) async {
        bloc.add(const ChatsStarted());
        await tick();
        events.add(
          ChatMessageReceived(
            message(chatId: 'chat-5', senderId: doctor.id, text: 'new'),
          ),
        );
      },
      skip: 2,
      expect: () => [
        isA<ChatsState>()
            .having((s) => s.chats.first.id, 'first chat', 'chat-5')
            .having((s) => s.chats.first.lastMessage, 'preview', 'new')
            .having((s) => s.unreadFor(patient.id), 'unread', 1),
      ],
    );

    blocTest<ChatsBloc, ChatsState>(
      'clears unread when a read receipt arrives',
      setUp: () => when(
        () => repository.chats(),
      ).thenAnswer((_) async => [chat(lastMessage: 'hi', patientUnread: 3)]),
      build: build,
      act: (bloc) async {
        bloc.add(const ChatsStarted());
        await tick();
        events.add(ChatReadReceived(chatId: 'chat-5', userId: patient.id));
      },
      skip: 2,
      expect: () => [
        isA<ChatsState>().having((s) => s.unreadFor(patient.id), 'unread', 0),
      ],
    );

    blocTest<ChatsBloc, ChatsState>(
      'refetches after reconnecting or for an unknown chat',
      setUp: () =>
          when(() => repository.chats()).thenAnswer((_) async => [existing]),
      build: build,
      act: (bloc) async {
        bloc.add(const ChatsStarted());
        await tick();
        events.add(const ChatConnected());
        await tick();
        events.add(ChatMessageReceived(message(chatId: 'chat-77')));
        await tick();
      },
      verify: (_) => verify(() => repository.chats()).called(3),
    );

    blocTest<ChatsBloc, ChatsState>(
      'opens a chat with a doctor',
      setUp: () => when(
        () => repository.open(doctor.id),
      ).thenAnswer((_) async => chat()),
      build: build,
      act: (bloc) => bloc.add(ChatOpenRequested(doctor.id)),
      expect: () => [
        const ChatsState(openStatus: Status.loading),
        ChatsState(
          chats: [chat()],
          openStatus: Status.loaded,
          openedChatId: 'chat-5',
        ),
      ],
    );

    blocTest<ChatsBloc, ChatsState>(
      'disconnects when closed',
      build: build,
      verify: (_) => verify(() => repository.disconnect()).called(1),
    );

    test('lists only conversations with messages and sums unread', () {
      final state = ChatsState(
        chats: [
          chat(id: 'chat-1', lastMessage: 'a', patientUnread: 2),
          chat(id: 'chat-2'),
          chat(id: 'chat-3', lastMessage: 'b', patientUnread: 1),
        ],
      );
      expect(state.conversations.map((c) => c.id), ['chat-1', 'chat-3']);
      expect(state.unreadFor(patient.id), 3);
    });
  });

  group('ChatBloc', () {
    final first = message(n: 1, senderId: doctor.id, text: 'hello');
    final second = message(n: 2, senderId: doctor.id, text: 'are you there?');

    ChatBloc build() =>
        ChatBloc(repository: repository, chatId: 'chat-5', userId: patient.id);

    setUp(() {
      when(() => repository.chat('chat-5')).thenAnswer(
        (_) async => chat(lastMessage: 'are you there?', patientUnread: 2),
      );
      when(
        () => repository.messages('chat-5'),
      ).thenAnswer((_) async => [second, first]);
    });

    blocTest<ChatBloc, ChatState>(
      'loads the chat newest first and marks it read',
      build: build,
      act: (bloc) => bloc.add(const ChatStarted()),
      wait: const Duration(milliseconds: 10),
      expect: () => [
        const ChatState(status: Status.loading),
        ChatState(
          status: Status.loaded,
          chat: chat(lastMessage: 'are you there?', patientUnread: 2),
          messages: [second, first],
          hasMore: true,
        ),
        ChatState(
          status: Status.loaded,
          chat: chat(lastMessage: 'are you there?'),
          messages: [second, first],
          hasMore: true,
        ),
      ],
      verify: (_) => verify(() => repository.markRead('chat-5')).called(1),
    );

    blocTest<ChatBloc, ChatState>(
      'does not mark read while the app is in the background',
      build: build,
      act: (bloc) async {
        bloc.add(const ChatVisibilityChanged(false));
        bloc.add(const ChatStarted());
      },
      wait: const Duration(milliseconds: 10),
      verify: (_) => verifyNever(() => repository.markRead(any())),
    );

    blocTest<ChatBloc, ChatState>(
      'shows a pending bubble then the sent message',
      setUp: () => when(() => repository.send('chat-5', 'hi doc')).thenAnswer(
        (_) async => message(n: 3, senderId: patient.id, text: 'hi doc'),
      ),
      build: build,
      seed: () =>
          ChatState(status: Status.loaded, chat: chat(), messages: [first]),
      act: (bloc) => bloc.add(const ChatMessageSubmitted('  hi doc ')),
      expect: () => [
        ChatState(
          status: Status.loaded,
          chat: chat(),
          messages: [first],
          pending: const ['hi doc'],
          sendStatus: Status.loading,
        ),
        isA<ChatState>()
            .having((s) => s.pending, 'pending', isEmpty)
            .having((s) => s.messages.map((m) => m.id), 'ids', [
              messageId(3),
              messageId(1),
            ])
            .having((s) => s.sendStatus, 'sendStatus', Status.loaded),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'keeps the text when sending fails',
      setUp: () => when(
        () => repository.send('chat-5', 'hi'),
      ).thenThrow(const AppException('offline')),
      build: build,
      seed: () => ChatState(status: Status.loaded, chat: chat()),
      act: (bloc) => bloc.add(const ChatMessageSubmitted('hi')),
      skip: 1,
      expect: () => [
        ChatState(
          status: Status.loaded,
          chat: chat(),
          sendStatus: Status.failure,
          failedText: 'hi',
          message: 'offline',
        ),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'adds live messages once and ignores other chats',
      build: build,
      act: (bloc) async {
        bloc.add(const ChatStarted());
        await Future<void>.delayed(const Duration(milliseconds: 5));
        final incoming = message(n: 9, senderId: doctor.id, text: 'live');
        events
          ..add(ChatMessageReceived(incoming))
          ..add(ChatMessageReceived(incoming))
          ..add(ChatMessageReceived(message(n: 10, chatId: 'chat-99')));
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) => expect(bloc.state.messages.map((m) => m.id), [
        messageId(9),
        messageId(2),
        messageId(1),
      ]),
    );

    blocTest<ChatBloc, ChatState>(
      'pages older messages until there are none',
      setUp: () {
        when(
          () => repository.messages('chat-5', before: messageId(1)),
        ).thenAnswer((_) async => []);
      },
      build: build,
      seed: () => ChatState(
        status: Status.loaded,
        chat: chat(),
        messages: [second, first],
        hasMore: true,
      ),
      act: (bloc) async {
        bloc.add(const ChatOlderRequested());
        await tick();
        bloc.add(const ChatOlderRequested());
      },
      verify: (bloc) {
        expect(bloc.state.hasMore, isFalse);
        verify(
          () => repository.messages('chat-5', before: messageId(1)),
        ).called(1);
      },
    );

    test('merges messages by id, newest first', () {
      expect(
        mergeMessages([second, first], [first, message(n: 3)]).map((m) => m.id),
        [messageId(3), messageId(2), messageId(1)],
      );
    });
  });
}
