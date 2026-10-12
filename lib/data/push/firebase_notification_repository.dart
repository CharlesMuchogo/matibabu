import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/entities/push_message.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  final ApiClient _api;
  final FirebaseMessaging _messaging;
  StreamSubscription<String>? _tokenRefresh;

  FirebaseNotificationRepository({
    required ApiClient api,
    FirebaseMessaging? messaging,
  }) : _api = api,
       _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Stream<PushMessage> get foregroundMessages => FirebaseMessaging.onMessage
      .map(_toPush)
      .where((message) => message != null)
      .cast<PushMessage>();

  @override
  Stream<String> get openedChats async* {
    final initial = _chatId(await _messaging.getInitialMessage());
    if (initial != null) yield initial;
    yield* FirebaseMessaging.onMessageOpenedApp
        .map(_chatId)
        .where((id) => id != null)
        .cast<String>();
  }

  @override
  Future<void> register() async {
    try {
      await _messaging.requestPermission();
      _tokenRefresh ??= _messaging.onTokenRefresh.listen(_save);
      final token = await _messaging.getToken();
      if (token != null) await _save(token);
    } on Exception catch (e) {
      log('Push registration failed', error: e);
    }
  }

  @override
  Future<void> unregister() async {
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    try {
      final token = await _messaging.getToken();
      if (token != null) await _api.delete('/devices', data: {'token': token});
    } on Exception catch (e) {
      log('Push unregistration failed', error: e);
    }
  }

  Future<void> _save(String token) async {
    try {
      await _api.post('/devices', data: {'token': token});
    } on AppException catch (e) {
      log('Saving push token failed', error: e);
    }
  }

  static String? _chatId(RemoteMessage? message) {
    final chatId = message?.data['chat_id'];
    return message?.data['type'] == 'chat' && chatId is String && chatId.isNotEmpty
        ? chatId
        : null;
  }

  static PushMessage? _toPush(RemoteMessage message) {
    final chatId = _chatId(message);
    if (chatId == null) return null;
    return PushMessage(
      chatId: chatId,
      title: message.notification?.title ?? 'New message',
      body: message.notification?.body ?? '',
    );
  }
}
