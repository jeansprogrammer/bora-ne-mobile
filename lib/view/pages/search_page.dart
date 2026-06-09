import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/controllers/search_controller.dart' as sc;
import 'package:boranemobile/data/category_data.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/route_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _inputController = TextEditingController();
  late final sc.SearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sc.SearchController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String val) {
    if (val.trim().isEmpty) return;
    _controller.pesquisar(val);
    _controller.salvarHistoricoAtual(); // salva histórico somente no Enter
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterSheet(controller: _controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<sc.SearchController>.value(
      value: _controller,
      child: Consumer<sc.SearchController>(
        builder: (context, ctrl, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    // ── Barra de pesquisa ──────────────────────────────
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            const Icon(Icons.search,
                                color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                autofocus: true,
                                textInputAction: TextInputAction.search,
                                style: const TextStyle(fontSize: 15),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'O que você está procurando?',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  // Atualiza só o estado visual (botão X)
                                  setState(() {});
                                },
                                onSubmitted: _onSubmitted,
                              ),
                            ),
                            if (_inputController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _inputController.clear();
                                  _controller.pesquisar('');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.close,
                                      color: Colors.grey, size: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Botão filtro ──────────────────────────────────
                    GestureDetector(
                      onTap: _abrirFiltros,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ctrl.filter.temFiltroAtivo
                              ? Colors.orangeAccent
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: ctrl.filter.temFiltroAtivo
                              ? Colors.white
                              : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: _buildBody(ctrl),
          );
        },
      ),
    );
  }

  Widget _buildBody(sc.SearchController ctrl) {
    // Loading
    if (ctrl.isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }

    // Estado inicial — histórico
    if (!ctrl.hasSearched) {
      return _buildHistorico(ctrl);
    }

    // Sem resultados
    if (ctrl.semResultados) {
      return _buildVazio();
    }

    // Resultados
    return _buildResultados(ctrl);
  }

  // ── HISTÓRICO ─────────────────────────────────────────────────────────────

  Widget _buildHistorico(sc.SearchController ctrl) {
    if (ctrl.historico.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('Pesquise destinos e rotas',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Explore o Nordeste',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pesquisas recentes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton(
                onPressed: ctrl.limparHistorico,
                child: const Text('Limpar',
                    style: TextStyle(
                        color: Colors.orangeAccent, fontSize: 13)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: ctrl.historico.length,
            itemBuilder: (_, i) {
              final item = ctrl.historico[i];
              return ListTile(
                leading: const Icon(Icons.history,
                    color: Colors.grey, size: 20),
                title: Text(item.query,
                    style: const TextStyle(fontSize: 14)),
                subtitle: item.filter.temFiltroAtivo
                    ? Text(
                        _descricaoFiltro(item.filter),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.orangeAccent),
                      )
                    : null,
                trailing: const Icon(Icons.north_west,
                    color: Colors.grey, size: 16),
                onTap: () {
                  _inputController.text = item.query;
                  _controller.setFilter(item.filter);
                  _controller.pesquisar(item.query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _descricaoFiltro(sc.SearchFilter f) {
    final partes = <String>[];
    if (f.soDestinos) partes.add('Destinos');
    if (f.soRotas) partes.add('Rotas');
    if (f.cidadeFiltro != null && f.cidadeFiltro!.isNotEmpty)
      partes.add(f.cidadeFiltro!);
    if (f.categoriasFiltro.isNotEmpty)
      partes.add(f.categoriasFiltro.join(', '));
    return partes.join(' · ');
  }

  // ── SEM RESULTADOS ────────────────────────────────────────────────────────

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nada encontrado para\n"${_controller.query}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente outros termos ou remova os filtros.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (_controller.filter.temFiltroAtivo) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _controller.resetFilter,
              icon: const Icon(Icons.filter_alt_off,
                  color: Colors.black, size: 18),
              label: const Text('Remover filtros',
                  style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── RESULTADOS ────────────────────────────────────────────────────────────

  Widget _buildResultados(sc.SearchController ctrl) {
    final totalDestinos = ctrl.resultadosDestinos.length;
    final totalRotas = ctrl.resultadosRotas.length;
    final total = totalDestinos + totalRotas;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Resumo
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '$total resultado${total != 1 ? 's' : ''} para "${ctrl.query}"',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),

        // ── Destinos ────────────────────────────────────────────────────
        if (ctrl.resultadosDestinos.isNotEmpty) ...[
          _sectionTitle('Destinos', totalDestinos),
          const SizedBox(height: 8),
          ...ctrl.resultadosDestinos.map((data) => DestinationCard(
                id: data['id'] ?? '',
                data: data,
              )),
          const SizedBox(height: 16),
        ],

        // ── Rotas ────────────────────────────────────────────────────────
        if (ctrl.resultadosRotas.isNotEmpty) ...[
          _sectionTitle('Rotas', totalRotas),
          const SizedBox(height: 8),
          ...ctrl.resultadosRotas.map((data) => RouteCard(
                id: data['id'] ?? '',
                data: data,
              )),
        ],
      ],
    );
  }

  Widget _sectionTitle(String titulo, int count) {
    return Row(
      children: [
        Text(titulo,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ── FILTER SHEET ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final sc.SearchController controller;
  const _FilterSheet({required this.controller});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _soDestinos;
  late bool _soRotas;
  late String? _cidade;
  late List<String> _categorias;

  @override
  void initState() {
    super.initState();
    final f = widget.controller.filter;
    _soDestinos = f.soDestinos;
    _soRotas = f.soRotas;
    _cidade = f.cidadeFiltro;
    _categorias = List.from(f.categoriasFiltro);
  }

  void _aplicar() {
    widget.controller.setFilter(sc.SearchFilter(
      soDestinos: _soDestinos,
      soRotas: _soRotas,
      cidadeFiltro: _cidade,
      categoriasFiltro: _categorias,
    ));
    Navigator.pop(context);
  }

  void _limpar() {
    setState(() {
      _soDestinos = false;
      _soRotas = false;
      _cidade = null;
      _categorias = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cidades = widget.controller.cidadesDisponiveis;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filtros',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _limpar,
                  child: const Text('Limpar tudo',
                      style: TextStyle(color: Colors.orangeAccent)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                controller: scrollController,
                children: [

                  // ── Tipo ──────────────────────────────────────────────
                  _filterTitle('Tipo'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _toggleChip(
                        'Destinos',
                        Icons.place_outlined,
                        _soDestinos,
                        () => setState(() {
                          _soDestinos = !_soDestinos;
                          if (_soDestinos) _soRotas = false;
                        }),
                      ),
                      const SizedBox(width: 10),
                      _toggleChip(
                        'Rotas',
                        Icons.alt_route,
                        _soRotas,
                        () => setState(() {
                          _soRotas = !_soRotas;
                          if (_soRotas) _soDestinos = false;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Cidade ────────────────────────────────────────────
                  _filterTitle('Cidade'),
                  const SizedBox(height: 8),
                  cidades.isEmpty
                      ? const Text('Nenhuma cidade disponível',
                          style: TextStyle(color: Colors.grey, fontSize: 13))
                      : DropdownButtonFormField<String>(
                          value: _cidade,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: 'Todas as cidades',
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                            prefixIcon: const Icon(Icons.location_city_outlined,
                                color: Colors.orangeAccent, size: 20),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.black12)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Colors.black12)),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Todas as cidades'),
                            ),
                            ...cidades.map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c,
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (v) => setState(() => _cidade = v),
                        ),
                  const SizedBox(height: 20),

                  // ── Categorias ────────────────────────────────────────
                  _filterTitle('Categorias'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoriasBoraNE.map((cat) {
                      final sel = _categorias.contains(cat.name);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel) {
                            _categorias.remove(cat.name);
                          } else {
                            _categorias.add(cat.name);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? Colors.orangeAccent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel
                                  ? Colors.orangeAccent
                                  : Colors.black12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(cat.name,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: sel
                                          ? Colors.white
                                          : Colors.black87)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Botão aplicar ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _aplicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Aplicar filtros',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTitle(String title) => Text(title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));

  Widget _toggleChip(
      String label, IconData icon, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? Colors.orangeAccent : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? Colors.orangeAccent : Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: sel ? Colors.white : Colors.black54),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}