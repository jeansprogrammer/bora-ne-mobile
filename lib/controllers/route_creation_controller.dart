import 'package:flutter/material.dart';
import '../../models/route_creation_model.dart';
import '../../services/geoapify_service.dart';

class RouteCreationController extends ChangeNotifier {
  final GeoapifyService geoapify = GeoapifyService();

  RouteCreationModel newRoute = RouteCreationModel();

  bool get canAddMorePlaces => newRoute.places.length < 10;

  void setName(String value) {
    newRoute.name = value;
    notifyListeners();
  }

  void setCategory(String value) {
    newRoute.category = value;
    notifyListeners();
  }

  void setDescription(String value) {
    newRoute.description = value;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> searchPlace(String query) {
    return geoapify.searchPlaces(query);
  }

  void addPlace(PlaceModel place) {
    if (canAddMorePlaces) {
      newRoute.places.add(place);
      notifyListeners();
    }
  }

  void removePlace(int index) {
    newRoute.places.removeAt(index);
    notifyListeners();
  }

  void saveRoute() {
    // Aqui você conecta com Firebase ou seu backend depois
    debugPrint("ROTA SALVA:");
    debugPrint(newRoute.name);
    debugPrint(newRoute.category);
    debugPrint(newRoute.description);
    debugPrint("Locais: ${newRoute.places.length}");
  }
}
