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

  List<DestinationModel> get destinosFavoritos => _favorites?.destinos ?? [];
  List<RouteCreationModel> get rotasFavoritas => _favorites?.rotas ?? []; 


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
      destinos: [],
      rotas: [],
      dataCriacao: DateTime.now(),
    );
    await _service.salvarFavoritos(novoRegistro);
    _favorites = novoRegistro;
  }

  bool isDestinoFavorito(String destinoId) {
    return destinosFavoritos.any((d) => d.id == destinoId);
  }

  Future<void> toggleDestinoFavorito(String userId, DestinationModel destino) async {
    if (_favorites == null || destino.id == null) return;

    final existe = isDestinoFavorito(destino.id!);

    try {
      if (existe) {
        // Remove do banco e da lista local
        await _service.desfavoritarDestino(userId, destino);
        _favorites!.destinos.removeWhere((d) => d.id == destino.id);
      } else {
        // Adiciona no banco e na lista local
        await _service.favoritarDestino(userId, destino);
        _favorites!.destinos.add(destino);
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
        // Encontra a rota exata guardada localmente para garantir a consistência do DateTime no array do Firebase
        final rotaParaRemover = _favorites!.rotas.firstWhere((r) => r.name == rota.name);
        await _service.desfavoritarRota(userId, rotaParaRemover);
        _favorites!.rotas.removeWhere((r) => r.name == rota.name);
      } else {
        // Se a rota ainda não tem data de criação definida, atribui agora antes de salvar
        await _service.favoritarRota(userId, rota);
        _favorites!.rotas.add(rota);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao alternar favorito da rota: $e");
    }
  }
}