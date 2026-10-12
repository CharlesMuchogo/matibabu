import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/doctor_repository.dart';
import 'package:matibabu/presentation/bloc/doctors/doctors_bloc.dart';
import 'package:matibabu/presentation/widgets/doctors_view.dart';

class CategoryDoctorsPage extends StatelessWidget {
  final Category category;

  const CategoryDoctorsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorsBloc(
        repository: context.read<DoctorRepository>(),
        storageId: 'category-${category.id}',
        categoryId: category.id,
      )..add(const DoctorsRequested()),
      child: Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: DoctorsView(
          emptyTitle: "No doctors yet",
          emptyMessage: "There are no ${category.name} specialists available.",
        ),
      ),
    );
  }
}
