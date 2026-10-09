import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctorcategoriesexpanded.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class DoctorCartegories extends StatelessWidget {
  const DoctorCartegories({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Categories")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Doctor Categoty")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: ErrorView());
          if (!snapshot.hasData) return const LoadingView();

          final docs = snapshot.data!.docs;
          return GridView.builder(
            padding: AppSpacing.page,
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm + 4,
              crossAxisSpacing: AppSpacing.sm + 4,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) => Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DoctorCategoriesExpanded(category: docs[index].id),
                  ),
                ),
                child: Padding(
                  padding: AppSpacing.card,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Avatar(docs[index]["DisplayPhoto"], radius: 30),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Text(
                        docs[index].id,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
