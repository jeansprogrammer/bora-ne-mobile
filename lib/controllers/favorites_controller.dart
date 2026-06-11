import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/models/favorites_model.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:boranemobile/services/favorites_service.dart';
import 'package:flutter/material.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesService _service = FavoritesService();

  FavoritesModel? _favorites;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para expor as variáveis de forma segura para a View
  FavoritesModel? get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DestinationModel> get destinosFavoritos => _favorites?.destinations ?? [];
  List<RouteCreationModel> get rotasFavoritas => _favorites?.routes ?? []; 

  void forceNotifyListeners() {
    notifyListeners();
  }

  Future<void> fetchFavorites(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _service.obterFavoritos(userId);
      
      // Se for a primeira vez do usuário no app e ele não tiver o doc de favoritos
      if (_favorites == null) {
        await _inicializarNovoUsuario(userId);
      }
    } catch (e) {
      _errorMessage = "Erro ao carregar favoritos: $e";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria a estrutura inicial de favoritos no banco caso ela não exista
  Future<void> _inicializarNovoUsuario(String userId) async {
    final novoRegistro = FavoritesModel(
      userId: userId,
      destinations: [],
      routes: [],
      createdat: DateTime.now(),
    );
    await _service.salvarFavoritos(novoRegistro);
    _favorites = novoRegistro;
  }

  bool isDestinoFavorito(String destinoId, {String? nome}) {
    return destinosFavoritos.any((d) =>
      (destinoId.isNotEmpty && d.id == destinoId) ||
      (nome != null && nome.isNotEmpty && d.name == nome)
    );
  }

  Future<void> toggleDestinoFavorito(String userId, DestinationModel destino) async {
    if (_favorites == null || destino.id == null) return;

    final existe = isDestinoFavorito(destino.id!);

    try {
      if (existe) {
        // Remove do banco e da lista local
        await _service.desfavoritarDestino(userId, destino.id!);
        _favorites!.destinations.removeWhere((d) =>
          (destino.id != null && destino.id!.isNotEmpty && d.id == destino.id) ||
          (destino.name.isNotEmpty && d.name == destino.name)
        );
      } else {
        // Adiciona no banco e na lista local
        await _service.favoritarDestino(userId, destino);
        _favorites!.destinations.add(destino);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao alternar favorito do destino: $e");
    }
  }

  bool isRotaFavorita(String rotaNome) {
    return rotasFavoritas.any((r) => r.name == rotaNome);
  }

  /// Liga/Desliga o favorito de uma rota no banco e atualiza o estado local
  Future<void> toggleRotaFavorito(String userId, RouteCreationModel rota) async {
    if (_favorites == null) return;

    final existe = isRotaFavorita(rota.name);

    try {
      if (existe) {
        // Encontra a rota exata guardada localmente para garantir a consistência no array do Firebase
        final rotaParaRemover = _favorites!.routes.firstWhere((r) => r.name == rota.name);
        await _service.desfavoritarRota(userId, rotaParaRemover.name);
        _favorites!.routes.removeWhere((r) => r.name == rota.name);
      } else {
        await _service.favoritarRota(userId, rota);
        _favorites!.routes.add(rota);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao alternar favorito da rota: $e");
    }
  }
}