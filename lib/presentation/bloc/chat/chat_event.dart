part of 'chat_bloc.dart';

sealed class ChatThreadEvent extends Equatable {
  const ChatThreadEvent();

  @override
  List<Object?> get props => [];
}

class ChatStarted extends ChatThreadEvent {
  const ChatStarted();
}

class ChatResynced extends ChatThreadEvent {
  const ChatResynced();
}

class ChatOlderRequested extends ChatThreadEvent {
  const ChatOlderRequested();
}

class ChatMessageSubmitted extends ChatThreadEvent {
  final String text;

  const ChatMessageSubmitted(this.text);

  @override
  List<Object?> get props => [text];
}

class ChatVisibilityChanged extends ChatThreadEvent {
  final bool visible;

  const ChatVisibilityChanged(this.visible);

  @override
  List<Object?> get props => [visible];
}

class ChatReadRequested extends ChatThreadEvent {
  const ChatReadRequested();
}
