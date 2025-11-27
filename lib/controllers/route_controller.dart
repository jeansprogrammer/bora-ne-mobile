import 'dart:async';
import 'package:boranemobile/models/route_model.dart';
import 'package:flutter/material.dart';


class RouteController extends ChangeNotifier {
  final PageController pageController = PageController(viewportFraction: 0.85);

  int currentIndex = 0;

  final List<RouteModel> routes = [
    RouteModel(
      title: "Rota Religiosa",
      subtitle: "Conheça os principais pontos de fé de Garanhuns",
      image: "assets/images/seminario.jpg",
    ),
    RouteModel(
      title: "Rota Gastronômica",
      subtitle: "Os melhores sabores da cidade",
      image: "assets/images/gastronomia.jpg",
    ),
    RouteModel(
      title: "Rota Cultural",
      subtitle: "Museus, história e arte",
      image: "assets/images/cultura.jpg",
    ),
  ];

  Timer? _autoPlayTimer;

  RouteController() {
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (pageController.hasClients) {
        currentIndex = (currentIndex + 1) % routes.length;
        pageController.animateToPage(
          currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
