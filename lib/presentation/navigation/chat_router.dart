import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/presentation/pages/chat_page.dart';

class ChatRouter {
  ChatRouter._();

  static const scheme = "matibabu";

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static final _openChats = <String>[];
  static String? _pendingChatId;
  static bool _ready = false;
  static StreamSubscription<Uri>? _links;

  static void init() {
    _links ??= AppLinks().uriLinkStream.listen(handleUri, onError: (_) {});
  }

  static String? get activeChatId =>
      _openChats.isEmpty ? null : _openChats.last;

  static void chatOpened(String chatId) => _openChats.add(chatId);

  static void chatClosed(String chatId) => _openChats.remove(chatId);

  static String _routeName(String chatId) => "/chat/$chatId";

  static void handleUri(Uri uri) {
    final chatId = uri.scheme == scheme && uri.host == "chat"
        ? uri.pathSegments.firstOrNull
        : null;
    if (chatId != null) openChat(chatId);
  }

  static void openChat(String chatId) {
    final navigator = navigatorKey.currentState;
    if (!_ready || navigator == null) {
      _pendingChatId = chatId;
      return;
    }
    final name = _routeName(chatId);
    if (_openChats.contains(chatId)) {
      navigator.popUntil((r) => r.settings.name == name || r.isFirst);
      return;
    }
    navigator.push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: (_) => ChatPage(chatId: chatId),
      ),
    );
  }

  static void ready() {
    _ready = true;
    final pending = _pendingChatId;
    _pendingChatId = null;
    if (pending != null) openChat(pending);
  }

  static void closed() {
    _ready = false;
    _openChats.clear();
  }
}
