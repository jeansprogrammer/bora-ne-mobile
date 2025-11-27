import 'package:flutter/material.dart';
import 'package:boranemobile/models/category_model.dart';
import 'package:boranemobile/view/widgets/category_item.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});

  final List<CategoryModel> categories = [
    CategoryModel(
      title: "Religioso",
      image: "assets/images/bible.png",
      route: "/religioso",
    ),
    CategoryModel(
      title: "Gastronômico",
      image: "assets/images/burger.png",
      route: "/gastronomico",
    ),
    CategoryModel(
      title: "Histórico",
      image: "assets/images/hieroglyph.png",
      route: "/historico",
    ),
    CategoryModel(
      title: "Aventuras",
      image: "assets/images/tent.png",
      route: "/aventuras",
    ),
    CategoryModel(
      title: "Outros",
      image: "assets/images/searching.png",
      route: "/outros",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 253, 245, 1),

      appBar: AppBar(
        title: const Text(
          "Categorias",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryItem(category: categories[index]);
          },
        ),
      ),
    );
  }
}
