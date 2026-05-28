class PlaceModel {
  final String name;
  final double lat;
  final double lon;

  PlaceModel({required this.name, required this.lat, required this.lon});

  Map<String, dynamic> toMap() => {
    'name': name,
    'lat': lat,
    'lon': lon,
  };

  factory PlaceModel.fromMap(Map<String, dynamic> map) => PlaceModel(
    name: map['name'],
    lat: map['lat'],
    lon: map['lon'],
  );
}

class RouteCreationModel {
  String name;
  String category;
  String description;
  String imageUrl;
  List<PlaceModel> places;

  RouteCreationModel({
    this.name = '',
    this.category = '',
    this.description = '',
    this.imageUrl = '',
    List<PlaceModel>? places,
  }) : places = places ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'description': description,
    'imageUrl': imageUrl,
    'places': places.map((p) => p.toMap()).toList(),
    'createdAt': DateTime.now(),
  };

  factory RouteCreationModel.fromMap(Map<String, dynamic> map) {
    return RouteCreationModel(
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Mapeia a lista interna de PlaceModel
      places: map['places'] != null
          ? (map['places'] as List)
              .map((p) => PlaceModel.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}