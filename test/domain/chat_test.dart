import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/entities/chat.dart';

import '../helpers/fixtures.dart';

void main() {
  test('unread counts and the other party depend on who is looking', () {
    final c = chat(patientUnread: 2, doctorUnread: 1);
    expect(c.unreadFor(patient.id), 2);
    expect(c.unreadFor(doctor.id), 1);
    expect(c.otherParty(patient.id), doctor);
    expect(c.otherParty(doctor.id), patient);
  });

  test('a new message updates the preview and the recipient unread count', () {
    final fromDoctor = message(senderId: doctor.id, text: 'Take two');
    final updated = chat().withMessage(fromDoctor);
    expect(updated.lastMessage, 'Take two');
    expect(updated.lastSenderId, doctor.id);
    expect(updated.lastMessageAt, fromDoctor.createdAt);
    expect(updated.patientUnread, 1);
    expect(updated.doctorUnread, 0);

    final reply = updated.withMessage(message(n: 101, senderId: patient.id));
    expect(reply.doctorUnread, 1);
    expect(reply.patientUnread, 1);
  });

  test('reading clears only the reader unread count', () {
    final c = chat(patientUnread: 3, doctorUnread: 2).readBy(patient.id);
    expect(c.patientUnread, 0);
    expect(c.doctorUnread, 2);
  });

  test('round trips through json', () {
    final c = chat(lastMessage: 'hi').withMessage(message());
    expect(Chat.fromJson(c.toJson()), c);
  });
}
