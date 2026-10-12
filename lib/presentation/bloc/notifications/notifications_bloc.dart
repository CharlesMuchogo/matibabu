import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/push_message.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRepository _repository;

  NotificationsBloc({required NotificationRepository repository})
    : _repository = repository,
      super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    await _repository.register();
    await Future.wait([
      emit.forEach<PushMessage>(
        _repository.foregroundMessages,
        onData: (message) => state.next(foreground: message),
      ),
      emit.forEach<String>(
        _repository.openedChats,
        onData: (chatId) => state.next(openChatId: chatId),
      ),
    ]);
  }
}
