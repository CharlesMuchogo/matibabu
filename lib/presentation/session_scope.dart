import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/chats/chats_bloc.dart';
import 'package:matibabu/presentation/bloc/notifications/notifications_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/navigation/chat_router.dart';

class SessionScope extends StatelessWidget {
  final Widget child;

  const SessionScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.isAuthenticated != current.isAuthenticated ||
          previous.user?.id != current.user?.id,
      builder: (context, state) {
        final user = state.user;
        if (!state.isAuthenticated || user == null) return child;
        return _UserScope(
          key: ValueKey(user.id),
          userId: user.id,
          child: child,
        );
      },
    );
  }
}

class _UserScope extends StatefulWidget {
  final String userId;
  final Widget child;

  const _UserScope({super.key, required this.userId, required this.child});

  @override
  State<_UserScope> createState() => _UserScopeState();
}

class _UserScopeState extends State<_UserScope> {
  late final AuthBloc _auth;
  late final AppointmentsBloc _appointments;
  late final ChatsBloc _chats;
  late final NotificationsBloc _notifications;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthBloc>();
    _appointments = AppointmentsBloc(
      repository: context.read<AppointmentRepository>(),
    )..add(const AppointmentsRequested());
    _chats = ChatsBloc(
      repository: context.read<ChatRepository>(),
      userId: widget.userId,
    )..add(const ChatsStarted());
    _notifications = NotificationsBloc(
      repository: context.read<NotificationRepository>(),
    )..add(const NotificationsStarted());
    WidgetsBinding.instance.addPostFrameCallback((_) => ChatRouter.ready());
  }

  @override
  void dispose() {
    ChatRouter.closed();
    if (!_auth.state.isAuthenticated) {
      _appointments.clear();
      _chats.clear();
    }
    _appointments.close();
    _chats.close();
    _notifications.close();
    super.dispose();
  }

  void _showMessage(String message) => ChatRouter.messengerKey.currentState
      ?.showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _appointments),
        BlocProvider.value(value: _chats),
        BlocProvider.value(value: _notifications),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ChatsBloc, ChatsState>(
            listenWhen: (previous, current) =>
                previous.openStatus != current.openStatus,
            listener: (context, state) {
              final chatId = state.openedChatId;
              if (state.openStatus == Status.loaded && chatId != null) {
                ChatRouter.openChat(chatId);
              } else if (state.openStatus.isFailure) {
                _showMessage("Couldn't open the chat. ${state.message}");
              }
            },
          ),
          BlocListener<NotificationsBloc, NotificationsState>(
            listener: (context, state) {
              final openChatId = state.openChatId;
              if (openChatId != null) ChatRouter.openChat(openChatId);
              final push = state.foreground;
              if (push == null || push.chatId == ChatRouter.activeChatId) {
                return;
              }
              ChatRouter.messengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(
                    "${push.title}: ${push.body}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  action: SnackBarAction(
                    label: "View",
                    onPressed: () => ChatRouter.openChat(push.chatId),
                  ),
                ),
              );
            },
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
