import 'package:aroundu/designs/widgets/chip.widgets.designs.dart';
import 'package:aroundu/models/category.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key, required this.categories, this.onTap});

  final List<CategoryModel> categories;
  final Function(CategoryModel category)? onTap;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 12,
      children: List.generate(
        categories.length,
        (index) {
          final category = categories[index];

          return DesignChip(
            title: "${category.iconUrl} ${category.name}",
            isSelected: false,
            onTap: () => onTap?.call(category),
          );
        },
      ),
    );
  }
}
