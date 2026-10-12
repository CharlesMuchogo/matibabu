import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/chats/chats_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/formatters.dart';
import 'package:matibabu/presentation/navigation/chat_router.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: BlocBuilder<ChatsBloc, ChatsState>(
        builder: (context, state) {
          final chats = state.conversations;
          if (chats.isEmpty) {
            return switch (state.status) {
              Status.failure => Center(
                child: ErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<ChatsBloc>().add(const ChatsRefreshed()),
                ),
              ),
              Status.loaded => const Center(
                child: EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "No messages yet",
                  message:
                      "Open a doctor's profile and tap Message to "
                      "start a conversation.",
                ),
              ),
              _ => const LoadingView(),
            };
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ChatsBloc>().add(const ChatsRefreshed()),
            child: ListView.separated(
              padding: AppSpacing.page,
              itemCount: chats.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _ChatTile(chats[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;

  const _ChatTile(this.chat);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final userId = context.select((AuthBloc bloc) => bloc.state.user?.id);
    if (userId == null) return const SizedBox.shrink();
    final other = chat.otherParty(userId);
    final unread = chat.unreadFor(userId);
    final at = chat.lastMessageAt;
    final preview = chat.lastSenderId == userId
        ? "You: ${chat.lastMessage}"
        : chat.lastMessage;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ChatRouter.openChat(chat.id),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Avatar(other?.profilePhoto, radius: 26),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other?.displayName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unread > 0
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: unread > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    at == null ? "" : chatListTimeLabel(context, at.toLocal()),
                    style: TextStyle(
                      fontSize: 12,
                      color: unread > 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  if (unread > 0)
                    Badge(
                      label: Text("$unread"),
                      backgroundColor: scheme.primary,
                    )
                  else
                    const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
