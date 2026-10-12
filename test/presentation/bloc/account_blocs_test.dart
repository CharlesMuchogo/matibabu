import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/entities/push_message.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:matibabu/presentation/bloc/notifications/notifications_bloc.dart';
import 'package:matibabu/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:matibabu/presentation/bloc/profile/profile_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/bloc/theme/theme_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  setUp(mockHydratedStorage);

  group('ProfileBloc', () {
    late MockUserRepository users;

    setUp(() => users = MockUserRepository());

    blocTest<ProfileBloc, ProfileState>(
      'updates details',
      setUp: () => when(
        () => users.updateProfile(const ProfileUpdate(address: 'Mombasa')),
      ).thenAnswer((_) async => patient),
      build: () => ProfileBloc(repository: users),
      act: (bloc) => bloc.add(
        const ProfileUpdateSubmitted(ProfileUpdate(address: 'Mombasa')),
      ),
      expect: () => [
        const ProfileState(status: Status.loading),
        const ProfileState(status: Status.loaded, user: patient),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'tracks photo uploads separately and reports failures',
      setUp: () => when(
        () => users.updateProfile(const ProfileUpdate(photoPath: 'a.jpg')),
      ).thenThrow(const AppException('Photo must be 5MB or smaller')),
      build: () => ProfileBloc(repository: users),
      act: (bloc) => bloc.add(
        const ProfileUpdateSubmitted(ProfileUpdate(photoPath: 'a.jpg')),
      ),
      expect: () => [
        const ProfileState(
          status: Status.loading,
          kind: ProfileUpdateKind.photo,
        ),
        const ProfileState(
          status: Status.failure,
          kind: ProfileUpdateKind.photo,
          message: 'Photo must be 5MB or smaller',
        ),
      ],
      verify: (bloc) =>
          expect(bloc.state.isLoading(ProfileUpdateKind.details), isFalse),
    );
  });

  group('PasswordResetBloc', () {
    late MockAuthRepository auth;

    setUp(() => auth = MockAuthRepository());

    blocTest<PasswordResetBloc, PasswordResetState>(
      'requests a code then resets the password',
      setUp: () {
        when(
          () => auth.requestPasswordReset(' pat@example.com'),
        ).thenAnswer((_) async {});
        when(
          () => auth.resetPassword(
            email: 'pat@example.com',
            code: '123456',
            newPassword: 'newpass1',
          ),
        ).thenAnswer((_) async {});
      },
      build: () => PasswordResetBloc(repository: auth),
      act: (bloc) async {
        bloc.add(const PasswordResetCodeRequested(' pat@example.com'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(
          const PasswordResetSubmitted(code: '123456', newPassword: 'newpass1'),
        );
      },
      expect: () => [
        const PasswordResetState(status: Status.loading),
        const PasswordResetState(
          step: PasswordResetStep.code,
          status: Status.loaded,
          email: 'pat@example.com',
        ),
        const PasswordResetState(
          step: PasswordResetStep.code,
          status: Status.loading,
          email: 'pat@example.com',
        ),
        const PasswordResetState(
          step: PasswordResetStep.done,
          status: Status.loaded,
          email: 'pat@example.com',
        ),
      ],
    );

    blocTest<PasswordResetBloc, PasswordResetState>(
      'stays on the code step when the code is wrong',
      setUp: () => when(
        () => auth.resetPassword(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(const AppException('Invalid or expired code')),
      build: () => PasswordResetBloc(repository: auth),
      seed: () => const PasswordResetState(
        step: PasswordResetStep.code,
        email: 'pat@example.com',
      ),
      act: (bloc) => bloc.add(
        const PasswordResetSubmitted(code: '000000', newPassword: 'newpass1'),
      ),
      skip: 1,
      expect: () => [
        const PasswordResetState(
          step: PasswordResetStep.code,
          status: Status.failure,
          email: 'pat@example.com',
          message: 'Invalid or expired code',
        ),
      ],
    );
  });

  group('NotificationsBloc', () {
    late MockNotificationRepository notifications;
    late StreamController<PushMessage> foreground;
    late StreamController<String> opened;

    setUp(() {
      notifications = MockNotificationRepository();
      foreground = StreamController<PushMessage>();
      opened = StreamController<String>();
      when(() => notifications.register()).thenAnswer((_) async {});
      when(
        () => notifications.foregroundMessages,
      ).thenAnswer((_) => foreground.stream);
      when(() => notifications.openedChats).thenAnswer((_) => opened.stream);
    });

    const push = PushMessage(
      chatId: 'chat-5',
      title: 'Dr. Jane Doe',
      body: 'hello',
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'registers and surfaces pushes and opened chats as distinct states',
      build: () => NotificationsBloc(repository: notifications),
      act: (bloc) async {
        bloc.add(const NotificationsStarted());
        await Future<void>.delayed(Duration.zero);
        foreground.add(push);
        foreground.add(push);
        await Future<void>.delayed(Duration.zero);
        opened.add('chat-5');
      },
      expect: () => [
        const NotificationsState(sequence: 1, foreground: push),
        const NotificationsState(sequence: 2, foreground: push),
        const NotificationsState(sequence: 3, openChatId: 'chat-5'),
      ],
      verify: (_) => verify(() => notifications.register()).called(1),
    );
  });

  group('ThemeCubit', () {
    blocTest<ThemeCubit, ThemeMode>(
      'switches theme mode',
      build: ThemeCubit.new,
      act: (cubit) => cubit.select(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
    );

    test('persists the mode by name', () {
      final cubit = ThemeCubit();
      expect(cubit.toJson(ThemeMode.light), {'mode': 'light'});
      expect(cubit.fromJson({'mode': 'dark'}), ThemeMode.dark);
      expect(cubit.fromJson({'mode': 'neon'}), isNull);
    });
  });
}
