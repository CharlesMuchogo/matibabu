import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends HydratedBloc<ChatsEvent, ChatsState> with SafeHandler {
  final ChatRepository _repository;
  final String userId;

  ChatsBloc({required ChatRepository repository, required this.userId})
    : _repository = repository,
      super(const ChatsState()) {
    on<ChatsStarted>(_onStarted, transformer: droppable());
    on<ChatsRefreshed>(_onRefreshed, transformer: restartable());
    on<ChatOpenRequested>(_onOpenRequested, transformer: droppable());
  }

  @override
  String get storagePrefix => 'ChatsBloc';

  Future<void> _onStarted(ChatsStarted event, Emitter<ChatsState> emit) {
    _repository.connect();
    add(const ChatsRefreshed());
    return emit.forEach<ChatEvent>(_repository.events, onData: _apply);
  }

  Future<void> _onRefreshed(
    ChatsRefreshed event,
    Emitter<ChatsState> emit,
  ) async {
    if (state.chats.isEmpty) emit(state.copyWith(status: Status.loading));
    await guard(
      () async => emit(
        state.copyWith(
          status: Status.loaded,
          chats: await _repository.chats(),
          message: '',
        ),
      ),
      (message) =>
          emit(state.copyWith(status: Status.failure, message: message)),
    );
  }

  Future<void> _onOpenRequested(
    ChatOpenRequested event,
    Emitter<ChatsState> emit,
  ) async {
    emit(state.copyWith(openStatus: Status.loading, message: ''));
    await guard(
      () async {
        final chat = await _repository.open(event.userId);
        final known = state.byId(chat.id) != null;
        emit(
          (known
                  ? state.withChat(chat)
                  : state.copyWith(chats: [...state.chats, chat]))
              .copyWith(openStatus: Status.loaded, openedChatId: chat.id),
        );
      },
      (message) =>
          emit(state.copyWith(openStatus: Status.failure, message: message)),
    );
  }

  ChatsState _apply(ChatEvent event) {
    switch (event) {
      case ChatConnected():
        add(const ChatsRefreshed());
        return state;
      case ChatMessageReceived(:final message):
        final chat = state.byId(message.chatId);
        if (chat == null) {
          add(const ChatsRefreshed());
          return state;
        }
        return state.withChat(chat.withMessage(message), moveToTop: true);
      case ChatReadReceived(:final chatId, :final userId):
        final chat = state.byId(chatId);
        return chat == null ? state : state.withChat(chat.readBy(userId));
    }
  }

  @override
  ChatsState? fromJson(Map<String, dynamic> json) => ChatsState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(ChatsState state) =>
      state.status == Status.loaded ? state.toMap() : null;

  @override
  Future<void> close() async {
    await _repository.disconnect();
    return super.close();
  }
}
