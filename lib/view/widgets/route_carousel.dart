import 'dart:async';
import 'package:boranemobile/view/pages/mapa_page.dart';
import 'package:flutter/material.dart';
import 'models/route_model.dart';

class RouteCarousel extends StatefulWidget {
  const RouteCarousel({super.key});

  @override
  State<RouteCarousel> createState() => _RouteCarouselState();
}

class _RouteCarouselState extends State<RouteCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  int _currentIndex = 0;
  Timer? _timer;

  final List<RouteModel> _routes = [
    RouteModel(
      title: "Lugares Religiosos em Garanhuns",
      subtitle: "Maria Eduarda",
      image: "../../assets/images/cristo-do-magano.png",
    ),
    RouteModel(
      title: "Aventuras em Bonito",
      subtitle: "Jean Mendes",
      image: "../../assets/images/restaurante.png",
    ),
    RouteModel(
      title: "Rota Cultura Popular",
      subtitle: "Bruna Sousa",
      image: "../../assets/images/marco-zero.png",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_pageController.hasClients) return;

      _currentIndex = (_currentIndex + 1) % _routes.length;

      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {}); // atualiza indicadores, se houver
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
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          final route = _routes[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(route.image),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      route.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TelaMapa()),
                          );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        child: Text("Ver rota", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
