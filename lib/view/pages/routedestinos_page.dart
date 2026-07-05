import 'package:boranemobile/controllers/destination_creation_controller.dart';
import 'package:boranemobile/controllers/route_creation_controller.dart';
import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/route_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

const Color kPrimaryGold = Color(0xFFEDA200);

class RouteDestinosPage extends StatefulWidget {
  final String? categoriaInicial;

  final String? cidadeInicial;

  const RouteDestinosPage({
    super.key,
    this.categoriaInicial,
    this.cidadeInicial,
  });

  @override
  State<RouteDestinosPage> createState() => _RouteDestinosPageState();
}

class _RouteDestinosPageState extends State<RouteDestinosPage> {
  int selectedIndex = 0;
  Position? _posicaoAtual;

  @override
  void initState() {
    super.initState();
    _detectarPosicao();
  }

  Future<void> _detectarPosicao() async {
    final pos = await LocationService().obterPosicaoAtual();
    if (mounted && pos != null) {
      setState(() => _posicaoAtual = pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoria = widget.categoriaInicial;
    final cidade = widget.cidadeInicial;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Image.asset(
                          'assets/images/LOGO_V2_1.png',
                          height: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Botões Rotas / Destinos (reduzidos) ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: "Rotas",
                      selected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTabButton(
                      title: "Destinos",
                      selected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Categoria selecionada (vinda da home) ────────────────────────
            if (categoria != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kPrimaryGold, width: 1),
                  ),
                  child: Text(
                    categoria,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryGold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ── Lista de Rotas / Destinos ────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selectedIndex == 0
                    ? RotasWidget(
                        key: const ValueKey('rotas'),
                        categoriaFiltro: categoria,
                        cidadeFiltro: cidade,
                        posicaoAtual: _posicaoAtual,
                      )
                    : DestinosWidget(
                        key: const ValueKey('destinos'),
                        categoriaFiltro: categoria,
                        cidadeFiltro: cidade,
                        posicaoAtual: _posicaoAtual,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPrimaryGold : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kPrimaryGold, width: 1.5),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : kPrimaryGold,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

List<String> _parseCats(dynamic valor) {
  if (valor == null) return [];
  if (valor is List) return List<String>.from(valor);
  if (valor is String && valor.isNotEmpty) return [valor];
  return [];
}

bool _passaFiltro(List<String> categoriasItem, String? categoria) {
  if (categoria == null) return true;
  return categoriasItem.contains(categoria);
}

// Distância (em metros) de uma posição até um ponto (lat, lon).
// Retorna null quando as coordenadas do ponto são inválidas (0,0 = não geocodificado).
double? _distanciaAte(Position origem, double lat, double lon) {
  if (lat == 0.0 && lon == 0.0) return null;
  return Geolocator.distanceBetween(origem.latitude, origem.longitude, lat, lon);
}

// Ordena por distância crescente; itens sem coordenadas válidas vão para o final.
void _ordenarPorDistancia<T>(
  List<T> itens,
  Position? posicaoAtual,
  double? Function(T) obterDistancia,
) {
  if (posicaoAtual == null) return;
  itens.sort((a, b) {
    final da = obterDistancia(a);
    final db = obterDistancia(b);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });
}

// ── ROTAS ──────────────────────────────────────────────────────────────────

class RotasWidget extends StatefulWidget {
  final String? categoriaFiltro;
  final String? cidadeFiltro;
  final Position? posicaoAtual;
  const RotasWidget({
    super.key,
    this.categoriaFiltro,
    this.cidadeFiltro,
    this.posicaoAtual,
  });

  @override
  State<RotasWidget> createState() => _RotasWidgetState();
}

class _RotasWidgetState extends State<RotasWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RouteCreationController>().carregarRotas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Consumer<RouteCreationController>(
      builder: (context, controller, child) {
        if (controller.isSearching) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryGold),
          );
        }

        final rotasFiltradas = controller.rotas.where((rota) {
          final cats = _parseCats(rota['categories']);
          return _passaFiltro(cats, widget.categoriaFiltro) && (widget.cidadeFiltro == null || rota['city'] == widget.cidadeFiltro);
        }).toList();

        if (rotasFiltradas.isEmpty) {
          return const Center(child: Text("Nenhuma rota encontrada"));
        }

        // Ordena pela menor distância entre a posição atual e os destinos da rota.
        _ordenarPorDistancia<Map<String, dynamic>>(
          rotasFiltradas,
          widget.posicaoAtual,
          (rota) {
            final posicao = widget.posicaoAtual;
            if (posicao == null) return null;
            final destinos = rota['destinations'];
            if (destinos is! List || destinos.isEmpty) return null;

            double? menorDistancia;
            for (final d in destinos) {
              if (d is! Map) continue;
              final lat = (d['latitude'] ?? 0.0) as num;
              final lon = (d['longitude'] ?? 0.0) as num;
              final dist = _distanciaAte(posicao, lat.toDouble(), lon.toDouble());
              if (dist != null && (menorDistancia == null || dist < menorDistancia)) {
                menorDistancia = dist;
              }
            }
            return menorDistancia;
          },
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: rotasFiltradas.length,
          itemBuilder: (context, index) {
            final rota = rotasFiltradas[index];
            return RouteCard(id: rota['id'] ?? '', data: rota, currentUid: uid);
          },
        );
      },
    );
  }
}

// ── DESTINOS ───────────────────────────────────────────────────────────────

class DestinosWidget extends StatefulWidget {
  final String? categoriaFiltro;
  final String? cidadeFiltro;
  final Position? posicaoAtual;
  const DestinosWidget({
    super.key,
    this.categoriaFiltro,
    this.cidadeFiltro,
    this.posicaoAtual,
  });

  @override
  State<DestinosWidget> createState() => _DestinosWidgetState();
}

class _DestinosWidgetState extends State<DestinosWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DestinationCreationController>().carregarDestinos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Consumer<DestinationCreationController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryGold),
          );
        }

        final destinosFiltrados = controller.destinos.where((destino) {
          final cats = _parseCats(destino.categories);
          return _passaFiltro(cats, widget.categoriaFiltro) && (widget.cidadeFiltro == null || destino.city == widget.cidadeFiltro);
        }).toList();

        if (destinosFiltrados.isEmpty) {
          return const Center(child: Text('Nenhum destino encontrado'));
        }

        // Ordena do mais próximo ao mais distante da posição atual do usuário.
        _ordenarPorDistancia<DestinationModel>(
          destinosFiltrados,
          widget.posicaoAtual,
          (destino) => widget.posicaoAtual == null
              ? null
              : _distanciaAte(
                  widget.posicaoAtual!,
                  destino.latitude,
                  destino.longitude,
                ),
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: destinosFiltrados.length,
          itemBuilder: (context, index) {
            final destino = destinosFiltrados[index];
            return DestinationCard(
              id: destino.id ?? '',
              data: destino.toMap(),
              currentUid: uid,
            );
          },
        );
      },
    );
  }
}
