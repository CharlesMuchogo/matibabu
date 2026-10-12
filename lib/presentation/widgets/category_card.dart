import 'package:flutter/material.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/presentation/pages/category_doctors_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool compact;

  const CategoryCard(this.category, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => CategoryDoctorsPage(category: category),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Avatar(category.photo, radius: compact ? 24 : 30),
              SizedBox(height: compact ? AppSpacing.sm : AppSpacing.sm + 4),
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 12 : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
