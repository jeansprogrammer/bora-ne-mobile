class CategoryModel {
  final String name;
  final List<String> synonyms;
  final String emoji;

  const CategoryModel({
    required this.name,
    required this.synonyms,
    required this.emoji,
  });

  /// Verifica se uma query bate com o nome ou qualquer sinônimo
  bool matches(String query) {
    final q = query.toLowerCase().trim();
    if (name.toLowerCase().contains(q)) return true;
    return synonyms.any((s) => s.toLowerCase().contains(q));
  }
}