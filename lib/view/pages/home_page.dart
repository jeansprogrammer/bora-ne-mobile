import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/route_carousel.dart';
import 'package:boranemobile/view/pages/routes_page.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/services/geoapify_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _cidadeDetectada;
  bool _estaCarregandoLocalizacao = false;

  @override
  void initState() {
    super.initState();
    _detectarLocalizacao();
  }

  Future<void> _detectarLocalizacao() async {
    setState(() {
      _estaCarregandoLocalizacao = true;
    });

    try {
      final pos = await LocationService().obterPosicaoAtual();
      if (pos != null) {
        final cidade = await GeoapifyService().obterCidadePorCoordenadas(
          pos.latitude,
          pos.longitude,
        );
        if (cidade != null && mounted) {
          setState(() {
            _cidadeDetectada = cidade;
          });
        }
      }
    } catch (e) {
      print('Erro ao obter localização ou cidade: $e');
    } finally {
      if (mounted) {
        setState(() {
          _estaCarregandoLocalizacao = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Image.asset('assets/images/logo_bora_ne.png', height: 44),
                ),
              ),

              // ── Barra de Localização ──────────────────────────────────────
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.orangeAccent, size: 18),
                        const SizedBox(width: 6),
                        if (_estaCarregandoLocalizacao) ...[
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Detectando sua cidade...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else if (_cidadeDetectada != null)
                          Text(
                            'Mostrando rotas de $_cidadeDetectada',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _detectarLocalizacao,
                            child: const Text(
                              'Definir localização / Permitir GPS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orangeAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Barra de pesquisa ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06),
                          blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'O que você está procurando?',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Icon(Icons.search, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Carrossel de rotas ────────────────────────────────────────
              RouteCarousel(cidade: _cidadeDetectada),

              const SizedBox(height: 20),

              // ── Categorias ────────────────────────────────────────────────
              _buildCategoriasSection(),

              const SizedBox(height: 20),

              // ── Próximo a você ────────────────────────────────────────────
              _buildProximoAVoce(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── SEÇÃO CATEGORIAS ──────────────────────────────────────────────────────

  Widget _buildCategoriasSection() {
    final categorias = [
      {'nome': 'Gastronomia', 'icone': '🍔', 'cor': const Color(0xFFFFB347)},
      {'nome': 'Religioso',   'icone': '⛪', 'cor': const Color(0xFF7B9FE0)},
      {'nome': 'Lazer',       'icone': '🎪', 'cor': const Color(0xFF6FD18A)},
      {'nome': 'Música',      'icone': '🎭', 'cor': const Color(0xFFE07B7B)},
      {'nome': 'Cultural',    'icone': '🏛️', 'cor': const Color(0xFFB07BE0)},
      {'nome': 'Histórico',   'icone': '🏰', 'cor': const Color(0xFF7BBBE0)},
      {'nome': 'Natural',     'icone': '🌿', 'cor': const Color(0xFF5DBE8A)},
      {'nome': 'Aventura',    'icone': '🧗', 'cor': const Color(0xFFE0A87B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categorias.length,
            itemBuilder: (_, i) {
              final cat = categorias[i];
              return GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ListaReligiososPage())),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: (cat['cor'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(cat['icone'] as String,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['nome'] as String,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── PRÓXIMO A VOCÊ ────────────────────────────────────────────────────────

  Widget _buildProximoAVoce() {
    // Definimos o stream filtrado por cidade se disponível
    final streamFiltrado = (_cidadeDetectada != null && _cidadeDetectada!.isNotEmpty)
        ? FirebaseFirestore.instance
            .collection('rotas_criadas')
            .where('cidade', isEqualTo: _cidadeDetectada)
            .limit(3)
            .snapshots()
        : FirebaseFirestore.instance
            .collection('rotas_criadas')
            .limit(3)
            .snapshots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximo a você',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_cidadeDetectada != null && _cidadeDetectada!.isNotEmpty)
                Text(
                  'em $_cidadeDetectada',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.orangeAccent),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: streamFiltrado,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
            }

            // Se estiver vazio E tínhamos uma cidade filtrada, fazemos o fallback para todas as rotas
            if ((!snapshot.hasData || snapshot.data!.docs.isEmpty) &&
                _cidadeDetectada != null &&
                _cidadeDetectada!.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'Ainda não temos rotas cadastradas em $_cidadeDetectada. Enquanto isso, confira estas opções de outras cidades:',
                      style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rotas_criadas')
                        .limit(3)
                        .snapshots(),
                    builder: (context, fallbackSnapshot) {
                      if (fallbackSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
                      }
                      if (!fallbackSnapshot.hasData || fallbackSnapshot.data!.docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Nenhuma rota disponível.', style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return _buildRotasList(fallbackSnapshot.data!.docs);
                    },
                  ),
                ],
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Nenhuma rota encontrada.', style: TextStyle(color: Colors.grey)),
              );
            }

            return _buildRotasList(snapshot.data!.docs);
          },
        ),
      ],
    );
  }

  Widget _buildRotasList(List<QueryDocumentSnapshot> docs) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _buildRotaCard(doc.id, data);
          },
        ),
        const SizedBox(height: 8),
        // ── Botão Ver mais ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListaReligiososPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver mais',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRotaCard(String id, Map<String, dynamic> data) {
    final nome = data['name'] ?? 'Sem título';
    final descricao = data['description'] ?? '';
    final fotoCapa = data['fotoCapa'] ?? '';
    final categorias = List<String>.from(data['categorias'] ?? []);

    // Favoritos: lista de UIDs
    final favoritadoPor = List<String>.from(data['favoritadoPor'] ?? []);
    // TODO: substituir pelo UID real do usuário logado
    const String uidAtual = 'usuario_teste';
    final isFavorito = favoritadoPor.contains(uidAtual);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: fotoCapa.isNotEmpty
                ? Image.network(fotoCapa,
                    width: 100, height: 100, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder())
                : _imagePlaceholder(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(descricao,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Ver rota'),
                      ),
                      GestureDetector(
                        onTap: () => _toggleFavorito(id, favoritadoPor, uidAtual),
                        child: Icon(
                          isFavorito ? Icons.favorite : Icons.favorite_border,
                          color: isFavorito ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorito(
      String rotaId, List<String> favoritadoPor, String uid) async {
    final ref =
        FirebaseFirestore.instance.collection('rotas_criadas').doc(rotaId);
    final lista = List<String>.from(favoritadoPor);
    if (lista.contains(uid)) {
      lista.remove(uid);
    } else {
      lista.add(uid);
    }
    await ref.update({'favoritadoPor': lista});
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: const Color(0xFFFFF9E7),
      child: const Icon(Icons.image_outlined,
          color: Colors.orangeAccent, size: 32),
    );
  }
}