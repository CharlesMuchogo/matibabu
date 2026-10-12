import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/appointments/appointments_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/categories/categories_bloc.dart';
import 'package:matibabu/presentation/bloc/doctors/doctors_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/pages/categories_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/appointment_card.dart';
import 'package:matibabu/presentation/widgets/category_card.dart';
import 'package:matibabu/presentation/widgets/common.dart';
import 'package:matibabu/presentation/widgets/doctor_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorsBloc(
        repository: context.read<DoctorRepository>(),
        storageId: 'top',
      )..add(const DoctorsRequested()),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<AppointmentsBloc>().add(const AppointmentsRequested());
            context.read<CategoriesBloc>().add(const CategoriesRequested());
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _Header(),
              const SectionHeader("Upcoming appointments"),
              const _UpcomingAppointments(),
              SectionHeader(
                "Doctor categories",
                actionLabel: "See all",
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const CategoriesPage(),
                  ),
                ),
              ),
              const _Categories(),
              const SectionHeader("Top rated specialists"),
              const _TopDoctors(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF008080), Color(0xFF0FA3A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSpacing.radius * 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user?.firstName ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "How are you feeling today?",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Avatar(user?.profilePhoto, radius: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingAppointments extends StatelessWidget {
  const _UpcomingAppointments();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsBloc, AppointmentsState>(
      builder: (context, state) {
        if (state.status == Status.loading) {
          return const LoadingView(height: 140);
        }
        if (state.status.isFailure && state.appointments.isEmpty) {
          return ErrorView(
            message: state.message,
            onRetry: () => context.read<AppointmentsBloc>().add(
              const AppointmentsRequested(),
            ),
          );
        }

        final upcoming = state.upcomingAt(DateTime.now());
        if (upcoming.isEmpty) {
          return Padding(
            padding: AppSpacing.pageHorizontal,
            child: Card(
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Text(
                        "No upcoming appointments. Book a specialist below.",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 152,
          child: ListView.separated(
            padding: AppSpacing.pageHorizontal,
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.sm + 4),
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.82,
              child: AppointmentCard(upcoming[index]),
            ),
          ),
        );
      },
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return state.status.isFailure
              ? ErrorView(
                  message: state.message,
                  onRetry: () => context.read<CategoriesBloc>().add(
                    const CategoriesRequested(),
                  ),
                )
              : const LoadingView(height: 112);
        }
        return SizedBox(
          height: 112,
          child: ListView.separated(
            padding: AppSpacing.pageHorizontal,
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: AppSpacing.sm + 4),
            itemBuilder: (context, index) => SizedBox(
              width: 96,
              child: CategoryCard(state.categories[index], compact: true),
            ),
          ),
        );
      },
    );
  }
}

class _TopDoctors extends StatelessWidget {
  const _TopDoctors();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsBloc, DoctorsState>(
      builder: (context, state) {
        if (state.doctors.isEmpty) {
          return switch (state.status) {
            Status.failure => ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<DoctorsBloc>().add(const DoctorsRequested()),
            ),
            Status.loaded => const EmptyState(
              icon: Icons.person_search_outlined,
              title: "No doctors yet",
            ),
            _ => const LoadingView(height: 120),
          };
        }
        return Padding(
          padding: AppSpacing.pageHorizontal,
          child: Column(
            children: [
              for (final doctor in state.doctors.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
                  child: DoctorTile(doctor),
                ),
            ],
          ),
        );
      },
    );
  }
}
