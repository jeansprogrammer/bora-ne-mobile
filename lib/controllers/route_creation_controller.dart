import 'package:flutter/material.dart';
import '../models/route_creation_model.dart';
import '../models/destination_model.dart';
import '../services/new_route_service.dart';
import '../services/destination_service.dart';
import '../services/image_upload_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RouteCreationController extends ChangeNotifier {
  final NewRouteService _routeService = NewRouteService();
  final DestinationService _DestinationService = DestinationService();
  final ImageUploadService _imageService = ImageUploadService();

  
  List<Map<String, dynamic>> _rotas = [];

  List<Map<String, dynamic>> get rotas => _rotas;

  RouteCreationModel newRoute = RouteCreationModel();

  // ── Estados ──────────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool _isSearching = false;

  // ── Fotos ─────────────────────────────────────────────────────────────────
  List<File> fotos = [];
  int indiceFotoCapa = 0;
  String urlFotoCapaManual = '';

  // ── Modo edição ─────────────────────────────────────────────────────────────
  // Quando != null, estamos editando uma rota existente (id do documento Firestore).
  String? editingRouteId;
  // Fotos que JÁ estavam salvas na rota (URLs). Preservadas ao editar.
  List<String> _urlsFotosExistentes = [];
  // Lista de favoritos já existente — preservada para não zerar ao editar.
  List<String> _favoritedByExistente = [];

  bool get isEditing => editingRouteId != null;
  List<String> get urlsFotosExistentes => _urlsFotosExistentes;

  // ── Múltiplas categorias ──────────────────────────────────────────────────
  List<String> _categoriasSelecionadas = [];

  // ── Cidade + UF ───────────────────────────────────────────────────────────
  String _cidadeSelecionada = '';
  String _ufSelecionado = '';

  // ── Destinos selecionados (modelo completo) ───────────────────────────────
  List<DestinationModel> _DestinationsSelecionados = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isSaving => _isSaving;
  bool get isSearching => _isSearching;
  List<String> get categoriasSelecionadas => _categoriasSelecionadas;
  String get cidadeSelecionada => _cidadeSelecionada;
  String get ufSelecionado => _ufSelecionado;
  List<DestinationModel> get DestinationsSelecionados => _DestinationsSelecionados;
  bool get canAddMorePlaces => _DestinationsSelecionados.length < 10;

  bool get isValid =>
      newRoute.name.isNotEmpty &&
      _categoriasSelecionadas.isNotEmpty &&
      _cidadeSelecionada.isNotEmpty &&
      _ufSelecionado.isNotEmpty &&
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

  // ── Carregar rota existente para EDIÇÃO ───────────────────────────────────
  // Recebe o Map vindo da route_detail (já contém o 'id' do documento Firestore)
  // e pré-preenche todos os campos do formulário.
  void carregarParaEdicao(Map<String, dynamic> rota) {
    // Identificador do documento — essencial para o update/delete
    editingRouteId = rota['id']?.toString();

    // Campos de texto
    newRoute = RouteCreationModel.fromMap(rota, id: editingRouteId);
    newRoute.name = rota['name'] ?? '';
    newRoute.description = rota['description'] ?? '';

    // Categorias
    final rawCats = rota['categories'];
    _categoriasSelecionadas = rawCats == null
        ? []
        : rawCats is List
            ? List<String>.from(rawCats)
            : [rawCats.toString()];

    // Cidade / UF (setados diretamente para NÃO disparar a limpeza de destinos)
    _cidadeSelecionada = rota['city'] ?? '';
    _ufSelecionado = rota['state'] ?? '';

    // Destinos já existentes na rota
    final rawDest = rota['destinations'];
    final List<DestinationModel> destinos = rawDest is List
        ? rawDest
            .map((d) => DestinationModel.fromMap(
                  Map<String, dynamic>.from(d as Map),
                ))
            .toList()
        : <DestinationModel>[];
    _DestinationsSelecionados = List<DestinationModel>.from(destinos);
    newRoute.destinations = List<DestinationModel>.from(destinos);

    // Fotos já salvas (URLs) — preservadas
    final rawPhotos = rota['photos'];
    _urlsFotosExistentes = rawPhotos == null
        ? []
        : rawPhotos is List
            ? List<String>.from(rawPhotos)
            : (rawPhotos.toString().isNotEmpty ? [rawPhotos.toString()] : []);

    // Foto de capa atual (mostrada como preview via URL)
    urlFotoCapaManual = rota['coverPhoto'] ?? '';

    // Favoritos atuais — preservados ao salvar
    _favoritedByExistente = List<String>.from(rota['favoritedBy'] ?? []);

    // Limpa seleção de fotos NOVAS (locais)
    fotos = [];
    indiceFotoCapa = 0;

    notifyListeners();
  }

  // Remove uma foto que já estava salva (apenas da lista local; só persiste ao salvar)
  void removerFotoExistente(int index) {
    if (index < 0 || index >= _urlsFotosExistentes.length) return;
    final removida = _urlsFotosExistentes.removeAt(index);
    // Se a removida era a capa, escolhe outra capa válida
    if (urlFotoCapaManual == removida) {
      urlFotoCapaManual =
          _urlsFotosExistentes.isNotEmpty ? _urlsFotosExistentes.first : '';
    }
    notifyListeners();
  }

  Future<void> carregarRotas() async {
    _isSearching = true;
    notifyListeners();

    try {
      _rotas = await _routeService.getAllRoutes();
    } catch (e) {
      debugPrint('Erro ao carregar rotas: $e');
    }

    _isSearching = false;
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

  void setCidade(String city) {
    _cidadeSelecionada = city;
    // Limpa destinos ao trocar cidade
    _DestinationsSelecionados = [];
    newRoute.destinations = [];
    notifyListeners();
  }

  void setUf(String uf) {
    _ufSelecionado = uf;
    // Reseta cidade e destinos ao trocar estado
    _cidadeSelecionada = '';
    _DestinationsSelecionados = [];
    newRoute.destinations = [];
    notifyListeners();
  }

  void addDestination(DestinationModel Destination) {
    if (!canAddMorePlaces) return;
    if (_DestinationsSelecionados.any((d) => d.name == Destination.name)) return;
    _DestinationsSelecionados.add(Destination);
    newRoute.destinations.add(DestinationModel(
      id: Destination.id, // ← preserva o id do documento para permitir edição depois
      name: Destination.name,
      description: Destination.description,
      photos: Destination.photos,
      coverPhoto: Destination.coverPhoto,
      categories: Destination.categories,
      street: Destination.street,
      number: Destination.number,
      neighborhood: Destination.neighborhood,
      cep: Destination.cep,
      city: Destination.city, 
      state: Destination.state,
      latitude: Destination.latitude,
      longitude: Destination.longitude,
      favoritedBy: Destination.favoritedBy,
    ));
    notifyListeners();
  }

  void removeDestination(int index) {
    _DestinationsSelecionados.removeAt(index);
    newRoute.destinations.removeAt(index);
    notifyListeners();
  }

  void reordenarDestination(int oldIndex, int newIndex) {
    final Destination = _DestinationsSelecionados.removeAt(oldIndex);
    _DestinationsSelecionados.insert(newIndex, Destination);
    final place = newRoute.destinations.removeAt(oldIndex);
    newRoute.destinations.insert(newIndex, place);
    notifyListeners();
  }

  // ── Salvar rota ───────────────────────────────────────────────────────────

  Future<bool> saveRoute() async {
    if (!isValid) return false;

    _isSaving = true;
    notifyListeners();

    try {
      // ── Monta a lista final de fotos ──────────────────────────────────────
      // Começa com as fotos que já estavam salvas (modo edição; vazio no modo criação).
      List<String> urlsFotos = List<String>.from(_urlsFotosExistentes);
      // Capa atual (URL). No modo criação pode ser uma URL manual; no modo edição
      // é a capa já existente.
      String urlCapa = urlFotoCapaManual;

      // Faz upload das NOVAS fotos locais selecionadas pelo usuário (se houver)
      if (fotos.isNotEmpty) {
        final novasUrls = await _imageService.uploadImagens(fotos);
        if (novasUrls.isNotEmpty) {
          // A capa escolhida no grid refere-se às fotos novas
          urlCapa = novasUrls[indiceFotoCapa.clamp(0, novasUrls.length - 1)];
        }
        urlsFotos.addAll(novasUrls);
      }

      // Garante que a capa esteja presente na lista de fotos
      if (urlCapa.isNotEmpty && !urlsFotos.contains(urlCapa)) {
        urlsFotos.insert(0, urlCapa);
      }
      // Se ainda não há capa definida mas há fotos, usa a primeira
      if (urlCapa.isEmpty && urlsFotos.isNotEmpty) {
        urlCapa = urlsFotos.first;
      }

      // ── Monta o payload ───────────────────────────────────────────────────
      final Map<String, dynamic> dadosParaSalvar = newRoute.toMap();
      dadosParaSalvar['photos'] = urlsFotos;
      dadosParaSalvar['coverPhoto'] = urlCapa;
      dadosParaSalvar['categories'] = _categoriasSelecionadas;
      dadosParaSalvar['city'] = _cidadeSelecionada;
      dadosParaSalvar['state'] = _ufSelecionado;
      // Preserva favoritos no modo edição; zera apenas na criação
      dadosParaSalvar['favoritedBy'] =
          isEditing ? _favoritedByExistente : <String>[];

      // ── Cria ou atualiza no Firestore ─────────────────────────────────────
      final bool success;
      if (isEditing) {
        success = await _routeService.updateRouteInFirestore(
          editingRouteId!,
          dadosParaSalvar,
        );
      } else {
        success = await _routeService.saveRouteToFirestore(dadosParaSalvar);
      }

      if (success) {
        resetar();
        await carregarRotas();
      }

      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      debugPrint("Erro ao salvar rota: $e");
      return false;
    }
  }

  // ── Excluir rota (apenas no modo edição) ──────────────────────────────────
  Future<bool> deleteRoute() async {
    if (editingRouteId == null) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final success =
          await _routeService.deleteRouteFromFirestore(editingRouteId!);
      if (success) {
        resetar();
        await carregarRotas();
      }
      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      print("Erro ao excluir rota: $e");
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
    _ufSelecionado = '';
    _DestinationsSelecionados = [];
    // Limpa o estado de edição
    editingRouteId = null;
    _urlsFotosExistentes = [];
    _favoritedByExistente = [];
    notifyListeners();
  }
}