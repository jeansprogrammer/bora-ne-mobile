import 'package:flutter/material.dart';
import '../models/route_creation_model.dart';
import '../models/destino_model.dart';
import '../services/new_route_service.dart';
import '../services/destino_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RouteCreationController extends ChangeNotifier {
  final NewRouteService _routeService = NewRouteService();
  final DestinoService _destinoService = DestinoService();

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
  List<DestinoModel> _destinosSelecionados = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isSaving => _isSaving;
  bool get isSearching => _isSearching;
  List<String> get categoriasSelecionadas => _categoriasSelecionadas;
  String get cidadeSelecionada => _cidadeSelecionada;
  List<DestinoModel> get destinosSelecionados => _destinosSelecionados;
  bool get canAddMorePlaces => _destinosSelecionados.length < 10;

  bool get isValid =>
      newRoute.name.isNotEmpty &&
      _categoriasSelecionadas.isNotEmpty &&
      _destinosSelecionados.isNotEmpty;

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

  // ── Busca de destinos — Firestore ─────────────────────────────────────────

  Future<List<DestinoModel>> pesquisarDestinos(String query) async {
    if (query.isEmpty) return [];

    _isSearching = true;
    notifyListeners();

    final resultados = await _destinoService.buscarDestinosPorNome(query);

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

  void addDestino(DestinoModel destino) {
    if (!canAddMorePlaces) return;
    if (_destinosSelecionados.any((d) => d.nome == destino.nome)) return;
    _destinosSelecionados.add(destino);
    newRoute.places.add(PlaceModel(
      name: destino.nome,
      lat: destino.latitude,
      lon: destino.longitude,
    ));
    notifyListeners();
  }

  void removeDestino(int index) {
    _destinosSelecionados.removeAt(index);
    newRoute.places.removeAt(index);
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
        _destinosSelecionados = [];
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
}