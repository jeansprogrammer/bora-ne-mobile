import 'package:boranemobile/models/destination_model.dart';

class RouteCreationModel {
  String name;
  List<String> categories;  // ← sempre List, nunca String
  String description;
  String imageUrl;
  String state;
  List<DestinationModel> destinations;
  List<String> favoritedBy; // ← adicionado

  RouteCreationModel({
    this.name = '',
    this.categories = const [],
    this.description = '',
    this.imageUrl = '',
    this.state = '',
    List<DestinationModel>? destinations,
    this.favoritedBy = const [],
  }) : destinations = destinations ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'categories': categories,   // salva como List
    'description': description,
    'imageUrl': imageUrl,
    'state': state,
    'destinations': destinations.map((p) => p.toMap()).toList(),
    'favoritedBy': favoritedBy,
  };

  factory RouteCreationModel.fromMap(Map<String, dynamic> map) {
    // Suporte a dados antigos onde categories era String
    final rawCats = map['categories'];
    final List<String> cats = rawCats == null
        ? []
        : rawCats is List
            ? List<String>.from(rawCats)
            : [rawCats.toString()];

    return RouteCreationModel(
      name: map['name'] ?? '',
      categories: cats,
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      state: map['state'] ?? '',
      favoritedBy: List<String>.from(map['favoritedBy'] ?? []),
      destinations: map['destinations'] != null
          ? (map['destinations'] as List)
              .map((p) => DestinationModel.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}