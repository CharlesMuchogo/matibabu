import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class FakeResponse {
  final int status;
  final Object? body;

  const FakeResponse(this.status, [this.body]);
}

class FakeAdapter implements HttpClientAdapter {
  final FakeResponse Function(RequestOptions options) handler;
  final requests = <RequestOptions>[];

  FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = handler(options);
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio fakeDio(FakeAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://api.test/api/v1'))
      ..httpClientAdapter = adapter;

String fakeJwt(DateTime expiresAt) {
  String part(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256'})}.${part({'exp': expiresAt.millisecondsSinceEpoch ~/ 1000})}.signature';
}
