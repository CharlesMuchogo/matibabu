import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/models/appointment.dart';
import 'package:matibabu/pages/bookingpage.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class AppointmentPage extends StatelessWidget {
  final Appointment appointment;

  const AppointmentPage(this.appointment, {super.key});

  Future<void> _remove() async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection("Patient")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("My appointments")
        .doc(appointment.id)
        .delete();

    // A cancelled appointment was already released by the doctor.
    if (!appointment.isCancelled) {
      await firestore
          .collection("Doctor")
          .doc(appointment.doctorId)
          .collection("My appointments")
          .doc(appointment.id)
          .delete();
    }
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final cancelled = appointment.isCancelled;
    final ok = await confirmDialog(
      context,
      title: cancelled ? "Delete appointment?" : "Cancel appointment?",
      message: cancelled
          ? "This removes it from your history."
          : "Your slot with ${appointment.doctorName} will be released.",
      confirmLabel: cancelled ? "Delete" : "Cancel appointment",
      destructive: true,
    );
    if (!ok) return;
    await _remove();
    if (context.mounted) Navigator.pop(context);
  }

  void _reschedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingsPage(
          address: appointment.address,
          doctorName: appointment.doctorName,
          doctorUid: appointment.doctorId,
          doctorSpecialty: appointment.consultation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canModify = appointment.isCancelled || appointment.isUpcoming;

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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.person_rounded,
                        color: scheme.primary, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appointment.doctorName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(appointment.consultation,
                            style: TextStyle(color: scheme.primary)),
                      ],
                    ),
                  ),
                  StatusChip(appointment.displayStatus),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                _detail(
                    Icons.calendar_today_outlined, "Date", appointment.date),
                const Divider(height: 1, indent: AppSpacing.md),
                _detail(Icons.access_time_rounded, "Time", appointment.time),
                const Divider(height: 1, indent: AppSpacing.md),
                _detail(Icons.location_on_outlined, "Location",
                    appointment.address),
              ],
            ),
          ),
          if (canModify) ...[
            const SizedBox(height: AppSpacing.lg),
            if (appointment.isCancelled) ...[
              FilledButton(
                onPressed: () => _reschedule(context),
                child: const Text("Reschedule"),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
            ],
            OutlinedButton(
              onPressed: () => _confirmRemove(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cancelled,
                side: const BorderSide(color: AppColors.cancelled),
              ),
              child: Text(appointment.isCancelled
                  ? "Delete appointment"
                  : "Cancel appointment"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}
