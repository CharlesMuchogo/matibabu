import 'package:flutter/material.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/presentation/pages/doctor_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class DoctorTile extends StatelessWidget {
  final User doctor;
  final bool navigates;

  const DoctorTile(this.doctor, {super.key, this.navigates = true});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: navigates
            ? () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => DoctorPage(doctor: doctor),
                ),
              )
            : null,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Avatar(doctor.profilePhoto, radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: scheme.primary),
                    ),
                  ],
                ),
              ),
              if (navigates)
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorList extends StatelessWidget {
  final List<User> doctors;
  final EdgeInsetsGeometry padding;

  const DoctorList(this.doctors, {super.key, this.padding = AppSpacing.page});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: doctors.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm + 4),
      itemBuilder: (_, i) => DoctorTile(doctors[i]),
    );
  }
}
