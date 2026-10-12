import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:matibabu/domain/entities/appointment.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/appointment_card.dart';
import 'package:matibabu/presentation/widgets/common.dart';

enum HistoryFilter {
  all("All"),
  completed("Completed"),
  upcoming("Upcoming"),
  cancelled("Cancelled");

  final String label;

  const HistoryFilter(this.label);

  bool matches(Appointment a, DateTime now) => switch (this) {
    HistoryFilter.all => true,
    HistoryFilter.completed => a.isCompletedAt(now),
    HistoryFilter.upcoming => a.isUpcomingAt(now),
    HistoryFilter.cancelled => a.isCancelled,
  };

  EmptyState get emptyState => switch (this) {
    HistoryFilter.all => const EmptyState(
      icon: Icons.history_rounded,
      title: "No medical history yet",
      message: "Appointments you book will show up here.",
    ),
    HistoryFilter.completed => const EmptyState(
      icon: Icons.check_circle_outline,
      title: "No completed visits",
      message: "Visits you've attended will show up here.",
    ),
    HistoryFilter.upcoming => const EmptyState(
      icon: Icons.event_available_outlined,
      title: "No upcoming appointments",
      message: "Find a doctor to book your next visit.",
    ),
    HistoryFilter.cancelled => const EmptyState(
      icon: Icons.event_busy_outlined,
      title: "No cancelled appointments",
    ),
  };
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryFilter _filter = HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Medical History")),
      body: BlocBuilder<AppointmentsBloc, AppointmentsState>(
        builder: (context, state) {
          if (state.appointments.isEmpty && state.status.isFailure) {
            return Center(
              child: ErrorView(
                message: state.message,
                onRetry: () => context.read<AppointmentsBloc>().add(
                  const AppointmentsRequested(),
                ),
              ),
            );
          }
          if (state.appointments.isEmpty && state.status != Status.loaded) {
            return const LoadingView();
          }

          final now = DateTime.now();
          final visible = state.appointments.reversed
              .where((a) => _filter.matches(a, now))
              .toList();

          return RefreshIndicator(
            onRefresh: () async => context.read<AppointmentsBloc>().add(
              const AppointmentsRequested(),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _SummaryRow(state.appointments, now),
                  ),
                ),
                SliverToBoxAdapter(child: _filterChips()),
                if (visible.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: _filter.emptyState),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    sliver: SliverList.list(children: _groupedByMonth(visible)),
                  ),
              ],
            ),
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

  List<Widget> _groupedByMonth(List<Appointment> items) {
    final widgets = <Widget>[];
    String? currentMonth;
    for (final a in items) {
      final month = DateFormat.yMMMM().format(a.startsAt);
      if (month != currentMonth) {
        currentMonth = month;
        widgets.add(
          Padding(
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
          ),
        );
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
          child: AppointmentCard(a),
        ),
      );
    }
    return widgets;
  }
}

class _SummaryRow extends StatelessWidget {
  final List<Appointment> appointments;
  final DateTime now;

  const _SummaryRow(this.appointments, this.now);

  int _count(HistoryFilter filter) =>
      appointments.where((a) => filter.matches(a, now)).length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            "Visits",
            _count(HistoryFilter.completed),
            Icons.check_circle_outline,
            AppColors.completed,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: _StatCard(
            "Upcoming",
            _count(HistoryFilter.upcoming),
            Icons.event_outlined,
            AppColors.seed,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: _StatCard(
            "Cancelled",
            _count(HistoryFilter.cancelled),
            Icons.event_busy_outlined,
            AppColors.cancelled,
          ),
        ),
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
            Text(
              "$value",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
