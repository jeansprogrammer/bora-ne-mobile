import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/services/favorites_service.dart';
import 'package:boranemobile/controllers/favorites_controller.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:boranemobile/view/pages/route_detail.dart';

class RouteCard extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;
  final String currentUid;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.id,
    required this.data,
    this.currentUid = 'usuario_teste',
    this.onTap,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  late bool _isFavorito;
  late List<String> _favoritedBy;

  @override
  void initState() {
    super.initState();
    _favoritedBy = List<String>.from(widget.data['favoritedBy'] ?? []);
    _isFavorito = _favoritedBy.contains(widget.currentUid);
    try {
      final favController = Provider.of<FavoritesController>(context, listen: false);
      if (favController.favorites != null) {
        final name = widget.data['name'] ?? '';
        _isFavorito = favController.isRotaFavorita(name);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant RouteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.currentUid != widget.currentUid) {
      _favoritedBy = List<String>.from(widget.data['favoritedBy'] ?? []);
      _isFavorito = _favoritedBy.contains(widget.currentUid);
      try {
        final favController = Provider.of<FavoritesController>(context, listen: false);
        if (favController.favorites != null) {
          final name = widget.data['name'] ?? '';
          _isFavorito = favController.isRotaFavorita(name);
        }
      } catch (_) {}
    }
  }

  Future<void> _toggleFavorito(BuildContext context) async {
    final isAdd = !_isFavorito;

    // 1. Atualiza o estado visual local imediatamente
    setState(() {
      _isFavorito = isAdd;
      if (isAdd) {
        _favoritedBy.add(widget.currentUid);
      } else {
        _favoritedBy.remove(widget.currentUid);
      }
    });

    // 2. Atualiza o FavoritesController PRIMEIRO para que a tela de favoritos
    //    atualize imediatamente (remove/adiciona o item da lista visível)
    final map = Map<String, dynamic>.from(widget.data);
    map['id'] = widget.id;
    final rota = RouteCreationModel.fromMap(map);
    try {
      final favController = Provider.of<FavoritesController>(context, listen: false);
      if (favController.favorites != null) {
        if (isAdd) {
          favController.favorites!.routes.add(rota);
        } else {
          favController.favorites!.routes.removeWhere((r) => r.name == rota.name);
        }
        favController.forceNotifyListeners();
      }
    } catch (_) {
      // Controller pode não estar na árvore de provedores
    }

    // 3. Sincroniza com o Firebase em background (não bloqueia a UI)
    try {
      if (widget.id.isNotEmpty) {
        final ref = FirebaseFirestore.instance.collection('routes').doc(widget.id);
        await ref.update({'favoritedBy': _favoritedBy});
      }

      final favService = FavoritesService();
      if (isAdd) {
        await favService.favoritarRota(widget.currentUid, rota);
      } else {
        await favService.desfavoritarRota(widget.currentUid, rota.name);
      }
    } catch (e) {
      debugPrint('Erro ao sincronizar favorito de rota com Firebase: $e');
    }
  }

  List<String> _parseCats(dynamic valor) {
    if (valor == null) return [];
    if (valor is List) return List<String>.from(valor);
    if (valor is String && valor.isNotEmpty) return [valor];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final nome        = widget.data['name']        ?? 'Sem título';
    final coverPhoto  = widget.data['coverPhoto']  ?? '';
    final categories  = _parseCats(widget.data['categories']);
    final city        = widget.data['city']        ?? '';
    final destinations = widget.data['destinations'] as List? ?? [];
    final totalDestinos = destinations.length;

    return GestureDetector(
      onTap: widget.onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RouteDetailPage(
                    rota: {...widget.data, 'id': widget.id},
                  ),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // ── Imagem ────────────────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: coverPhoto.isNotEmpty
                      ? Image.network(
                          coverPhoto,
                          width: 100,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),

                // ── Info ──────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 40, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (city.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  city,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '$totalDestinos destino${totalDestinos != 1 ? 's' : ''}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        if (categories.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: categories.map((cat) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3D6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  cat,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFF7B119),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Coração no topo direito ────────────────────────────────────
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => _toggleFavorito(context),
                child: Icon(
                  _isFavorito ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorito ? const Color(0xFFF7B119) : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 110,
      color: const Color(0xFFFFF9E7),
      child: const Icon(Icons.image_outlined,
          color: Colors.orangeAccent, size: 32),
    );
  }
}