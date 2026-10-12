import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/network/token_store.dart';
import 'package:matibabu/domain/app_exception.dart';

import '../helpers/fake_adapter.dart';

class MemoryTokenStore implements TokenStore {
  Tokens? tokens;

  MemoryTokenStore([this.tokens]);

  @override
  Future<Tokens?> read() async => tokens;

  @override
  Future<void> save(Tokens tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}

void main() {
  final now = DateTime(2026, 10, 12, 12);
  final valid = fakeJwt(now.add(const Duration(hours: 1)));
  final expiring = fakeJwt(now.add(const Duration(seconds: 5)));
  final refreshed = fakeJwt(now.add(const Duration(hours: 24)));

  late MemoryTokenStore store;
  late FakeAdapter api;
  late FakeAdapter auth;
  late int refreshStatus;

  ApiClient client() => ApiClient(
    baseUrl: 'http://api.test/api/v1',
    tokens: store,
    dio: fakeDio(api),
    refreshDio: fakeDio(auth),
    now: () => now,
  );

  setUp(() {
    store = MemoryTokenStore(Tokens(access: valid, refresh: 'refresh-1'));
    refreshStatus = 200;
    auth = FakeAdapter(
      (_) => FakeResponse(
        refreshStatus,
        refreshStatus == 200
            ? {'token': refreshed, 'refresh_token': 'refresh-2'}
            : {'message': 'invalid refresh token'},
      ),
    );
  });

  test('sends the access token on API calls but not on auth calls', () async {
    api = FakeAdapter((_) => const FakeResponse(200, {'ok': true}));
    final c = client();

    await c.get('/users/me');
    await c.post('/auth/login', data: {});

    expect(api.requests[0].headers['Authorization'], 'Bearer $valid');
    expect(api.requests[1].headers.containsKey('Authorization'), isFalse);
  });

  test('refreshes once on 401 and retries with the new token', () async {
    api = FakeAdapter(
      (options) => options.headers['Authorization'] == 'Bearer $refreshed'
          ? const FakeResponse(200, {'id': 1})
          : const FakeResponse(401, {'message': 'Invalid auth claims'}),
    );

    expect(await client().get('/users/me'), {'id': 1});
    expect(auth.requests.single.data, {'refresh_token': 'refresh-1'});
    expect(store.tokens, Tokens(access: refreshed, refresh: 'refresh-2'));
    expect(api.requests, hasLength(2));
  });

  test('ends the session when the refresh token is rejected', () async {
    refreshStatus = 401;
    api = FakeAdapter(
      (_) => const FakeResponse(401, {'message': 'Invalid auth claims'}),
    );
    final c = client();
    final expired = expectLater(c.sessionExpired, emits(null));

    await expectLater(c.get('/users/me'), throwsA(isA<AppException>()));
    await expired;
    expect(store.tokens, isNull);
  });

  test('maps API errors to readable exceptions', () async {
    api = FakeAdapter(
      (_) => const FakeResponse(409, {
        'message': 'this time slot is already booked',
      }),
    );

    await expectLater(
      client().post('/appointments', data: {}),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'This time slot is already booked',
        ),
      ),
    );
  });

  test('maps connection failures to a connectivity message', () {
    final error = exceptionFrom(
      DioException.connectionError(
        requestOptions: RequestOptions(),
        reason: 'offline',
      ),
    );
    expect(error.message, contains("Couldn't reach the server"));
  });

  test('returns the stored token while it is fresh', () async {
    api = FakeAdapter((_) => const FakeResponse(200));
    expect(await client().freshAccessToken(), valid);
    expect(auth.requests, isEmpty);
  });

  test('refreshes the token before it expires', () async {
    store.tokens = Tokens(access: expiring, refresh: 'refresh-1');
    api = FakeAdapter((_) => const FakeResponse(200));
    expect(await client().freshAccessToken(), refreshed);
  });

  test('has no token without a session', () async {
    store.tokens = null;
    api = FakeAdapter((_) => const FakeResponse(200));
    final c = client();
    expect(await c.freshAccessToken(), isNull);
    expect(await c.hasSession(), isFalse);
  });

  test('reads the expiry from a jwt', () {
    expect(jwtExpiry(valid), now.add(const Duration(hours: 1)));
    expect(jwtExpiry('not-a-jwt'), isNull);
  });
}
