import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/appointment_repository.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/booking/booking_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/formatters.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';
import 'package:matibabu/presentation/widgets/doctor_tile.dart';

class BookingPage extends StatelessWidget {
  final User doctor;

  const BookingPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc(
        doctorRepository: context.read<DoctorRepository>(),
        appointmentRepository: context.read<AppointmentRepository>(),
        doctor: doctor,
      ),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  bool _isWeekend(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  Future<void> _pickDate(BuildContext context) async {
    var initial = DateTime.now();
    while (_isWeekend(initial)) {
      initial = initial.add(const Duration(days: 1));
    }
    final bloc = context.read<BookingBloc>();
    final date = await showDatePicker(
      context: context,
      selectableDayPredicate: (d) => !_isWeekend(d),
      initialDate: bloc.state.date ?? initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      helpText: "Select date of appointment",
    );
    if (date != null) bloc.add(BookingDateSelected(date));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return BlocConsumer<BookingBloc, BookingState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        final appointment = state.appointment;
        if (state.submitStatus == Status.loaded && appointment != null) {
          context.read<AppointmentsBloc>().add(AppointmentBooked(appointment));
          showSnack(context, "Your appointment was booked!");
          Navigator.pop(context);
        } else if (state.submitStatus.isFailure) {
          showMessageDialog(context, "Booking failed", state.message);
        }
      },
      builder: (context, state) {
        final date = state.date;
        return Scaffold(
          appBar: AppBar(title: const Text("Book Appointment")),
          body: ListView(
            padding: AppSpacing.page,
            children: [
              DoctorTile(context.read<BookingBloc>().doctor, navigates: false),
              const SizedBox(height: AppSpacing.lg),
              Text("Date", style: titleStyle),
              const SizedBox(height: AppSpacing.sm),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () => _pickDate(context),
                  leading: Icon(
                    Icons.calendar_today_outlined,
                    color: scheme.primary,
                  ),
                  title: Text(
                    date == null ? "Select a date" : formatDate(date),
                  ),
                  subtitle: const Text("Monday to Friday"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text("Time", style: titleStyle),
              const SizedBox(height: AppSpacing.sm),
              if (date == null)
                Text(
                  "Pick a date to see available times.",
                  style: TextStyle(color: scheme.onSurfaceVariant),
                )
              else
                _TimeSlots(state: state, date: date),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: AppSpacing.page,
              child: LoadingButton(
                label: "Book Appointment",
                loading: state.submitStatus.isLoading,
                onPressed: () =>
                    context.read<BookingBloc>().add(const BookingSubmitted()),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimeSlots extends StatelessWidget {
  final BookingState state;
  final DateTime date;

  const _TimeSlots({required this.state, required this.date});

  @override
  Widget build(BuildContext context) {
    return switch (state.slotsStatus) {
      Status.failure => ErrorView(
        message: state.message,
        onRetry: () =>
            context.read<BookingBloc>().add(BookingDateSelected(date)),
      ),
      Status.loaded when state.slots.isEmpty => const EmptyState(
        icon: Icons.event_busy_outlined,
        title: "Fully booked",
        message: "Try another date.",
      ),
      Status.loaded => Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final slot in state.slots)
            ChoiceChip(
              label: Text(formatSlot(date, slot.time)),
              selected: state.time == slot.time,
              showCheckmark: false,
              onSelected: (_) => context.read<BookingBloc>().add(
                BookingTimeSelected(slot.time),
              ),
            ),
        ],
      ),
      _ => const LoadingView(height: 120),
    };
  }
}
