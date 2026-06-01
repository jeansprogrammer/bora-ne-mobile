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
  String categories;
  String description;
  String imageUrl;
  List<PlaceModel> destinations;

  RouteCreationModel({
    this.name = '',
    this.categories = '',
    this.description = '',
    this.imageUrl = '',
    List<PlaceModel>? destinations,
  }) : destinations = destinations ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'categories': categories,
    'description': description,
    'imageUrl': imageUrl,
    'destinations': destinations.map((p) => p.toMap()).toList(),
  };

  factory RouteCreationModel.fromMap(Map<String, dynamic> map) {
    return RouteCreationModel(
      name: map['name'] ?? '',
      categories: map['categories'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Mapeia a lista interna de PlaceModel
      destinations: map['destinations'] != null
          ? (map['destinations'] as List)
              .map((p) => PlaceModel.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}