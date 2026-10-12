import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/network/token_store.dart';
import 'package:matibabu/data/repositories/appointment_repository_impl.dart';
import 'package:matibabu/data/repositories/auth_repository_impl.dart';
import 'package:matibabu/data/repositories/doctor_repository_impl.dart';
import 'package:matibabu/data/repositories/user_repository_impl.dart';
import 'package:matibabu/data/social/social_auth.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fake_adapter.dart';
import '../helpers/fixtures.dart';
import 'api_client_test.dart' show MemoryTokenStore;

class MockSocialAuth extends Mock implements SocialAuth {}

void main() {
  late FakeAdapter adapter;
  late MemoryTokenStore store;
  late ApiClient api;

  void respond(FakeResponse Function(RequestOptions options) handler) {
    adapter = FakeAdapter(handler);
    store = MemoryTokenStore();
    api = ApiClient(
      baseUrl: 'http://api.test/api/v1',
      tokens: store,
      dio: fakeDio(adapter),
      refreshDio: fakeDio(adapter),
    );
  }

  Map<String, dynamic> session() => {
    'token': 'access',
    'refresh_token': 'refresh',
    'user': patient.toJson(),
  };

  group('AuthRepositoryImpl', () {
    late MockSocialAuth social;

    setUp(() {
      social = MockSocialAuth();
      when(() => social.signOut()).thenAnswer((_) async {});
    });

    test('login normalises the email and stores the session', () async {
      respond((_) => FakeResponse(200, session()));
      final repository = AuthRepositoryImpl(api: api, social: social);

      final user = await repository.login(
        email: ' Pat@Example.com ',
        password: 'secret1',
      );

      expect(user, patient);
      expect(adapter.requests.single.path, '/auth/login');
      expect(adapter.requests.single.data, {
        'email': 'pat@example.com',
        'password': 'secret1',
      });
      expect(store.tokens, const Tokens(access: 'access', refresh: 'refresh'));
    });

    test('register signs up a patient without an address', () async {
      respond((_) => FakeResponse(200, session()));
      await AuthRepositoryImpl(api: api, social: social).register(
        const Registration(
          firstName: 'Pat',
          lastName: 'Ient',
          email: 'pat@example.com',
          phoneNumber: '0700',
          password: 'secret1',
        ),
      );

      expect(
        adapter.requests.single.data,
        containsPair('user_type', 'patient'),
      );
      expect(
        (adapter.requests.single.data as Map).containsKey('address'),
        isFalse,
      );
    });

    test(
      'social login sends the provider token to the matching endpoint',
      () async {
        respond((_) => FakeResponse(200, session()));
        when(() => social.signIn(SocialProvider.google)).thenAnswer(
          (_) async => const SocialCredential(
            token: 'firebase-id-token',
            firstName: 'Pat',
          ),
        );

        final user = await AuthRepositoryImpl(
          api: api,
          social: social,
        ).socialLogin(SocialProvider.google);

        expect(user, patient);
        expect(adapter.requests.single.path, '/auth/firebase-login');
        expect(
          adapter.requests.single.data,
          containsPair('token', 'firebase-id-token'),
        );
      },
    );

    test('a cancelled social login makes no request', () async {
      respond((_) => FakeResponse(200, session()));
      when(
        () => social.signIn(SocialProvider.apple),
      ).thenAnswer((_) async => null);

      expect(
        await AuthRepositoryImpl(
          api: api,
          social: social,
        ).socialLogin(SocialProvider.apple),
        isNull,
      );
      expect(adapter.requests, isEmpty);
    });

    test('logout clears the stored session', () async {
      respond((_) => const FakeResponse(200));
      store.tokens = const Tokens(access: 'a', refresh: 'r');
      await AuthRepositoryImpl(api: api, social: social).logout();
      expect(store.tokens, isNull);
      verify(() => social.signOut()).called(1);
    });
  });

  group('UserRepositoryImpl', () {
    test('sends only the changed fields as json', () async {
      respond((_) => FakeResponse(200, patient.toJson()));
      await UserRepositoryImpl(
        api,
      ).updateProfile(const ProfileUpdate(address: 'Mombasa'));

      expect(adapter.requests.single.method, 'PUT');
      expect(adapter.requests.single.data, {'address': 'Mombasa'});
    });

    test('uploads a photo as multipart form data', () async {
      respond((_) => FakeResponse(200, patient.toJson()));
      await UserRepositoryImpl(api).updateProfile(
        const ProfileUpdate(photoPath: 'pubspec.yaml', firstName: 'Pat'),
      );

      final data = adapter.requests.single.data as FormData;
      expect(data.files.single.key, 'photo');
      expect(Map.fromEntries(data.fields), {'first_name': 'Pat'});
    });
  });

  group('DoctorRepositoryImpl', () {
    test('filters doctors by category and trimmed query', () async {
      respond((_) => FakeResponse(200, [doctor.toJson()]));
      final doctors = await DoctorRepositoryImpl(
        api,
      ).doctors(categoryId: 'category-3', query: ' dent ');

      expect(doctors, [doctor]);
      expect(adapter.requests.single.queryParameters, {
        'limit': 100,
        'category_id': 'category-3',
        'q': 'dent',
      });
    });

    test('omits empty filters', () async {
      respond((_) => const FakeResponse(200, []));
      await DoctorRepositoryImpl(api).doctors();
      expect(adapter.requests.single.queryParameters, {'limit': 100});
    });

    test('requests availability for a day', () async {
      respond(
        (_) => const FakeResponse(200, {
          'date': '2026-10-14',
          'slots': [
            {'time': '08:00', 'available': true},
            {'time': '08:30', 'available': false},
          ],
        }),
      );
      final slots = await DoctorRepositoryImpl(
        api,
      ).availability(doctorId: 'doctor-2', date: DateTime(2026, 10, 14));

      expect(adapter.requests.single.path, '/doctors/doctor-2/availability');
      expect(adapter.requests.single.queryParameters, {'date': '2026-10-14'});
      expect(slots, const [
        Slot(time: '08:00', available: true),
        Slot(time: '08:30', available: false),
      ]);
    });
  });

  group('AppointmentRepositoryImpl', () {
    test('cancels through the status endpoint', () async {
      final cancelled = appointment(status: AppointmentStatus.cancelled);
      respond((_) => FakeResponse(200, cancelled.toJson()));

      final result = await AppointmentRepositoryImpl(
        api,
      ).updateStatus('appointment-10', AppointmentStatus.cancelled);

      expect(result, cancelled);
      expect(adapter.requests.single.method, 'PATCH');
      expect(
        adapter.requests.single.path,
        '/appointments/appointment-10/status',
      );
      expect(adapter.requests.single.data, {'status': 'cancelled'});
    });

    test('removes with a delete', () async {
      respond(
        (_) => const FakeResponse(200, {'message': 'appointment removed'}),
      );
      await AppointmentRepositoryImpl(api).remove('appointment-10');
      expect(adapter.requests.single.method, 'DELETE');
    });
  });
}
