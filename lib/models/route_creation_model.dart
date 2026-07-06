import 'package:boranemobile/models/destination_model.dart';

class RouteCreationModel {
  String? id;
  String name;
  List<String> categories;
  String description;
  List<String> photos;
  String state;
  String city;
  String coverPhoto;
  List<DestinationModel> destinations;
  List<String> favoritedBy;
  // UID do usuário que criou a rota (só ele pode editar)
  String createdBy;

  RouteCreationModel({
    this.id,
    this.name = '',
    this.categories = const [],
    this.description = '',
    this.photos = const [],
    this.state = '',
    this.city = '',
    this.coverPhoto = '',
    List<DestinationModel>? destinations,
    this.favoritedBy = const [],
    this.createdBy = '',
  }) : destinations = destinations ?? [];

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'categories': categories,
    'description': description,
    'photos': photos,
    'state': state,
    'city': city,
    'coverPhoto': coverPhoto,
    'destinations': destinations.map((p) => p.toMap()).toList(),
    'favoritedBy': favoritedBy,
    'createdBy': createdBy,
  };

  factory RouteCreationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawCats = map['categories'];
    final List<String> cats = rawCats == null
        ? []
        : rawCats is List
            ? List<String>.from(rawCats)
            : [rawCats.toString()];

    // Suporte a dados antigos onde photos era String
    final rawPhotos = map['photos'];
    final List<String> photos = rawPhotos == null
        ? []
        : rawPhotos is List
            ? List<String>.from(rawPhotos)
            : rawPhotos.toString().isNotEmpty
                ? [rawPhotos.toString()]
                : [];

    return RouteCreationModel(
      id: id ?? map['id'],
      name: map['name'] ?? '',
      categories: cats,
      description: map['description'] ?? '',
      photos: photos,
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      coverPhoto: map['coverPhoto'] ?? '',
      favoritedBy: List<String>.from(map['favoritedBy'] ?? []),
      createdBy: map['createdBy'] ?? '',
      destinations: map['destinations'] != null
          ? (map['destinations'] as List)
              .map((p) => DestinationModel.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}