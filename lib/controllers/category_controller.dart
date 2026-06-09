import 'package:flutter/material.dart';
import '../data/category_data.dart';
import '../models/category_model.dart';

class CategoryController extends ChangeNotifier {
  List<String> _selecionadas = [];
  String _filtro = '';

  // ── Getters ───────────────────────────────────────────────────────────────

  List<String> get selecionadas => List.unmodifiable(_selecionadas);

  List<CategoryModel> get todasCategorias => categoriasBoraNE;

  List<CategoryModel> get categoriasFiltradas =>
      _filtro.isEmpty ? categoriasBoraNE : buscarCategorias(_filtro);

  bool isSelecionada(String nome) => _selecionadas.contains(nome);

  // ── Seleção ───────────────────────────────────────────────────────────────

  void toggle(String nome) {
    if (_selecionadas.contains(nome)) {
      _selecionadas.remove(nome);
    } else {
      _selecionadas.add(nome);
    }
    notifyListeners();
  }

  void setSelecionadas(List<String> categorias) {
    _selecionadas = List.from(categorias);
    notifyListeners();
  }

  void limpar() {
    _selecionadas.clear();
    notifyListeners();
  }

  // ── Filtro de busca ───────────────────────────────────────────────────────

  void setFiltro(String query) {
    _filtro = query;
    notifyListeners();
  }

  // ── Busca expandida com sinônimos ─────────────────────────────────────────

  /// Retorna os termos expandidos para busca full-text
  List<String> expandirQuery(String query) =>
      expandirQueryComSinonimos(query);

  /// Verifica se um destino/rota pertence a uma categoria pelo nome ou sinônimo
  bool destinoPertenceACategoria(List<String> categoriaDestino, String filtro) {
    return categoriaDestino.any((cat) {
      final model = categoriasBoraNE
          .where((c) => c.name == cat)
          .firstOrNull;
      return model?.matches(filtro) ?? cat.toLowerCase().contains(filtro.toLowerCase());
    });
  }
}