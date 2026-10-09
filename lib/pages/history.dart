import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matibabu/models/appointment.dart';
import 'package:matibabu/pages/appointment.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

enum HistoryFilter { all, completed, upcoming, cancelled }

extension on HistoryFilter {
  String get label {
    switch (this) {
      case HistoryFilter.all:
        return "All";
      case HistoryFilter.completed:
        return "Completed";
      case HistoryFilter.upcoming:
        return "Upcoming";
      case HistoryFilter.cancelled:
        return "Cancelled";
    }
  }

  bool matches(Appointment a) {
    switch (this) {
      case HistoryFilter.all:
        return true;
      case HistoryFilter.completed:
        return a.isCompleted;
      case HistoryFilter.upcoming:
        return a.isUpcoming;
      case HistoryFilter.cancelled:
        return a.isCancelled;
    }
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter _filter = HistoryFilter.all;

  late final Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
      .collection("Patient")
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection("My appointments")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: ErrorView());
          if (!snapshot.hasData) return const LoadingView();

          final all = Appointment.fromQuery(snapshot.data!);
          // Most recent first for a history view.
          final visible = all.where(_filter.matches).toList().reversed.toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                sliver: SliverToBoxAdapter(child: _SummaryRow(all)),
              ),
              SliverToBoxAdapter(child: _filterChips()),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _emptyState()),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                  sliver: SliverList.list(children: _groupedByMonth(visible)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          for (final f in HistoryFilter.values) ...[
            ChoiceChip(
              label: Text(f.label),
              selected: _filter == f,
              showCheckmark: false,
              onSelected: (_) => setState(() => _filter = f),
            ),
            if (f != HistoryFilter.values.last)
              const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    switch (_filter) {
      case HistoryFilter.all:
        return const EmptyState(
          icon: Icons.history_rounded,
          title: "No medical history yet",
          message: "Appointments you book will show up here.",
        );
      case HistoryFilter.completed:
        return const EmptyState(
          icon: Icons.check_circle_outline,
          title: "No completed visits",
          message: "Visits you've attended will show up here.",
        );
      case HistoryFilter.upcoming:
        return const EmptyState(
          icon: Icons.event_available_outlined,
          title: "No upcoming appointments",
          message: "Find a doctor to book your next visit.",
        );
      case HistoryFilter.cancelled:
        return const EmptyState(
          icon: Icons.event_busy_outlined,
          title: "No cancelled appointments",
        );
    }
  }

  List<Widget> _groupedByMonth(List<Appointment> items) {
    final widgets = <Widget>[];
    String? currentMonth;
    for (final a in items) {
      final dt = a.dateTime;
      final month = dt == null ? "Other" : DateFormat.yMMMM().format(dt);
      if (month != currentMonth) {
        currentMonth = month;
        widgets.add(Padding(
          padding: EdgeInsets.only(
            top: widgets.isEmpty ? 0 : AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ));
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
        child: AppointmentCard(
          a,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AppointmentPage(a)),
          ),
        ),
      ));
    }
    return widgets;
  }
}

class _SummaryRow extends StatelessWidget {
  final List<Appointment> appointments;
  const _SummaryRow(this.appointments);

  @override
  Widget build(BuildContext context) {
    final completed = appointments.where((a) => a.isCompleted).length;
    final upcoming = appointments.where((a) => a.isUpcoming).length;
    final cancelled = appointments.where((a) => a.isCancelled).length;

    return Row(
      children: [
        Expanded(
            child: _StatCard("Visits", completed, Icons.check_circle_outline,
                AppColors.completed)),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
            child: _StatCard(
                "Upcoming", upcoming, Icons.event_outlined, AppColors.seed)),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
            child: _StatCard("Cancelled", cancelled, Icons.event_busy_outlined,
                AppColors.cancelled)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text("$value",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
