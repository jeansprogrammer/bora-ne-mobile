import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import '../data/category_data.dart';

class SearchFilter {
  bool soDestinos;
  bool soRotas;
  String? cidadeFiltro;
  List<String> categoriasFiltro;

  SearchFilter({
    this.soDestinos = false,
    this.soRotas = false,
    this.cidadeFiltro,
    this.categoriasFiltro = const [],
  });

  bool get temFiltroAtivo =>
      soDestinos ||
      soRotas ||
      (cidadeFiltro != null && cidadeFiltro!.isNotEmpty) ||
      categoriasFiltro.isNotEmpty;

  SearchFilter copyWith({
    bool? soDestinos,
    bool? soRotas,
    String? cidadeFiltro,
    List<String>? categoriasFiltro,
  }) =>
      SearchFilter(
        soDestinos: soDestinos ?? this.soDestinos,
        soRotas: soRotas ?? this.soRotas,
        cidadeFiltro: cidadeFiltro ?? this.cidadeFiltro,
        categoriasFiltro: categoriasFiltro ?? this.categoriasFiltro,
      );
}

class SearchHistoryItem {
  final String query;
  final SearchFilter filter;
  final DateTime timestamp;

  SearchHistoryItem({
    required this.query,
    required this.filter,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'query': query,
        'soDestinos': filter.soDestinos,
        'soRotas': filter.soRotas,
        'cidadeFiltro': filter.cidadeFiltro ?? '',
        'categoriasFiltro': filter.categoriasFiltro,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SearchHistoryItem.fromMap(Map<String, dynamic> map) =>
      SearchHistoryItem(
        query: map['query'] ?? '',
        filter: SearchFilter(
          soDestinos: map['soDestinos'] ?? false,
          soRotas: map['soRotas'] ?? false,
          cidadeFiltro: (map['cidadeFiltro'] as String?)?.isEmpty == true
              ? null
              : map['cidadeFiltro'],
          categoriasFiltro:
              List<String>.from(map['categoriasFiltro'] ?? []),
        ),
        timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      );
}

class SearchController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Estado ────────────────────────────────────────────────────────────────
  String _query = '';
  bool _isSearching = false;
  bool _hasSearched = false;
  SearchFilter _filter = SearchFilter();

  List<Map<String, dynamic>> _resultadosDestinos = [];
  List<Map<String, dynamic>> _resultadosRotas = [];
  List<SearchHistoryItem> _historico = [];
  List<String> _cidadesDisponiveis = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  String get query => _query;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  SearchFilter get filter => _filter;
  List<Map<String, dynamic>> get resultadosDestinos => _resultadosDestinos;
  List<Map<String, dynamic>> get resultadosRotas => _resultadosRotas;
  List<SearchHistoryItem> get historico => _historico;
  List<String> get cidadesDisponiveis => _cidadesDisponiveis;

  bool get semResultados =>
      _hasSearched &&
      !_isSearching &&
      _resultadosDestinos.isEmpty &&
      _resultadosRotas.isEmpty;

  SearchController() {
    _carregarHistorico();
    _carregarCidades();
  }

  // ── Histórico ─────────────────────────────────────────────────────────────

  Future<void> _carregarHistorico() async {
    try {
      final snap = await _firestore
          .collection('search_history')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      _historico = snap.docs
          .map((d) => SearchHistoryItem.fromMap(d.data()))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _salvarHistorico(String q, SearchFilter f) async {
    if (q.trim().isEmpty) return;
    try {
      final item =
          SearchHistoryItem(query: q, filter: f, timestamp: DateTime.now());
      await _firestore.collection('search_history').add(item.toMap());
      _historico.insert(0, item);
      if (_historico.length > 10)
        _historico = _historico.take(10).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> limparHistorico() async {
    try {
      final snap = await _firestore.collection('search_history').get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      _historico = [];
      notifyListeners();
    } catch (_) {}
  }

  /// Chamado pela view ao pressionar Enter/Submit
  Future<void> salvarHistoricoAtual() async {
    await _salvarHistorico(_query, _filter);
  }

  // ── Cidades disponíveis ───────────────────────────────────────────────────

  Future<void> _carregarCidades() async {
    try {
      final snap = await _firestore.collection('destinations').get();
      _cidadesDisponiveis = snap.docs
          .map((d) => (d.data()['city'] as String? ?? '').trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      notifyListeners();
    } catch (_) {}
  }

  // ── Filtro ────────────────────────────────────────────────────────────────

  void setFilter(SearchFilter f) {
    _filter = f;
    notifyListeners();
    if (_query.isNotEmpty) pesquisar(_query);
  }

  void resetFilter() {
    _filter = SearchFilter();
    notifyListeners();
    if (_query.isNotEmpty) pesquisar(_query);
  }

  // ── Pesquisa principal ────────────────────────────────────────────────────

  Future<void> pesquisar(String q) async {
    _query = q;
    if (q.trim().isEmpty) {
      _resultadosDestinos = [];
      _resultadosRotas = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    notifyListeners();

    final queryLower = q.trim().toLowerCase();

    final futures = <Future<List<Map<String, dynamic>>>>[];
    if (!_filter.soRotas)    futures.add(_buscarDestinos(queryLower));
    if (!_filter.soDestinos) futures.add(_buscarRotas(queryLower));

    final resultados = await Future.wait(futures);

    int idx = 0;
    _resultadosDestinos = !_filter.soRotas    ? resultados[idx++] : [];
    _resultadosRotas    = !_filter.soDestinos ? resultados[idx]   : [];

    _isSearching = false;
    notifyListeners();
    // histórico só salvo no Enter via salvarHistoricoAtual()
  }


  // ── Normaliza texto removendo acentos ─────────────────────────────────────

  String _normalizar(String texto) {
    const mapa = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n', 'ý': 'y',
      'À': 'a', 'Á': 'a', 'Â': 'a', 'Ã': 'a', 'Ä': 'a',
      'È': 'e', 'É': 'e', 'Ê': 'e', 'Ë': 'e',
      'Ì': 'i', 'Í': 'i', 'Î': 'i', 'Ï': 'i',
      'Ò': 'o', 'Ó': 'o', 'Ô': 'o', 'Õ': 'o', 'Ö': 'o',
      'Ù': 'u', 'Ú': 'u', 'Û': 'u', 'Ü': 'u',
      'Ç': 'c', 'Ñ': 'n', 'Ý': 'y',
    };
    return texto.toLowerCase().split('').map((c) => mapa[c] ?? c).join();
  }

  // ── Ordena: nome primeiro, depois descrição ───────────────────────────────

  List<Map<String, dynamic>> _ordenar(
      List<Map<String, dynamic>> lista, String queryNorm) {
    // 1º: bate pelo nome
    final porNome = lista.where((d) =>
        _normalizar(d['name'] as String? ?? '').contains(queryNorm));
    // 2º: bate pela categoria mas não pelo nome
    final porCat = lista.where((d) {
      final nome = _normalizar(d['name'] as String? ?? '');
      if (nome.contains(queryNorm)) return false;
      final cats = _parseCategorias(d['categories'])
          .map((c) => _normalizar(c));
      return cats.any((c) => c.contains(queryNorm));
    });
    // 3º: bate só pela descrição
    final porDesc = lista.where((d) {
      final nome = _normalizar(d['name'] as String? ?? '');
      if (nome.contains(queryNorm)) return false;
      final cats = _parseCategorias(d['categories'])
          .map((c) => _normalizar(c));
      if (cats.any((c) => c.contains(queryNorm))) return false;
      return _normalizar(d['description'] as String? ?? '').contains(queryNorm);
    });
    return [...porNome, ...porCat, ...porDesc];
  }

  // ── Helper: normaliza categories (String ou List) ─────────────────────────

  List<String> _parseCategorias(dynamic valor) {
    if (valor == null) return [];
    if (valor is List) return List<String>.from(valor);
    if (valor is String && valor.isNotEmpty) return [valor];
    return [];
  }

  // ── Busca destinos ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> _buscarDestinos(String queryLower) async {
    final queryNorm = _normalizar(queryLower);
    try {
      final snap = await _firestore.collection('destinations').get();
      final lista = snap.docs.where((doc) {
        final data = doc.data();
        final nome = _normalizar(data['name'] as String? ?? '');
        final desc = _normalizar(data['description'] as String? ?? '');
        final cats = _parseCategorias(data['categories'])
            .map((c) => _normalizar(c)).toList();
        final city = _normalizar(data['city'] as String? ?? '');

        if (_filter.cidadeFiltro != null &&
            _filter.cidadeFiltro!.isNotEmpty &&
            city != _normalizar(_filter.cidadeFiltro!)) return false;

        if (_filter.categoriasFiltro.isNotEmpty) {
          final cf = _filter.categoriasFiltro.map((c) => _normalizar(c)).toList();
          if (!cats.any((c) => cf.contains(c))) return false;
        }

        return nome.contains(queryNorm) ||
            desc.contains(queryNorm) ||
            cats.any((c) => c.contains(queryNorm));
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return _ordenar(lista, queryNorm);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _buscarRotas(String queryLower) async {
    final queryNorm = _normalizar(queryLower);
    try {
      final snap = await _firestore.collection('routes').get();

      final lista = snap.docs.where((doc) {
        final data = doc.data();
        final nome = _normalizar(data['name'] as String? ?? '');
        final desc = _normalizar(data['description'] as String? ?? '');
        final cats = _parseCategorias(data['categories'])
            .map((c) => _normalizar(c)).toList();
        final city = _normalizar(data['city'] as String? ?? '');

        if (_filter.cidadeFiltro != null &&
            _filter.cidadeFiltro!.isNotEmpty &&
            city != _normalizar(_filter.cidadeFiltro!)) return false;

        if (_filter.categoriasFiltro.isNotEmpty) {
          final cf = _filter.categoriasFiltro.map((c) => _normalizar(c)).toList();
          if (!cats.any((c) => cf.contains(c))) return false;
        }

        return nome.contains(queryNorm) ||
            desc.contains(queryNorm) ||
            cats.any((c) => c.contains(queryNorm));
      }).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return _ordenar(lista, queryNorm);
    } catch (e) {
      return [];
    }
  }
}