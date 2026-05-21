import 'package:flutter/material.dart';
import '../models/route_creation_model.dart';
import '../services/new_route_service.dart';
import '../services/destino_service.dart'; // Importação para a busca dinâmica
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RouteCreationController extends ChangeNotifier {
  // Instância dos Serviços
  final NewRouteService _routeService = NewRouteService();
  final DestinoService _destinoService = DestinoService();

  RouteCreationModel newRoute = RouteCreationModel();
  
  // Estados de Controle
  bool _isSaving = false;
  bool _isSearching = false; // Novo: controla o loading da busca
  List<File> _fotosSelecionadas = [];

  // Getters
  List<File> get fotosSelecionadas => _fotosSelecionadas;
  bool get isSaving => _isSaving;
  bool get isSearching => _isSearching;
  bool get canAddMorePlaces => newRoute.places.length < 10;
  bool get isValid =>
      newRoute.name.isNotEmpty &&
      newRoute.category.isNotEmpty &&
      newRoute.places.isNotEmpty;

  final ImagePicker _picker = ImagePicker();

  // --- LÓGICA DE BUSCA NO FIRESTORE ---

  Future<List<Map<String, dynamic>>> pesquisarLocais(String query) async {
    if (query.isEmpty) return [];
    
    _isSearching = true;
    notifyListeners();

    // Busca no Firestore via DestinoService
    final resultados = await _destinoService.buscarDestinosNoFirestore(query);
    
    _isSearching = false;
    notifyListeners();
    return resultados;
  }

  // --- LÓGICA DE SELEÇÃO DE IMAGENS ---

  Future<void> selecionarFotos() async {
    final List<XFile> imagens = await _picker.pickMultiImage();

    if (imagens.isNotEmpty) {
      _fotosSelecionadas.addAll(
        imagens.map((xfile) => File(xfile.path)).toList(),
      );
      notifyListeners();
    }
  }

  void removerFoto(int index) {
    _fotosSelecionadas.removeAt(index);
    notifyListeners();
  }

  // --- ATUALIZAÇÃO DOS CAMPOS DA ROTA ---

  void setName(String val) {
    newRoute.name = val;
    notifyListeners();
  }

  void setCategory(String val) {
    newRoute.category = val;
    notifyListeners();
  }

  void setDescription(String val) {
    newRoute.description = val;
    notifyListeners();
  }

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

  // --- LÓGICA DE SALVAMENTO (STORAGE + FIRESTORE) ---

  Future<bool> saveRoute() async {
    if (!isValid) return false;

    _isSaving = true;
    notifyListeners();

    try {
      // 1. Upload das fotos para o Firebase Storage
      List<String> urlsDasFotos = [];
      if (_fotosSelecionadas.isNotEmpty) {
        urlsDasFotos = await _routeService.uploadImages(_fotosSelecionadas);
      }

      // 2. Prepara os dados incluindo os links das imagens
      final Map<String, dynamic> dadosParaSalvar = newRoute.toMap();
      dadosParaSalvar['fotos'] = urlsDasFotos; 

      // 3. Salva o documento no Firestore
      final success = await _routeService.saveRouteToFirestore(dadosParaSalvar);

      if (success) {
        // Reseta o estado do formulário após sucesso
        newRoute = RouteCreationModel(); 
        _fotosSelecionadas = [];
      }

      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      print("Erro no RouteCreationController ao salvar: $e");
      return false;
    }
  }
}