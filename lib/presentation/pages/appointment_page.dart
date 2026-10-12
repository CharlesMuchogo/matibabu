import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/formatters.dart';
import 'package:matibabu/presentation/pages/booking_page.dart';
import 'package:matibabu/presentation/pages/doctor_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class AppointmentPage extends StatelessWidget {
  final String appointmentId;

  const AppointmentPage({super.key, required this.appointmentId});

  Future<void> _confirmRemove(
    BuildContext context,
    Appointment appointment,
  ) async {
    final now = DateTime.now();
    final cancelling = appointment.canCancelAt(now);
    final ok = await confirmDialog(
      context,
      title: cancelling ? "Cancel appointment?" : "Delete appointment?",
      message: cancelling
          ? "Your slot with ${appointment.doctor?.displayName ?? "the doctor"} will be released."
          : "This removes it from your history.",
      confirmLabel: cancelling ? "Cancel appointment" : "Delete",
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    context.read<AppointmentsBloc>().add(
      cancelling
          ? AppointmentCancelRequested(appointment.id)
          : AppointmentRemoveRequested(appointment.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentsBloc, AppointmentsState>(
      listenWhen: (previous, current) => previous.action != current.action,
      listener: (context, state) {
        if (state.action.isFailure) {
          showMessageDialog(context, "Something went wrong", state.message);
        } else if (state.action == Status.loaded &&
            state.byId(appointmentId) == null) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final appointment = state.byId(appointmentId);
        if (appointment == null) {
          return Scaffold(appBar: AppBar(), body: const LoadingView());
        }
        final scheme = Theme.of(context).colorScheme;
        final now = DateTime.now();
        final doctor = appointment.doctor;
        final busy = state.action.isLoading;

        return Scaffold(
          appBar: AppBar(title: const Text("Appointment")),
          body: ListView(
            padding: AppSpacing.page,
            children: [
              Card(
                child: Padding(
                  padding: AppSpacing.card,
                  child: Row(
                    children: [
                      Avatar(doctor?.profilePhoto, radius: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor?.displayName ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doctor?.specialty ?? "",
                              style: TextStyle(color: scheme.primary),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(appointment.displayStatusAt(now)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Column(
                  children: [
                    DetailTile(
                      Icons.calendar_today_outlined,
                      "Date",
                      formatDate(appointment.startsAt),
                    ),
                    const Divider(height: 1, indent: AppSpacing.md),
                    DetailTile(
                      Icons.access_time_rounded,
                      "Time",
                      formatTime(appointment.startsAt),
                    ),
                    const Divider(height: 1, indent: AppSpacing.md),
                    DetailTile(
                      Icons.location_on_outlined,
                      "Location",
                      appointment.address,
                    ),
                  ],
                ),
              ),
              if (doctor != null) ...[
                const SizedBox(height: AppSpacing.lg),
                MessageDoctorButton(doctor, tonal: true),
              ],
              const SizedBox(height: AppSpacing.sm + 4),
              if (appointment.isCancelled && doctor != null) ...[
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BookingPage(doctor: doctor),
                    ),
                  ),
                  child: const Text("Reschedule"),
                ),
                const SizedBox(height: AppSpacing.sm + 4),
              ],
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => _confirmRemove(context, appointment),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cancelled,
                  side: const BorderSide(color: AppColors.cancelled),
                ),
                child: busy
                    ? const ButtonSpinner()
                    : Text(
                        appointment.canCancelAt(now)
                            ? "Cancel appointment"
                            : "Delete appointment",
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
