import 'package:equatable/equatable.dart';

class PushMessage extends Equatable {
  final String chatId;
  final String title;
  final String body;

  const PushMessage({
    required this.chatId,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [chatId, title, body];
}
