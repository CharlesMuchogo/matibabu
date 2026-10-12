import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatThreadEvent, ChatState> with SafeHandler {
  final ChatRepository _repository;
  final String chatId;
  final String userId;

  ChatBloc({
    required ChatRepository repository,
    required this.chatId,
    required this.userId,
  }) : _repository = repository,
       super(const ChatState()) {
    on<ChatStarted>(_onStarted, transformer: droppable());
    on<ChatResynced>((event, emit) => _load(emit), transformer: restartable());
    on<ChatOlderRequested>(_onOlderRequested, transformer: droppable());
    on<ChatMessageSubmitted>(_onSubmitted, transformer: sequential());
    on<ChatVisibilityChanged>(_onVisibilityChanged);
    on<ChatReadRequested>(_onReadRequested, transformer: droppable());
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: Status.loading));
    final updates = emit.forEach<ChatEvent>(_repository.events, onData: _apply);
    await _load(emit);
    await updates;
  }

  Future<void> _load(Emitter<ChatState> emit) => guard(
    () async {
      final (chat, messages) = await (
        _repository.chat(chatId),
        _repository.messages(chatId),
      ).wait;
      emit(
        state.copyWith(
          status: Status.loaded,
          chat: chat,
          messages: mergeMessages(state.messages, messages),
          hasMore: state.status == Status.loaded
              ? state.hasMore
              : messages.isNotEmpty,
        ),
      );
      add(const ChatReadRequested());
    },
    (message) => emit(
      state.copyWith(
        status: state.chat == null ? Status.failure : state.status,
        message: message,
      ),
    ),
  );

  Future<void> _onOlderRequested(
    ChatOlderRequested event,
    Emitter<ChatState> emit,
  ) async {
    if (!state.hasMore || state.messages.isEmpty) return;
    emit(state.copyWith(loadingOlder: true));
    await guard(
      () async {
        final older = await _repository.messages(
          chatId,
          before: state.messages.last.id,
        );
        emit(
          state.copyWith(
            messages: mergeMessages(state.messages, older),
            hasMore: older.isNotEmpty,
            loadingOlder: false,
          ),
        );
      },
      (message) => emit(state.copyWith(loadingOlder: false, message: message)),
    );
  }

  Future<void> _onSubmitted(
    ChatMessageSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;

    emit(
      state.copyWith(
        pending: [...state.pending, text],
        sendStatus: Status.loading,
        failedText: '',
      ),
    );
    final pending = [...state.pending]..remove(text);
    await guard(
      () async {
        final sent = await _repository.send(chatId, text);
        emit(
          state.copyWith(
            pending: pending,
            messages: mergeMessages(state.messages, [sent]),
            chat: state.chat?.withMessage(sent),
            sendStatus: Status.loaded,
          ),
        );
      },
      (message) => emit(
        state.copyWith(
          pending: pending,
          sendStatus: Status.failure,
          failedText: text,
          message: message,
        ),
      ),
    );
  }

  void _onVisibilityChanged(
    ChatVisibilityChanged event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(visible: event.visible));
    add(const ChatReadRequested());
  }

  Future<void> _onReadRequested(
    ChatReadRequested event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.chat;
    if (chat == null || !state.visible || chat.unreadFor(userId) == 0) return;
    emit(state.copyWith(chat: chat.readBy(userId)));
    await guard(() => _repository.markRead(chatId), (_) {});
  }

  ChatState _apply(ChatEvent event) {
    switch (event) {
      case ChatConnected():
        add(const ChatResynced());
        return state;
      case ChatMessageReceived(:final message) when message.chatId == chatId:
        final known = state.messages.any((m) => m.id == message.id);
        if (known) return state;
        if (message.senderId != userId) add(const ChatReadRequested());
        return state.copyWith(
          messages: mergeMessages(state.messages, [message]),
          chat: state.chat?.withMessage(message),
        );
      case ChatReadReceived(:final chatId, :final userId)
          when chatId == this.chatId:
        return state.copyWith(chat: state.chat?.readBy(userId));
      default:
        return state;
    }
  }
}

List<ChatMessage> mergeMessages(
  List<ChatMessage> current,
  List<ChatMessage> incoming,
) {
  final byId = {
    for (final m in current) m.id: m,
    for (final m in incoming) m.id: m,
  };
  return byId.values.toList()..sort(newestFirst);
}

int newestFirst(ChatMessage a, ChatMessage b) {
  final byTime = b.createdAt.compareTo(a.createdAt);
  return byTime != 0 ? byTime : b.id.compareTo(a.id);
}
