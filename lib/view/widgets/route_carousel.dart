import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/controllers/auth_controller.dart';
import 'package:boranemobile/controllers/favorites_controller.dart';
import 'package:boranemobile/services/favorites_service.dart';
import 'package:boranemobile/models/route_creation_model.dart';
import 'package:boranemobile/view/widgets/login_required_view.dart';

class RouteCarousel extends StatefulWidget {
  final String? city;
  final Function(Map<String, dynamic> rota)? onTapRota;

  const RouteCarousel({super.key, this.city, this.onTapRota});

  @override
  State<RouteCarousel> createState() => _RouteCarouselState();
}

class _RouteCarouselState extends State<RouteCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentIndex = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _rotas = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rotasSubscription;

  @override
  void initState() {
    super.initState();
    _escutarRotas();
  }

  @override
  void didUpdateWidget(covariant RouteCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      _escutarRotas();
    }
  }

  // Escuta as rotas em tempo real, para que exclusões/edições feitas em
  // outras telas (ex: excluir rota, adicionar categoria) reflitam aqui
  // imediatamente, sem precisar reiniciar o app.
  void _escutarRotas() {
    _rotasSubscription?.cancel();

    Query<Map<String, dynamic>> ref = FirebaseFirestore.instance.collection('routes');
    if (widget.city != null && widget.city!.isNotEmpty) {
      ref = ref.where('city', isEqualTo: widget.city);
    }

    _rotasSubscription = ref.limit(5).snapshots().listen((snap) {
      if (!mounted) return;

      // Fallback: se buscamos por uma cidade específica e não há rotas nela,
      // passamos a escutar todas as rotas.
      if (snap.docs.isEmpty && widget.city != null && widget.city!.isNotEmpty) {
        _rotasSubscription?.cancel();
        _rotasSubscription = FirebaseFirestore.instance
            .collection('routes')
            .limit(5)
            .snapshots()
            .listen(_atualizarRotas);
        return;
      }

      _atualizarRotas(snap);
    });
  }

  void _atualizarRotas(QuerySnapshot<Map<String, dynamic>> snap) {
    if (!mounted) return;
    setState(() {
      _rotas = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
    _iniciarAutoPlay();
  }

  void _iniciarAutoPlay() {
    _timer?.cancel();
    if (_rotas.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
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
    _rotasSubscription?.cancel();
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

  List<String> _parseCats(dynamic valor) {
    if (valor == null) return [];
    if (valor is List) return List<String>.from(valor);
    if (valor is String && valor.isNotEmpty) return [valor];
    return [];
  }

  Widget _buildCard(Map<String, dynamic> rota) {
    final nome = rota['name'] ?? 'Sem título';
    final coverPhoto = rota['coverPhoto'] ?? '';
    final categories = _parseCats(rota['categories']);
    final categoria = categories.isNotEmpty ? categories.first : '';

    // Favoritos
    final authController = Provider.of<AuthController>(context);
    final String uidAtual = authController.user?.uid ?? '';
    final favoritadoPor = List<String>.from(rota['favoritedBy'] ?? []);
    final isFavorito = favoritadoPor.contains(uidAtual);

    return GestureDetector(
      onTap: () {
        if (widget.onTapRota != null) {
          widget.onTapRota!(rota);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade300,
          image: coverPhoto.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(coverPhoto),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        ),
                        if (categories.length > 1) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1),
                            ),
                            child: Text(
                              '+${categories.length - 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    )
                  else
                    const SizedBox.shrink(),
                  // Botão favorito
                  GestureDetector(
                    onTap: () async {
                      if (uidAtual.isEmpty) {
                        showLoginRequiredSheet(
                          context,
                          icon: Icons.favorite_border,
                          title: 'Faça login para favoritar',
                          message:
                              'Entre na sua conta para salvar rotas e destinos favoritos.',
                        );
                        return;
                      }

                      final ref = FirebaseFirestore.instance
                          .collection('routes')
                          .doc(rota['id']);
                      final lista = List<String>.from(favoritadoPor);
                      final isAdd = !lista.contains(uidAtual);

                      // Atualização visual instantânea local
                      setState(() {
                        if (isAdd) {
                          lista.add(uidAtual);
                        } else {
                          lista.remove(uidAtual);
                        }
                        rota['favoritedBy'] = lista;
                      });
                      
                      // 1. Atualiza na coleção global de rotas
                      await ref.update({'favoritedBy': lista});
                      
                      // 2. Atualiza na sublista de favoritos do usuário
                      final favService = FavoritesService();
                      final model = RouteCreationModel.fromMap(rota);
                      if (isAdd) {
                        await favService.favoritarRota(uidAtual, model);
                      } else {
                        await favService.desfavoritarRota(uidAtual, model.name);
                      }

                      // 3. Atualiza o controller se estiver disponível na árvore
                      if (!mounted) return;
                      try {
                        final favController = Provider.of<FavoritesController>(context, listen: false);
                        if (favController.favorites != null) {
                          if (isAdd) {
                            favController.favorites!.routes.add(model);
                          } else {
                            favController.favorites!.routes.removeWhere((r) => r.name == model.name);
                          }
                          favController.forceNotifyListeners();
                        }
                      } catch (e) {
                        // ignore
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        color: isFavorito ? Color(0xFFF7B119) : const Color.fromARGB(255, 199, 198, 198),
                        size: 22,
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