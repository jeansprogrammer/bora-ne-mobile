import 'package:flutter/material.dart';
import 'models/category_model.dart';

class CategoryController {
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

  void navigateToCategory(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
