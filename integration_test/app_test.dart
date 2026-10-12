import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:matibabu/app.dart';
import 'package:matibabu/dependencies.dart';
import 'package:matibabu/presentation/navigation/chat_router.dart';
import 'package:matibabu/presentation/pages/chat_page.dart';

const _email = String.fromEnvironment('TEST_EMAIL');
const _password = String.fromEnvironment('TEST_PASSWORD');
const _doctor = String.fromEnvironment('TEST_DOCTOR');

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapAndWait(
  WidgetTester tester,
  Finder tap,
  Finder expected,
) async {
  await tester.tap(tap.first);
  await waitFor(tester, expected);
  await settle(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a patient can sign in, find a doctor, chat and sign out', (
    tester,
  ) async {
    await Firebase.initializeApp();
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(
        (await Directory.systemTemp.createTemp()).path,
      ),
    );
    final dependencies = Dependencies.create();
    await dependencies.auth.logout();

    await tester.pumpWidget(App(dependencies: dependencies));
    await waitFor(tester, find.text('Welcome back'));

    await tester.enterText(find.widgetWithText(TextField, 'Email'), _email);
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      _password,
    );
    await tapAndWait(
      tester,
      find.text('Sign in'),
      find.text('Upcoming appointments'),
    );
    await waitFor(tester, find.text('Dentist'));
    await waitFor(tester, find.text(_doctor));

    await tapAndWait(tester, find.text('Search'), find.text('Find a Doctor'));
    await tester.enterText(find.byType(TextField), 'contract');
    await waitFor(tester, find.text(_doctor));

    await tapAndWait(
      tester,
      find.text(_doctor).last,
      find.text('Current hospital'),
    );
    await tapAndWait(
      tester,
      find.text('Message'),
      find.widgetWithText(TextField, 'Message'),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Message'),
      'Hello from the app',
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    final bubble = find.widgetWithText(MessageBubble, 'Hello from the app');
    await waitFor(tester, bubble);
    await waitFor(
      tester,
      find.descendant(of: bubble, matching: find.textContaining(':')),
    );

    ChatRouter.navigatorKey.currentState!.popUntil((route) => route.isFirst);
    await waitFor(tester, find.text('Find a Doctor'));
    await settle(tester);
    await tapAndWait(
      tester,
      find.text('Messages'),
      find.text('You: Hello from the app'),
    );

    await tapAndWait(
      tester,
      find.text('History'),
      find.text('Medical History'),
    );
    await tapAndWait(tester, find.text('Profile'), find.text(_email));
    await tester.ensureVisible(find.text('Log out'));
    await settle(tester);
    await tapAndWait(tester, find.text('Log out'), find.text('Log out?'));
    await tapAndWait(
      tester,
      find.text('Log out').last,
      find.text('Welcome back'),
    );
  });
}
