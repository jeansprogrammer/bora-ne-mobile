import 'package:flutter/material.dart';
import 'package:boranemobile/models/category_model.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              category.image,
              height: 90,
              fit: BoxFit.fill,
            ),
          ),

          const SizedBox(width: 16),

          // Título
          Expanded(
            child: Text(
              category.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
