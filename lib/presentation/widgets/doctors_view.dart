import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/doctors/doctors_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';
import 'package:matibabu/presentation/widgets/doctor_tile.dart';

class DoctorsView extends StatelessWidget {
  final String emptyTitle;
  final String emptyMessage;
  final EdgeInsetsGeometry padding;

  const DoctorsView({
    super.key,
    required this.emptyTitle,
    required this.emptyMessage,
    this.padding = AppSpacing.page,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorsBloc, DoctorsState>(
      builder: (context, state) {
        if (state.doctors.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DoctorsBloc>().add(const DoctorsRequested()),
            child: DoctorList(state.doctors, padding: padding),
          );
        }
        return switch (state.status) {
          Status.failure => Center(
            child: ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<DoctorsBloc>().add(const DoctorsRequested()),
            ),
          ),
          Status.loaded => Center(
            child: EmptyState(
              icon: Icons.person_search_outlined,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ),
          _ => const LoadingView(),
        };
      },
    );
  }
}
