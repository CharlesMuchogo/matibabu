import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/doctors/doctors_bloc.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/doctors_view.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorsBloc(
        repository: context.read<DoctorRepository>(),
        storageId: 'search',
      )..add(const DoctorsRequested()),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  late final _controller = TextEditingController(
    text: context.read<DoctorsBloc>().state.query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {});
    context.read<DoctorsBloc>().add(DoctorsQueryChanged(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find a Doctor")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _controller,
              onChanged: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search by name, specialty or hospital",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          _search('');
                        },
                      ),
              ),
            ),
          ),
          const Expanded(
            child: DoctorsView(
              emptyTitle: "No doctors found",
              emptyMessage: "Try a different name or specialty.",
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.lg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
