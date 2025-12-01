import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/mapa_page.dart';
import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        setState(() => currentIndex = index);

        switch (index) {
          case 0:
            // INÍCIO
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
            break;

          case 1:
            // FAVORITOS
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
            break;

          case 2:
            // MAPA
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TelaMapa()),
            );
            break;

          case 3:
            // PERFIL
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
            break;
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
