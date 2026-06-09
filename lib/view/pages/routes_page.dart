import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/detail_local_sheet.dart';

class RoutesPage extends StatefulWidget {
  /// Categoria escolhida na HomeP age (ex: 'Gastronomia', 'Religioso').
  final String categoria;

  const RoutesPage({super.key, required this.categoria});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  late Future<List<Map<String, dynamic>>> _destinosFuture;

  @override
  void initState() {
    super.initState();
    _destinosFuture = _buscarPorCategoria(widget.categoria);
  }

  // ── Query no Firebase ─────────────────────────────────────
  // O campo 'categorias' é um array no Firestore →  arrayContains
  Future<List<Map<String, dynamic>>> _buscarPorCategoria(
      String categoria) async {
    final snap = await FirebaseFirestore.instance
        .collection('destinations')          // ← sua coleção
        .where('categories', arrayContains: categoria)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // guarda o id para uso futuro
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBar(),
              const SizedBox(height: 20),

              // Título dinâmico com a categoria escolhida
              Text(
                widget.categoria,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Lista vinda do Firebase
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _destinosFuture,
                  builder: (context, snapshot) {
                    // ── Carregando ─────────────────────────
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.orangeAccent),
                      );
                    }

                    // ── Erro ───────────────────────────────
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Erro: ${snapshot.error}'),
                      );
                    }

                    final locais = snapshot.data ?? [];

                    // ── Vazio ──────────────────────────────
                    if (locais.isEmpty) {
                      return Center(
                        child: Text(
                          'Nenhum local encontrado\npara "${widget.categoria}".',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 15),
                        ),
                      );
                    }

                    // ── Lista ──────────────────────────────
                    return ListView.builder(
                      itemCount: locais.length,
                      itemBuilder: (context, index) {
                        final item = locais[index];
                        return _itemCard(
                          context,
                          titulo: item['name'] ?? 'Sem nome',
                          img: item['coverPhoto'] ?? '',
                          nota: (item['nota'] as num?)?.toInt() ?? 0,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: const [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "O que você está procurando?",
                ),
              ),
            ),
            Icon(Icons.search, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(
    BuildContext context, {
    required String titulo,
    required String img,
    required int nota,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) =>
              DetailLocalSheet(titulo: titulo, img: img, nota: nota),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Imagem — usa network se for URL, asset se for caminho local
            Container(
              width: 90,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                color: Colors.grey[200],
              ),
              clipBehavior: Clip.antiAlias,
              child: img.startsWith('http')
                  ? Image.network(img, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey))
                  : Image.asset(img, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(Icons.star,
                          size: 18,
                          color: i < nota
                              ? Colors.orange
                              : Colors.grey[300]),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("307 Favoritos",
                      style:
                          TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.favorite_border, size: 25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _NavItem(icon: Icons.home, label: "Início"),
          _NavItem(icon: Icons.favorite, label: "Favoritos"),
          _NavItem(icon: Icons.notifications, label: "Notificações"),
          _NavItem(icon: Icons.person, label: "Perfil"),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}