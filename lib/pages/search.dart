import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/doctor_information.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _controller = TextEditingController();
  final Stream<QuerySnapshot> _doctors =
      FirebaseFirestore.instance.collection("Doctor").snapshots();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find a Doctor")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by name, specialty or hospital",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(_controller.clear),
                      ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _doctors,
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: ErrorView());
                if (!snapshot.hasData) return const LoadingView();

                final query = _controller.text.trim().toLowerCase();
                final results = snapshot.data!.docs
                    .where((d) =>
                        d.data().toString().toLowerCase().contains(query))
                    .toList();

                if (results.isEmpty) {
                  return const Center(
                    child: EmptyState(
                      icon: Icons.person_search_outlined,
                      title: "No doctors found",
                      message: "Try a different name or specialty.",
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm + 4),
                  itemBuilder: (_, i) => DoctorListTile(results[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
