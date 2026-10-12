import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/data/network/api_client.dart';
import 'package:matibabu/data/network/token_store.dart';
import 'package:matibabu/data/realtime/chat_socket.dart';
import 'package:matibabu/data/repositories/appointment_repository_impl.dart';
import 'package:matibabu/data/repositories/auth_repository_impl.dart';
import 'package:matibabu/data/repositories/chat_repository_impl.dart';
import 'package:matibabu/data/repositories/doctor_repository_impl.dart';
import 'package:matibabu/data/repositories/user_repository_impl.dart';
import 'package:matibabu/data/social/social_auth.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';

import '../data/api_client_test.dart' show MemoryTokenStore;
import '../helpers/fake_adapter.dart' show fakeJwt;

DateTime nextWeekday() {
  var day = DateTime.now().add(const Duration(days: 1));
  while (day.weekday > DateTime.friday) {
    day = day.add(const Duration(days: 1));
  }
  return DateTime(day.year, day.month, day.day);
}

void main() {
  final baseUrl = Platform.environment['MATIBABU_API_URL'];
  final stamp = DateTime.now().microsecondsSinceEpoch;

  late MemoryTokenStore store;
  late ApiClient api;
  late Dio doctorApi;
  late String doctorId;

  setUpAll(() async {
    if (baseUrl == null) return;
    store = MemoryTokenStore();
    api = ApiClient(baseUrl: '$baseUrl/api/v1', tokens: store);

    doctorApi = Dio(BaseOptions(baseUrl: '$baseUrl/api/v1'));
    final registered = await doctorApi.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': 'doctor$stamp@example.com',
        'first_name': 'Jane',
        'last_name': 'Contract',
        'password': 'secret1',
        'user_type': 'doctor',
      },
    );
    doctorId = registered.data!['user']['id'] as String;
    doctorApi.options.headers['Authorization'] =
        'Bearer ${registered.data!['token']}';
    final dentist = (await doctorApi.get<List<dynamic>>('/categories')).data!
        .cast<Map<String, dynamic>>()
        .firstWhere((c) => c['name'] == 'Dentist');
    await doctorApi.put<dynamic>(
      '/doctors/me',
      data: {'category_id': dentist['id'], 'hospital': 'Contract Clinic'},
    );
  });

  test(
    'the app data layer works against the real API',
    () async {
      final auth = AuthRepositoryImpl(api: api, social: FirebaseSocialAuth());
      final patient = await auth.register(
        Registration(
          firstName: 'Pat',
          lastName: 'Contract',
          email: 'patient$stamp@example.com',
          phoneNumber: '0700000000',
          password: 'secret1',
        ),
      );
      expect(patient.address, isEmpty);
      expect(await auth.hasSession(), isTrue);

      final users = UserRepositoryImpl(api);
      expect(
        (await users.updateProfile(
          const ProfileUpdate(address: 'Mombasa'),
        )).address,
        'Mombasa',
      );
      await expectLater(
        users.updateProfile(
          const ProfileUpdate(photoPath: 'assets/images/emptyprofile.png'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'File uploads are not configured',
          ),
        ),
      );

      final doctors = DoctorRepositoryImpl(api);
      final dentist = (await doctors.categories()).firstWhere(
        (c) => c.name == 'Dentist',
      );
      final listed = await doctors.doctors(
        categoryId: dentist.id,
        query: 'contract',
      );
      final doctor = listed.firstWhere((d) => d.id == doctorId);
      expect(doctor.displayName, 'Dr. Jane Contract');
      expect(doctor.specialty, 'Dentist');
      expect(doctor.hospital, 'Contract Clinic');

      final day = nextWeekday();
      final slots = await doctors.availability(doctorId: doctorId, date: day);
      expect(slots.first, const Slot(time: '08:00', available: true));

      final appointments = AppointmentRepositoryImpl(api);
      final booked = await appointments.book(
        NewAppointment(
          doctorId: doctorId,
          date: apiDate(day),
          time: '08:00',
          address: doctor.hospital,
        ),
      );
      expect(booked.doctor?.displayName, 'Dr. Jane Contract');
      expect(booked.startsAt, DateTime(day.year, day.month, day.day, 8));
      await expectLater(
        appointments.book(
          NewAppointment(doctorId: doctorId, date: apiDate(day), time: '08:00'),
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'This time slot is already booked',
          ),
        ),
      );
      expect(
        (await doctors.availability(
          doctorId: doctorId,
          date: day,
        )).first.available,
        isFalse,
      );
      expect(
        (await appointments.appointments()).map((a) => a.id),
        contains(booked.id),
      );

      final cancelled = await appointments.updateStatus(
        booked.id,
        AppointmentStatus.cancelled,
      );
      expect(cancelled.status, AppointmentStatus.cancelled);
      await appointments.remove(booked.id);
      expect(
        (await appointments.appointments()).map((a) => a.id),
        isNot(contains(booked.id)),
      );

      final expired = fakeJwt(
        DateTime.now().subtract(const Duration(minutes: 1)),
      );
      store.tokens = Tokens(access: expired, refresh: store.tokens!.refresh);
      expect((await users.me()).id, patient.id);
      expect(store.tokens!.access, isNot(expired));

      final socket = ChatSocket(
        url: Uri.parse(
          baseUrl!.replaceFirst('http', 'ws'),
        ).replace(path: '/api/v1/ws'),
        token: api.freshAccessToken,
      );
      final chats = ChatRepositoryImpl(api: api, socket: socket);
      final events = <ChatEvent>[];
      final subscription = chats.events.listen(events.add);
      chats.connect();

      final chat = await chats.open(doctorId);
      expect(chat.otherParty(patient.id)?.id, doctorId);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(events, contains(const ChatConnected()));

      await doctorApi.post<dynamic>(
        '/chats/${chat.id}/messages',
        data: {'text': 'Hello from the doctor'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final received = events.whereType<ChatMessageReceived>().single.message;
      expect(received.text, 'Hello from the doctor');
      expect(received.senderId, doctorId);

      final unread = await chats.chat(chat.id);
      expect(unread.unreadFor(patient.id), 1);
      await chats.markRead(chat.id);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(
        events,
        contains(ChatReadReceived(chatId: chat.id, userId: patient.id)),
      );

      final sent = await chats.send(chat.id, 'Thanks doc');
      final history = await chats.messages(chat.id);
      expect(history.map((m) => m.id), [sent.id, received.id]);
      expect(await chats.messages(chat.id, before: sent.id), [received]);
      expect((await chats.chats()).single.lastMessage, 'Thanks doc');

      await subscription.cancel();
      await chats.disconnect();
      await auth.logout();
      expect(await auth.hasSession(), isFalse);
    },
    skip: baseUrl == null
        ? 'Set MATIBABU_API_URL to run against a live API'
        : false,
  );
}
