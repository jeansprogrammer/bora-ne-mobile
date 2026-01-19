import 'package:flutter/material.dart';
import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/favorites_page.dart';
import 'package:boranemobile/view/pages/mapa_page.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // HOME
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Início',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),

          // FAVORITOS - liguei ao favorites_page.dart
          _NavItem(
            icon: Icons.favorite_border,
            label: 'Favoritos',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),

          // MAPA
          _NavItem(
            icon: Icons.map_outlined,
            label: 'Mapa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaMapa()),
              );
            },
          ),

          // PERFIL
          _NavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            onTap: () {
              // depois você cria a ProfilePage
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

