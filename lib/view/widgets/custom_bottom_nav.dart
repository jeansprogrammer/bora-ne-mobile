import 'package:flutter/material.dart';
import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/favorites_page.dart';
import 'package:boranemobile/view/pages/mapa_page.dart';
import 'package:boranemobile/view/pages/new_route_page.dart';
import 'package:boranemobile/view/pages/new_destination_page.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {

  void _abrirMenuAdicionar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('O que deseja adicionar?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.alt_route, color: Colors.orangeAccent),
              ),
              title: const Text('Nova rota',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Crie uma rota personalizada'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewRoutePage()));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_location_alt_outlined,
                    color: Colors.orangeAccent),
              ),
              title: const Text('Novo Destino',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Cadastre um ponto turístico'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewDestinationPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detecta a rota atual para marcar o item ativo
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/home';

    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            iconActive: Icons.home,
            label: 'Início',
            isActive: currentRoute == '/home' || currentRoute == '/',
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const HomePage(), settings: const RouteSettings(name: '/home')),
            ),
          ),
          _NavItem(
            icon: Icons.favorite_border,
            iconActive: Icons.favorite,
            label: 'Favoritos',
            isActive: currentRoute == '/favoritos',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const FavoritesPage(),
                  settings: const RouteSettings(name: '/favoritos')),
            ),
          ),
  // Botão central — Adicionar
          _NavItemCenter(
            onTap: () => _abrirMenuAdicionar(),
          ),
          _NavItem(
            icon: Icons.notifications_outlined,
            iconActive: Icons.notifications,
            label: 'Notificações',
            isActive: currentRoute == '/notificacoes',
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.person_outline,
            iconActive: Icons.person,
            label: 'Perfil',
            isActive: currentRoute == '/perfil',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconActive : icon,
              size: 26,
              color: isActive ? Colors.orangeAccent : Colors.grey,
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemCenter extends StatelessWidget {
  final VoidCallback onTap;

  const _NavItemCenter({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}