part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthMethod { session, email, google, apple }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final Status action;
  final AuthMethod method;
  final String message;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.action = Status.initial,
    this.method = AuthMethod.session,
    this.message = '',
  });

  bool isSubmitting(AuthMethod method) =>
      action.isLoading && this.method == method;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    Status? action,
    AuthMethod? method,
    String? message,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    action: action ?? this.action,
    method: method ?? this.method,
    message: message ?? this.message,
  );

  Map<String, dynamic> toMap() => {
    'status': status.name,
    'user': user?.toJson(),
  };

  factory AuthState.fromMap(Map<String, dynamic> map) {
    final user = map['user'];
    return AuthState(
      status: AuthStatus.values.byName(map['status'] as String),
      user: user == null ? null : User.fromJson(normalizeJson(user as Map)),
    );
  }

  @override
  List<Object?> get props => [status, user, action, method, message];
}
