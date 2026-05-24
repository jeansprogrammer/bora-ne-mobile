import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteCarousel extends StatefulWidget {
  const RouteCarousel({super.key});

  @override
  State<RouteCarousel> createState() => _RouteCarouselState();
}

class _RouteCarouselState extends State<RouteCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentIndex = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _rotas = [];

  @override
  void initState() {
    super.initState();
    _carregarRotas();
  }

  Future<void> _carregarRotas() async {
    final snap = await FirebaseFirestore.instance
        .collection('rotas_criadas')
        .limit(5)
        .get();

    if (mounted) {
      setState(() {
        _rotas = snap.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
      _iniciarAutoPlay();
    }
  }

  void _iniciarAutoPlay() {
    _timer?.cancel();
    if (_rotas.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients || _rotas.isEmpty) return;
      _currentIndex = (_currentIndex + 1) % _rotas.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_rotas.isEmpty) {
      return _buildSkeleton();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _rotas.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, index) {
              final rota = _rotas[index];
              return _buildCard(rota);
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indicadores
        if (_rotas.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_rotas.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _currentIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _currentIndex
                      ? Colors.orangeAccent
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> rota) {
    final nome = rota['name'] ?? 'Sem título';
    final fotoCapa = rota['fotoCapa'] ?? '';
    final categorias = List<String>.from(rota['categorias'] ?? []);
    final categoria = categorias.isNotEmpty ? categorias.first : '';

    // Favoritos
    final favoritadoPor = List<String>.from(rota['favoritadoPor'] ?? []);
    const String uidAtual = 'usuario_teste';
    final isFavorito = favoritadoPor.contains(uidAtual);

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
          image: fotoCapa.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(fotoCapa),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.05),
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topo: badge categoria + favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (categoria.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        categoria,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  // Botão favorito
                  GestureDetector(
                    onTap: () async {
                      final ref = FirebaseFirestore.instance
                          .collection('rotas_criadas')
                          .doc(rota['id']);
                      final lista = List<String>.from(favoritadoPor);
                      if (lista.contains(uidAtual)) {
                        lista.remove(uidAtual);
                      } else {
                        lista.add(uidAtual);
                      }
                      await ref.update({'favoritadoPor': lista});
                      _carregarRotas();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        color: isFavorito ? Colors.red : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Título
              Text(
                nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      ),
    );
  }
}