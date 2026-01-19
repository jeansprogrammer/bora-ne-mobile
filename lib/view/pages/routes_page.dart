import 'package:flutter/material.dart';
import '../widgets/detalhe_local_sheet.dart';

class ListaReligiososPage extends StatelessWidget {
  const ListaReligiososPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locais = [
      {
        "titulo": "Seminário São José",
        "img": "assets/seminario.jpg",
        "nota": 5,
      },
      {
        "titulo": "Catedral de Santo Antônio",
        "img": "assets/catedral.jpg",
        "nota": 5,
      },
      {
        "titulo": "Santuário Mãe Rainha",
        "img": "assets/santuario.jpg",
        "nota": 5,
      },
      {
        "titulo": "Mosteiro de São Bento",
        "img": "assets/mosteiro.jpg",
        "nota": 4,
      },
      {
        "titulo": "Mirante Cristo do Magano",
        "img": "assets/magano.jpg",
        "nota": 5,
      },
    ];

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
              const Text(
                "Locais Religiosos",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: locais.length,
                  itemBuilder: (context, index) {
                    final item = locais[index];
                    return _itemCard(
                      context,
                      titulo: item["titulo"] as String,
                      img: item["img"] as String,
                      nota: item["nota"] as int,
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
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
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
          builder: (_) {
            return DetalheLocalSheet(titulo: titulo, img: img, nota: nota);
          },
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        Icons.star,
                        size: 18,
                        color: i < nota ? Colors.orange : Colors.grey[300],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "307 Favoritos",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
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
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
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
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class DetalheLocalPage extends StatelessWidget {
  final String titulo;

  const DetalheLocalPage({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Text("Página do local: $titulo", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
