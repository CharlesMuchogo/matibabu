import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:matibabu/domain/entities/user.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  List<Object?> get props => [id, chatId, senderId, text, createdAt];
}

@JsonSerializable()
class Chat extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String lastMessage;
  final String? lastSenderId;
  final DateTime? lastMessageAt;
  final int patientUnread;
  final int doctorUnread;
  final User? patient;
  final User? doctor;

  const Chat({
    required this.id,
    required this.patientId,
    required this.doctorId,
    this.lastMessage = '',
    this.lastSenderId,
    this.lastMessageAt,
    this.patientUnread = 0,
    this.doctorUnread = 0,
    this.patient,
    this.doctor,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);

  int unreadFor(String userId) =>
      userId == patientId ? patientUnread : doctorUnread;

  User? otherParty(String userId) => userId == patientId ? doctor : patient;

  Chat withMessage(ChatMessage message) {
    final fromPatient = message.senderId == patientId;
    return _copyWith(
      lastMessage: message.text,
      lastSenderId: message.senderId,
      lastMessageAt: message.createdAt,
      patientUnread: fromPatient ? patientUnread : patientUnread + 1,
      doctorUnread: fromPatient ? doctorUnread + 1 : doctorUnread,
    );
  }

  Chat readBy(String userId) => _copyWith(
    patientUnread: userId == patientId ? 0 : patientUnread,
    doctorUnread: userId == patientId ? doctorUnread : 0,
  );

  Chat _copyWith({
    String? lastMessage,
    String? lastSenderId,
    DateTime? lastMessageAt,
    int? patientUnread,
    int? doctorUnread,
  }) => Chat(
    id: id,
    patientId: patientId,
    doctorId: doctorId,
    lastMessage: lastMessage ?? this.lastMessage,
    lastSenderId: lastSenderId ?? this.lastSenderId,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    patientUnread: patientUnread ?? this.patientUnread,
    doctorUnread: doctorUnread ?? this.doctorUnread,
    patient: patient,
    doctor: doctor,
  );

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    lastMessage,
    lastSenderId,
    lastMessageAt,
    patientUnread,
    doctorUnread,
    patient,
    doctor,
  ];
}

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatConnected extends ChatEvent {
  const ChatConnected();
}

class ChatMessageReceived extends ChatEvent {
  final ChatMessage message;

  const ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatReadReceived extends ChatEvent {
  final String chatId;
  final String userId;

  const ChatReadReceived({required this.chatId, required this.userId});

  @override
  List<Object?> get props => [chatId, userId];
}
