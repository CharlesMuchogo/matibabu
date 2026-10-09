import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctor_information.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class DoctorCategoriesExpanded extends StatelessWidget {
  final String category;

  const DoctorCategoriesExpanded({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Doctor").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: ErrorView());
          if (!snapshot.hasData) return const LoadingView();

          final doctors = snapshot.data!.docs
              .where((d) => d["specialty"]
                  .toString()
                  .toLowerCase()
                  .contains(category.toLowerCase()))
              .toList();

          if (doctors.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.person_search_outlined,
                title: "No doctors yet",
                message: "There are no $category specialists available.",
              ),
            );
          }

          return ListView.separated(
            padding: AppSpacing.page,
            itemCount: doctors.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm + 4),
            itemBuilder: (_, i) => DoctorListTile(doctors[i]),
          );
        },
      ),
    );
  }
}
