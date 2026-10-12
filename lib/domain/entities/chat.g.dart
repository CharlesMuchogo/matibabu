// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  chatId: json['chat_id'] as String,
  senderId: json['sender_id'] as String,
  text: json['text'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'text': instance.text,
      'created_at': instance.createdAt.toIso8601String(),
    };

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: json['id'] as String,
  patientId: json['patient_id'] as String,
  doctorId: json['doctor_id'] as String,
  lastMessage: json['last_message'] as String? ?? '',
  lastSenderId: json['last_sender_id'] as String?,
  lastMessageAt: json['last_message_at'] == null
      ? null
      : DateTime.parse(json['last_message_at'] as String),
  patientUnread: (json['patient_unread'] as num?)?.toInt() ?? 0,
  doctorUnread: (json['doctor_unread'] as num?)?.toInt() ?? 0,
  patient: json['patient'] == null
      ? null
      : User.fromJson(json['patient'] as Map<String, dynamic>),
  doctor: json['doctor'] == null
      ? null
      : User.fromJson(json['doctor'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'patient_id': instance.patientId,
  'doctor_id': instance.doctorId,
  'last_message': instance.lastMessage,
  'last_sender_id': instance.lastSenderId,
  'last_message_at': instance.lastMessageAt?.toIso8601String(),
  'patient_unread': instance.patientUnread,
  'doctor_unread': instance.doctorUnread,
  'patient': instance.patient?.toJson(),
  'doctor': instance.doctor?.toJson(),
};
