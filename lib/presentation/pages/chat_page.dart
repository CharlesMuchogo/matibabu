import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/chat_repository.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/chat/chat_bloc.dart';
import 'package:matibabu/presentation/formatters.dart';
import 'package:matibabu/presentation/navigation/chat_router.dart';
import 'package:matibabu/presentation/pages/doctor_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class ChatPage extends StatelessWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        repository: context.read<ChatRepository>(),
        chatId: chatId,
        userId: context.read<AuthBloc>().state.user!.id,
      )..add(const ChatStarted()),
      child: _ChatView(chatId: chatId),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String chatId;

  const _ChatView({required this.chatId});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    ChatRouter.chatOpened(widget.chatId);
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_maybeLoadOlder);
  }

  @override
  void dispose() {
    ChatRouter.chatClosed(widget.chatId);
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<ChatBloc>().add(
      ChatVisibilityChanged(state == AppLifecycleState.resumed),
    );
  }

  void _maybeLoadOlder() {
    if (_scroll.position.extentAfter < 300) {
      context.read<ChatBloc>().add(const ChatOlderRequested());
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<ChatBloc>().add(ChatMessageSubmitted(text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.sendStatus != current.sendStatus &&
          current.sendStatus.isFailure,
      listener: (context, state) {
        if (_controller.text.isEmpty) _controller.text = state.failedText;
        showSnack(context, "Message not sent. ${state.message}");
      },
      builder: (context, state) {
        final chat = state.chat;
        if (chat == null) {
          return Scaffold(
            appBar: AppBar(),
            body: state.status.isFailure
                ? Center(
                    child: ErrorView(
                      message: state.message,
                      onRetry: () =>
                          context.read<ChatBloc>().add(const ChatResynced()),
                    ),
                  )
                : const LoadingView(),
          );
        }

        final userId = context.read<ChatBloc>().userId;
        final other = chat.otherParty(userId);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              onTap: other == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => DoctorPage(doctor: other),
                      ),
                    ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Avatar(other?.profilePhoto, radius: 20),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: Text(
                        other?.displayName ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(child: _messages(state, userId, other?.displayName)),
              MessageComposer(controller: _controller, onSend: _send),
            ],
          ),
        );
      },
    );
  }

  Widget _messages(ChatState state, String userId, String? otherName) {
    final messages = state.messages;
    final pending = state.pending.reversed.toList();
    if (messages.isEmpty && pending.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          title: "Say hello",
          message:
              "Send ${otherName ?? "them"} a message to start the "
              "conversation.",
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      itemCount:
          pending.length + messages.length + (state.loadingOlder ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < pending.length) {
          return MessageBubble(text: pending[i], mine: true);
        }
        final index = i - pending.length;
        if (index == messages.length) return const LoadingView(height: 48);

        final message = messages[index];
        final date = message.createdAt.toLocal();
        final older = index + 1 < messages.length
            ? messages[index + 1].createdAt.toLocal()
            : null;
        return Column(
          children: [
            if (older == null || !isSameDay(date, older))
              _DaySeparator(chatDayLabel(context, date)),
            MessageBubble(
              text: message.text,
              sentAt: date,
              mine: message.senderId == userId,
            ),
          ],
        );
      },
    );
  }
}

class _DaySeparator extends StatelessWidget {
  final String label;

  const _DaySeparator(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final DateTime? sentAt;
  final bool mine;

  const MessageBubble({
    super.key,
    required this.text,
    required this.mine,
    this.sentAt,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = mine ? scheme.onPrimary : scheme.onSurface;
    final sentAt = this.sentAt;
    const radius = Radius.circular(AppSpacing.radius);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm + 6,
            AppSpacing.sm + 2,
            AppSpacing.sm + 6,
            6,
          ),
          decoration: BoxDecoration(
            color: mine ? scheme.primary : Theme.of(context).cardTheme.color,
            border: mine
                ? null
                : Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: mine ? radius : const Radius.circular(4),
              bottomRight: mine ? const Radius.circular(4) : radius,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(
                  text,
                  style: TextStyle(color: foreground, fontSize: 15),
                ),
              ),
              const SizedBox(height: 2),
              sentAt == null
                  ? Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: foreground.withValues(alpha: 0.7),
                    )
                  : Text(
                      chatTimeLabel(context, sentAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: foreground.withValues(alpha: 0.7),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    return Material(
      color: Theme.of(context).cardTheme.color,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Message",
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) => IconButton.filled(
                  onPressed: value.text.trim().isEmpty ? null : onSend,
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
