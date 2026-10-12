part of 'chats_bloc.dart';

class ChatsState extends Equatable {
  final Status status;
  final List<Chat> chats;
  final Status openStatus;
  final String? openedChatId;
  final String message;

  const ChatsState({
    this.status = Status.initial,
    this.chats = const [],
    this.openStatus = Status.initial,
    this.openedChatId,
    this.message = '',
  });

  List<Chat> get conversations =>
      chats.where((c) => c.lastMessage.isNotEmpty).toList();

  int unreadFor(String userId) =>
      chats.fold(0, (total, chat) => total + chat.unreadFor(userId));

  Chat? byId(String id) => chats.where((c) => c.id == id).firstOrNull;

  ChatsState withChat(Chat chat, {bool moveToTop = false}) => copyWith(
    chats: moveToTop
        ? [chat, ...chats.where((c) => c.id != chat.id)]
        : [for (final c in chats) c.id == chat.id ? chat : c],
  );

  ChatsState copyWith({
    Status? status,
    List<Chat>? chats,
    Status? openStatus,
    String? openedChatId,
    String? message,
  }) => ChatsState(
    status: status ?? this.status,
    chats: chats ?? this.chats,
    openStatus: openStatus ?? this.openStatus,
    openedChatId: openedChatId ?? this.openedChatId,
    message: message ?? this.message,
  );

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'chats': chats.map((c) => c.toJson()).toList(),
  };

  factory ChatsState.fromMap(Map<String, dynamic> map) => ChatsState(
    status: Status.values.byName(map['status'] as String),
    chats: listFromJson(map['chats'], Chat.fromJson),
  );

  @override
  List<Object?> get props => [status, chats, openStatus, openedChatId, message];
}
