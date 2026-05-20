import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_creation_model.dart';

class RouteCreationController extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  RouteCreationModel newRoute = RouteCreationModel();
  bool isSaving = false;

  bool get canAddMorePlaces => newRoute.places.length < 10;
  bool get isValid => newRoute.name.isNotEmpty && 
                     newRoute.category.isNotEmpty && 
                     newRoute.places.isNotEmpty;

  void setName(String val) { newRoute.name = val; notifyListeners(); }
  void setCategory(String val) { newRoute.category = val; notifyListeners(); }
  void setDescription(String val) { newRoute.description = val; notifyListeners(); }
  
  void addPlace(String name, double lat, double lon) {
    if (canAddMorePlaces) {
      newRoute.places.add(PlaceModel(name: name, lat: lat, lon: lon));
      notifyListeners();
    }
  }

  void removePlace(int index) {
    newRoute.places.removeAt(index);
    notifyListeners();
  }

  // Simulação de busca - integre com seu Geoapify aqui
  Future<List<Map<String, dynamic>>> searchPlace(String query) async {
    return []; 
  }

  Future<bool> saveRoute() async {
    if (!isValid) return false;
    isSaving = true;
    notifyListeners();

    try {
      await _db.collection('rotas_criadas').add(newRoute.toMap());
      newRoute = RouteCreationModel(); // Limpa após sucesso
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}