import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/domain/entities/chat.dart';
import 'package:matibabu/domain/entities/user.dart';

const patient = User(
  id: 'patient-1',
  email: 'pat@example.com',
  firstName: 'Pat',
  lastName: 'Ient',
  address: 'Nairobi',
);

const dentistry = Category(id: 'category-3', name: 'Dentist');

const doctor = User(
  id: 'doctor-2',
  email: 'doc@example.com',
  firstName: 'Jane',
  lastName: 'Doe',
  phoneNumber: '0700000000',
  userType: UserType.doctor,
  doctorProfile: DoctorProfile(
    categoryId: 'category-3',
    hospital: 'Aga Khan',
    description: 'Teeth',
    category: dentistry,
  ),
);

Appointment appointment({
  String id = 'appointment-10',
  String date = '2026-10-14',
  String time = '09:30',
  AppointmentStatus status = AppointmentStatus.pending,
}) => Appointment(
  id: id,
  patientId: patient.id,
  doctorId: doctor.id,
  date: date,
  time: time,
  status: status,
  address: 'Aga Khan',
  doctor: doctor,
  patient: patient,
);

String messageId(int n) => 'message-${n.toString().padLeft(3, '0')}';

ChatMessage message({
  int n = 100,
  String chatId = 'chat-5',
  String senderId = 'doctor-2',
  String text = 'hello',
}) => ChatMessage(
  id: messageId(n),
  chatId: chatId,
  senderId: senderId,
  text: text,
  createdAt: DateTime.utc(2026, 10, 12, 9).add(Duration(minutes: n)),
);

Chat chat({
  String id = 'chat-5',
  String lastMessage = '',
  int patientUnread = 0,
  int doctorUnread = 0,
}) => Chat(
  id: id,
  patientId: patient.id,
  doctorId: doctor.id,
  lastMessage: lastMessage,
  patientUnread: patientUnread,
  doctorUnread: doctorUnread,
  patient: patient,
  doctor: doctor,
);
