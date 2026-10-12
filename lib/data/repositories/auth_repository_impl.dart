import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/social/social_auth.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _userType = 'patient';

  final ApiClient _api;
  final SocialAuth _social;

  AuthRepositoryImpl({required ApiClient api, required SocialAuth social})
    : _api = api,
      _social = social;

  @override
  Stream<void> get sessionExpired => _api.sessionExpired;

  @override
  Future<bool> hasSession() => _api.hasSession();

  @override
  Future<User> login({required String email, required String password}) =>
      _startSession(
        _api.post(
          '/auth/login',
          data: {'email': email.trim().toLowerCase(), 'password': password},
        ),
      );

  @override
  Future<User> register(Registration registration) => _startSession(
    _api.post(
      '/auth/register',
      data: {
        'first_name': registration.firstName.trim(),
        'last_name': registration.lastName.trim(),
        'email': registration.email.trim().toLowerCase(),
        'phone_number': registration.phoneNumber.trim(),
        'password': registration.password,
        'user_type': _userType,
      },
    ),
  );

  @override
  Future<User?> socialLogin(SocialProvider provider) async {
    final credential = await _social.signIn(provider);
    if (credential == null) return null;
    return _startSession(
      _api.post(
        '/auth/firebase-login',
        data: {
          'token': credential.token,
          'first_name': credential.firstName,
          'last_name': credential.lastName,
          'user_type': _userType,
        },
      ),
    );
  }

  @override
  Future<void> logout() async {
    await _social.signOut();
    await _api.clearSession();
  }

  @override
  Future<void> requestPasswordReset(String email) =>
      _api.post('/auth/forgot-password', data: {'email': email.trim()});

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _api.post(
    '/auth/reset-password',
    data: {
      'email': email.trim(),
      'code': code.trim(),
      'new_password': newPassword,
    },
  );

  Future<User> _startSession(Future<dynamic> request) async {
    final json = await request as Map<String, dynamic>;
    await _api.saveSession(json);
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }
}
