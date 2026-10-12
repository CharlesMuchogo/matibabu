import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/categories/categories_bloc.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/category_card.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Categories")),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state.categories.isEmpty) {
            return state.status.isFailure
                ? Center(
                    child: ErrorView(
                      message: state.message,
                      onRetry: () => context.read<CategoriesBloc>().add(
                        const CategoriesRequested(),
                      ),
                    ),
                  )
                : const LoadingView();
          }
          return GridView.builder(
            padding: AppSpacing.page,
            itemCount: state.categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm + 4,
              crossAxisSpacing: AppSpacing.sm + 4,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) =>
                CategoryCard(state.categories[index]),
          );
        },
      ),
    );
  }
}
