import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/domain/repositories/notification_repository.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:matibabu/presentation/bloc/status.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> with SafeHandler {
  final AuthRepository _auth;
  final UserRepository _users;
  final NotificationRepository _notifications;
  late final StreamSubscription<void> _expiry;

  AuthBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required NotificationRepository notificationRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _notifications = notificationRepository,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted, transformer: droppable());
    on<LoginRequested>(
      (event, emit) => _authenticate(
        emit,
        AuthMethod.email,
        () => _auth.login(email: event.email, password: event.password),
      ),
      transformer: droppable(),
    );
    on<RegisterRequested>(
      (event, emit) => _authenticate(
        emit,
        AuthMethod.email,
        () => _auth.register(event.registration),
      ),
      transformer: droppable(),
    );
    on<SocialLoginRequested>(
      (event, emit) => _authenticate(
        emit,
        AuthMethod.values.byName(event.provider.name),
        () => _auth.socialLogin(event.provider),
      ),
      transformer: droppable(),
    );
    on<LogoutRequested>(_onLogout, transformer: droppable());
    on<AuthUserChanged>(
      (event, emit) => emit(state.copyWith(user: event.user)),
    );
    on<_SessionExpired>(
      (event, emit) => emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          message: 'Your session has expired. Sign in again.',
        ),
      ),
    );
    _expiry = _auth.sessionExpired.listen((_) => add(const _SessionExpired()));
  }

  @override
  String get storagePrefix => 'AuthBloc';

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    if (!await _auth.hasSession()) {
      return emit(const AuthState(status: AuthStatus.unauthenticated));
    }

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        action: Status.loading,
        method: AuthMethod.session,
      ),
    );
    await guard(
      () async =>
          emit(state.copyWith(user: await _users.me(), action: Status.loaded)),
      (message) =>
          emit(state.copyWith(action: Status.failure, message: message)),
    );
  }

  Future<void> _authenticate(
    Emitter<AuthState> emit,
    AuthMethod method,
    Future<User?> Function() signIn,
  ) async {
    emit(state.copyWith(action: Status.loading, method: method, message: ''));
    await guard(
      () async {
        final user = await signIn();
        emit(
          user == null
              ? state.copyWith(action: Status.initial)
              : AuthState(
                  status: AuthStatus.authenticated,
                  user: user,
                  action: Status.loaded,
                  method: method,
                ),
        );
      },
      (message) =>
          emit(state.copyWith(action: Status.failure, message: message)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _notifications.unregister();
    await _auth.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) => AuthState.fromMap(json);

  @override
  Map<String, dynamic>? toJson(AuthState state) =>
      state.status == AuthStatus.unknown ? null : state.toMap();

  @override
  Future<void> close() async {
    await _expiry.cancel();
    return super.close();
  }
}
