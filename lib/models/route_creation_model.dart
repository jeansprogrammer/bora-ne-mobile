import 'package:latlong2/latlong.dart';

class RouteCreationModel {
  String name;
  String category;
  String description;
  List<String> photos;
  List<PlaceModel> places;

  RouteCreationModel({
    this.name = "",
    this.category = "",
    this.description = "",
    this.photos = const [],
    this.places = const [],
  });
}

class PlaceModel {
  String name;
  LatLng position;

  PlaceModel({
    required this.name,
    required this.position,
  });
}
