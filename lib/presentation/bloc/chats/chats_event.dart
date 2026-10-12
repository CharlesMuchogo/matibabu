part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

class ChatsStarted extends ChatsEvent {
  const ChatsStarted();
}

class ChatsRefreshed extends ChatsEvent {
  const ChatsRefreshed();
}

class ChatOpenRequested extends ChatsEvent {
  final String userId;

  const ChatOpenRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
