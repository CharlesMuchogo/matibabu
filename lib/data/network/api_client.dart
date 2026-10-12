import 'dart:async';

import 'package:dio/dio.dart';
import 'package:matibabu/data/network/token_store.dart';
import 'package:matibabu/domain/app_exception.dart';

class ApiClient {
  static const _retriedKey = 'retried';
  static const _refreshWindow = Duration(seconds: 30);

  final Dio dio;
  final Dio _refreshDio;
  final TokenStore _tokens;
  final DateTime Function() _now;
  final _sessionExpired = StreamController<void>.broadcast();

  ApiClient({
    required String baseUrl,
    required TokenStore tokens,
    Dio? dio,
    Dio? refreshDio,
    DateTime Function()? now,
  }) : dio = dio ?? Dio(_options(baseUrl)),
       _refreshDio = refreshDio ?? Dio(_options(baseUrl)),
       _tokens = tokens,
       _now = now ?? DateTime.now {
    this.dio.interceptors.add(
      QueuedInterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  static BaseOptions _options(String baseUrl) => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  );

  Stream<void> get sessionExpired => _sessionExpired.stream;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? data}) =>
      _send('POST', path, data: data);

  Future<dynamic> put(String path, {Object? data}) =>
      _send('PUT', path, data: data);

  Future<dynamic> patch(String path, {Object? data}) =>
      _send('PATCH', path, data: data);

  Future<dynamic> delete(String path, {Object? data}) =>
      _send('DELETE', path, data: data);

  Future<bool> hasSession() async => await _tokens.read() != null;

  Future<void> saveSession(Map<String, dynamic> json) =>
      _tokens.save(Tokens.fromJson(json));

  Future<void> clearSession() => _tokens.clear();

  Future<String?> freshAccessToken() async {
    final tokens = await _tokens.read();
    if (tokens == null) return null;
    if (!tokens.accessExpiresWithin(_refreshWindow, _now())) {
      return tokens.access;
    }
    return (await _refresh(tokens))?.access;
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data;
    } on DioException catch (e) {
      throw exceptionFrom(e);
    }
  }

  static bool _isAuthPath(RequestOptions options) =>
      options.path.startsWith('/auth/');

  static String _bearer(String token) => 'Bearer $token';

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = _isAuthPath(options) ? null : await _tokens.read();
    if (tokens != null) {
      options.headers['Authorization'] = _bearer(tokens.access);
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        _isAuthPath(options) ||
        options.extra[_retriedKey] == true) {
      return handler.next(error);
    }

    final stored = await _tokens.read();
    final alreadyRefreshed =
        stored != null &&
        options.headers['Authorization'] != _bearer(stored.access);
    final tokens = stored == null
        ? null
        : alreadyRefreshed
        ? stored
        : await _refresh(stored);
    if (tokens == null) return handler.next(error);

    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<Tokens?> _refresh(Tokens tokens) async {
    try {
      final response = await _refreshDio.post<dynamic>(
        '/auth/refresh-token',
        data: {'refresh_token': tokens.refresh},
      );
      final fresh = Tokens.fromJson(response.data as Map<String, dynamic>);
      await _tokens.save(fresh);
      return fresh;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokens.clear();
        _sessionExpired.add(null);
      }
      return null;
    }
  }
}

AppException exceptionFrom(DioException error) {
  final data = error.response?.data;
  if (data is Map && data['message'] is String) {
    final message = data['message'] as String;
    return AppException(
      message.isEmpty
          ? message
          : message[0].toUpperCase() + message.substring(1),
    );
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => const AppException(
      "Couldn't reach the server. Check your connection and try again.",
    ),
    _ => const AppException('Something went wrong. Try again.'),
  };
}

List<T> parseList<T>(
  dynamic data,
  T Function(Map<String, dynamic> json) parse,
) => (data as List).cast<Map<String, dynamic>>().map(parse).toList();
