import 'package:boranemobile/models/destination_model.dart';

class RouteCreationModel {
  String name;
  String categories;
  String description;
  String imageUrl;
  String state;
  List<DestinationModel> destinations;

  RouteCreationModel({
    this.name = '',
    this.categories = '',
    this.description = '',
    this.imageUrl = '',
    this.state = '',
    List<DestinationModel>? destinations,
  }) : destinations = destinations ?? [];

  Map<String, dynamic> toMap() => {
    'name': name,
    'categories': categories,
    'description': description,
    'imageUrl': imageUrl,
    'state': state,
    'destinations': destinations.map((p) => p.toMap()).toList(),
  };

  factory RouteCreationModel.fromMap(Map<String, dynamic> map) {
    return RouteCreationModel(
      name: map['name'] ?? '',
      categories: map['categories'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      state: map['state'] ?? '',
      destinations: map['destinations'] != null
          ? (map['destinations'] as List)
              .map((p) => DestinationModel.fromMap(p as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}