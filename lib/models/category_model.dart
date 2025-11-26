class CategoryModel {
  final String title;
  final String image;
  final String route; // ← ADICIONAR ESTE CAMPO

  CategoryModel({
    required this.title,
    required this.image,
    required this.route, // ← ADICIONAR NO CONSTRUTOR
  });
}
