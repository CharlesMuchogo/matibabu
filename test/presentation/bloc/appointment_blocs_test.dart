import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matibabu/domain/app_exception.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/booking/booking_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockAppointmentRepository appointments;
  late MockDoctorRepository doctors;

  setUpAll(() {
    registerFallbackValue(
      const NewAppointment(doctorId: '', date: '', time: ''),
    );
  });

  setUp(() {
    mockHydratedStorage();
    appointments = MockAppointmentRepository();
    doctors = MockDoctorRepository();
  });

  group('AppointmentsBloc', () {
    final later = appointment(id: 'appointment-2', date: '2026-10-20');
    final sooner = appointment(id: 'appointment-1', date: '2026-10-15');

    blocTest<AppointmentsBloc, AppointmentsState>(
      'loads appointments sorted by start time',
      setUp: () => when(
        () => appointments.appointments(),
      ).thenAnswer((_) async => [later, sooner]),
      build: () => AppointmentsBloc(repository: appointments),
      act: (bloc) => bloc.add(const AppointmentsRequested()),
      expect: () => [
        const AppointmentsState(status: Status.loading),
        AppointmentsState(status: Status.loaded, appointments: [sooner, later]),
      ],
    );

    blocTest<AppointmentsBloc, AppointmentsState>(
      'adds a newly booked appointment in order',
      build: () => AppointmentsBloc(repository: appointments),
      seed: () =>
          AppointmentsState(status: Status.loaded, appointments: [later]),
      act: (bloc) => bloc.add(AppointmentBooked(sooner)),
      expect: () => [
        AppointmentsState(status: Status.loaded, appointments: [sooner, later]),
      ],
    );

    blocTest<AppointmentsBloc, AppointmentsState>(
      'cancels an appointment',
      setUp: () =>
          when(
            () => appointments.updateStatus(
              'appointment-1',
              AppointmentStatus.cancelled,
            ),
          ).thenAnswer(
            (_) async => sooner.copyWith(status: AppointmentStatus.cancelled),
          ),
      build: () => AppointmentsBloc(repository: appointments),
      seed: () =>
          AppointmentsState(status: Status.loaded, appointments: [sooner]),
      act: (bloc) =>
          bloc.add(const AppointmentCancelRequested('appointment-1')),
      expect: () => [
        AppointmentsState(
          status: Status.loaded,
          appointments: [sooner],
          action: Status.loading,
        ),
        AppointmentsState(
          status: Status.loaded,
          appointments: [sooner.copyWith(status: AppointmentStatus.cancelled)],
          action: Status.loaded,
        ),
      ],
    );

    blocTest<AppointmentsBloc, AppointmentsState>(
      'removes an appointment and reports failures without losing data',
      setUp: () {
        when(
          () => appointments.remove('appointment-1'),
        ).thenAnswer((_) async {});
        when(() => appointments.remove('appointment-2')).thenThrow(
          const AppException(
            'only cancelled or past appointments can be removed',
          ),
        );
      },
      build: () => AppointmentsBloc(repository: appointments),
      seed: () => AppointmentsState(
        status: Status.loaded,
        appointments: [sooner, later],
      ),
      act: (bloc) async {
        bloc.add(const AppointmentRemoveRequested('appointment-1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AppointmentRemoveRequested('appointment-2'));
      },
      skip: 2,
      expect: () => [
        AppointmentsState(
          status: Status.loaded,
          appointments: [later],
          action: Status.loading,
        ),
        AppointmentsState(
          status: Status.loaded,
          appointments: [later],
          action: Status.failure,
          message: 'only cancelled or past appointments can be removed',
        ),
      ],
    );

    test('finds upcoming appointments', () {
      final state = AppointmentsState(
        appointments: [
          appointment(id: 'appointment-1', date: '2026-10-01'),
          appointment(id: 'appointment-2', date: '2026-10-20'),
          appointment(
            id: 'appointment-3',
            date: '2026-10-21',
            status: AppointmentStatus.cancelled,
          ),
        ],
      );
      expect(state.upcomingAt(DateTime(2026, 10, 14)).map((a) => a.id), [
        'appointment-2',
      ]);
    });
  });

  group('BookingBloc', () {
    final date = DateTime(2026, 10, 14);
    const open = Slot(time: '09:30', available: true);
    const taken = Slot(time: '10:00', available: false);

    BookingBloc build() => BookingBloc(
      doctorRepository: doctors,
      appointmentRepository: appointments,
      doctor: doctor,
    );

    blocTest<BookingBloc, BookingState>(
      'shows only available slots for the chosen day',
      setUp: () => when(
        () => doctors.availability(doctorId: 'doctor-2', date: date),
      ).thenAnswer((_) async => [open, taken]),
      build: build,
      act: (bloc) => bloc.add(BookingDateSelected(date)),
      expect: () => [
        BookingState(date: date, slotsStatus: Status.loading),
        BookingState(
          date: date,
          slotsStatus: Status.loaded,
          slots: const [open],
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'requires a date and time before booking',
      build: build,
      act: (bloc) => bloc.add(const BookingSubmitted()),
      expect: () => [
        const BookingState(
          submitStatus: Status.failure,
          message: 'Pick both a date and a time.',
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'books the chosen slot at the doctor hospital',
      setUp: () => when(
        () => appointments.book(
          const NewAppointment(
            doctorId: 'doctor-2',
            date: '2026-10-14',
            time: '09:30',
            address: 'Aga Khan',
          ),
        ),
      ).thenAnswer((_) async => appointment()),
      build: build,
      seed: () => BookingState(
        date: date,
        slotsStatus: Status.loaded,
        slots: const [open],
        time: '09:30',
      ),
      act: (bloc) => bloc.add(const BookingSubmitted()),
      skip: 1,
      expect: () => [
        BookingState(
          date: date,
          slotsStatus: Status.loaded,
          slots: const [open],
          time: '09:30',
          submitStatus: Status.loaded,
          appointment: appointment(),
        ),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'reloads slots when the chosen one was just taken',
      setUp: () {
        when(
          () => appointments.book(any()),
        ).thenThrow(const AppException('This time slot is already booked'));
        when(
          () => doctors.availability(doctorId: 'doctor-2', date: date),
        ).thenAnswer((_) async => [taken]);
      },
      build: build,
      seed: () => BookingState(
        date: date,
        slotsStatus: Status.loaded,
        slots: const [open],
        time: '09:30',
      ),
      act: (bloc) => bloc.add(const BookingSubmitted()),
      skip: 1,
      expect: () => [
        BookingState(
          date: date,
          slotsStatus: Status.loading,
          submitStatus: Status.failure,
          message: 'This time slot is already booked',
        ),
        BookingState(
          date: date,
          slotsStatus: Status.loaded,
          submitStatus: Status.failure,
          message: 'This time slot is already booked',
        ),
      ],
    );
  });
}
