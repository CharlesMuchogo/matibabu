part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final Status status;
  final Chat? chat;
  final List<ChatMessage> messages;
  final List<String> pending;
  final bool hasMore;
  final bool loadingOlder;
  final bool visible;
  final Status sendStatus;
  final String failedText;
  final String message;

  const ChatState({
    this.status = Status.initial,
    this.chat,
    this.messages = const [],
    this.pending = const [],
    this.hasMore = false,
    this.loadingOlder = false,
    this.visible = true,
    this.sendStatus = Status.initial,
    this.failedText = '',
    this.message = '',
  });

  ChatState copyWith({
    Status? status,
    Chat? chat,
    List<ChatMessage>? messages,
    List<String>? pending,
    bool? hasMore,
    bool? loadingOlder,
    bool? visible,
    Status? sendStatus,
    String? failedText,
    String? message,
  }) => ChatState(
    status: status ?? this.status,
    chat: chat ?? this.chat,
    messages: messages ?? this.messages,
    pending: pending ?? this.pending,
    hasMore: hasMore ?? this.hasMore,
    loadingOlder: loadingOlder ?? this.loadingOlder,
    visible: visible ?? this.visible,
    sendStatus: sendStatus ?? this.sendStatus,
    failedText: failedText ?? this.failedText,
    message: message ?? this.message,
  );

  @override
  List<Object?> get props => [
    status,
    chat,
    messages,
    pending,
    hasMore,
    loadingOlder,
    visible,
    sendStatus,
    failedText,
    message,
  ];
}
