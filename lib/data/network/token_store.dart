import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens extends Equatable {
  final String access;
  final String refresh;

  const Tokens({required this.access, required this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    access: json['token'] as String,
    refresh: json['refresh_token'] as String,
  );

  Map<String, dynamic> toJson() => {'token': access, 'refresh_token': refresh};

  bool accessExpiresWithin(Duration window, DateTime now) {
    final expiry = jwtExpiry(access);
    return expiry == null || !expiry.isAfter(now.add(window));
  }

  @override
  List<Object?> get props => [access, refresh];
}

DateTime? jwtExpiry(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    final exp = payload is Map ? payload['exp'] : null;
    return exp is num
        ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000)
        : null;
  } on FormatException {
    return null;
  }
}

abstract class TokenStore {
  Future<Tokens?> read();

  Future<void> save(Tokens tokens);

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  static const _key = 'session_tokens';

  final FlutterSecureStorage _storage;

  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<Tokens?> read() async {
    final raw = await _storage.read(key: _key);
    return raw == null
        ? null
        : Tokens.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Tokens tokens) =>
      _storage.write(key: _key, value: jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
