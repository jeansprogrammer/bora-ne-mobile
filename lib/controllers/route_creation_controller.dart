import 'package:flutter/material.dart';
import '../models/route_creation_model.dart';
import '../models/destination_model.dart';
import '../services/new_route_service.dart';
import '../services/destination_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RouteCreationController extends ChangeNotifier {
  final NewRouteService _routeService = NewRouteService();
  final DestinationService _DestinationService = DestinationService();

  RouteCreationModel newRoute = RouteCreationModel();

  // ── Estados ──────────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool _isSearching = false;

  // ── Fotos ─────────────────────────────────────────────────────────────────
  List<File> fotos = [];
  int indiceFotoCapa = 0;
  String urlFotoCapaManual = '';

  // ── Múltiplas categorias ──────────────────────────────────────────────────
  List<String> _categoriasSelecionadas = [];

  // ── Cidade ────────────────────────────────────────────────────────────────
  String _cidadeSelecionada = '';

  // ── Destinos selecionados (modelo completo) ───────────────────────────────
  List<DestinationModel> _DestinationsSelecionados = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isSaving => _isSaving;
  bool get isSearching => _isSearching;
  List<String> get categoriasSelecionadas => _categoriasSelecionadas;
  String get cidadeSelecionada => _cidadeSelecionada;
  List<DestinationModel> get DestinationsSelecionados => _DestinationsSelecionados;
  bool get canAddMorePlaces => _DestinationsSelecionados.length < 10;

  bool get isValid =>
      newRoute.name.isNotEmpty &&
      _categoriasSelecionadas.isNotEmpty &&
      _cidadeSelecionada.isNotEmpty &&
      _DestinationsSelecionados.length >= 3;

  final ImagePicker _picker = ImagePicker();

  // ── Fotos ─────────────────────────────────────────────────────────────────

  Future<void> selecionarFotos() async {
    final List<XFile> imagens = await _picker.pickMultiImage();
    if (imagens.isNotEmpty) {
      fotos.addAll(imagens.map((x) => File(x.path)));
      notifyListeners();
    }
  }

  void removerFoto(int index) {
    fotos.removeAt(index);
    if (indiceFotoCapa >= fotos.length) {
      indiceFotoCapa = fotos.isEmpty ? 0 : fotos.length - 1;
    }
    notifyListeners();
  }

  void definirFotoCapa(int index) {
    indiceFotoCapa = index;
    notifyListeners();
  }

  void setUrlFotoCapa(String url) {
    urlFotoCapaManual = url;
    notifyListeners();
  }

  // ── Busca de Destinos filtrada pela cidade selecionada ────────────────────

  Future<List<DestinationModel>> pesquisarDestinations(String query) async {
    if (query.isEmpty) return [];

    _isSearching = true;
    notifyListeners();

    final resultados = await _DestinationService.buscarDestinationsPorNomeECidade(
      query,
      _cidadeSelecionada,
    );

    _isSearching = false;
    notifyListeners();
    return resultados;
  }

  // ── Campos da rota ────────────────────────────────────────────────────────

  void setName(String val) {
    newRoute.name = val;
    notifyListeners();
  }

  void setDescription(String val) {
    newRoute.description = val;
    notifyListeners();
  }

  void toggleCategoria(String categoria) {
    if (_categoriasSelecionadas.contains(categoria)) {
      _categoriasSelecionadas.remove(categoria);
    } else {
      _categoriasSelecionadas.add(categoria);
    }
    notifyListeners();
  }

  void setCidade(String cidade) {
    _cidadeSelecionada = cidade;
    notifyListeners();
  }

  void addDestination(DestinationModel Destination) {
    if (!canAddMorePlaces) return;
    if (_DestinationsSelecionados.any((d) => d.name == Destination.name)) return;
    _DestinationsSelecionados.add(Destination);
    newRoute.places.add(PlaceModel(
      name: Destination.name,
      lat: Destination.latitude,
      lon: Destination.longitude,
    ));
    notifyListeners();
  }

  void removeDestination(int index) {
    _DestinationsSelecionados.removeAt(index);
    newRoute.places.removeAt(index);
    notifyListeners();
  }

  void reordenarDestination(int oldIndex, int newIndex) {
    final Destination = _DestinationsSelecionados.removeAt(oldIndex);
    _DestinationsSelecionados.insert(newIndex, Destination);
    final place = newRoute.places.removeAt(oldIndex);
    newRoute.places.insert(newIndex, place);
    notifyListeners();
  }

  // ── Salvar rota ───────────────────────────────────────────────────────────

  Future<bool> saveRoute() async {
    if (!isValid) return false;

    _isSaving = true;
    notifyListeners();

    try {
      // Foto capa: tenta upload se tiver arquivo, senão usa URL manual
      String urlCapa = '';
      if (fotos.isNotEmpty) {
        final urls = await _routeService.uploadImages(fotos);
        urlCapa = urls.isNotEmpty
            ? urls[indiceFotoCapa.clamp(0, urls.length - 1)]
            : urlFotoCapaManual;
      } else {
        urlCapa = urlFotoCapaManual;
      }

      final Map<String, dynamic> dadosParaSalvar = newRoute.toMap();
      dadosParaSalvar['fotoCapa'] = urlCapa;
      dadosParaSalvar['categorias'] = _categoriasSelecionadas;
      dadosParaSalvar['cidade'] = _cidadeSelecionada;

      final success = await _routeService.saveRouteToFirestore(dadosParaSalvar);

      if (success) {
        newRoute = RouteCreationModel();
        fotos = [];
        indiceFotoCapa = 0;
        urlFotoCapaManual = '';
        _categoriasSelecionadas = [];
        _cidadeSelecionada = '';
        _DestinationsSelecionados = [];
      }

      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      print("Erro ao salvar rota: $e");
      return false;
    }
  }

  // ── Reset público (ao confirmar saída) ────────────────────────────────────

  void resetar() {
    newRoute = RouteCreationModel();
    fotos = [];
    indiceFotoCapa = 0;
    urlFotoCapaManual = '';
    _categoriasSelecionadas = [];
    _cidadeSelecionada = '';
    _DestinationsSelecionados = [];
    notifyListeners();
  }
}