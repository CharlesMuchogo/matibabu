part of 'notifications_bloc.dart';

class NotificationsState extends Equatable {
  final int sequence;
  final PushMessage? foreground;
  final String? openChatId;

  const NotificationsState({
    this.sequence = 0,
    this.foreground,
    this.openChatId,
  });

  NotificationsState next({PushMessage? foreground, String? openChatId}) =>
      NotificationsState(
        sequence: sequence + 1,
        foreground: foreground,
        openChatId: openChatId,
      );

  @override
  List<Object?> get props => [sequence, foreground, openChatId];
}
