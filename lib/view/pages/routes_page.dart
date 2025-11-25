import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/route_card.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  String selectedFilter = 'Relevância';

  final List<Map<String, dynamic>> routes = [
    {
      "title": "Praias da Região",
      "createdBy": "João Mendes",
      "image": "assets/images/praia.jpg",
    },
    {
      "title": "Centro Histórico",
      "createdBy": "Ana Lima",
      "image": "assets/images/catedral.jpg",
    },
    {
      "title": "Rota Gastronômica",
      "createdBy": "Pedro Silva",
      "image": "assets/images/food.jpg",
    },
  ];

  void openFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Relevância (curtidas)"),
              onTap: () {
                setState(() => selectedFilter = "Relevância");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Ordem alfabética"),
              onTap: () {
                setState(() => selectedFilter = "Ordem alfabética");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Categoria"),
              onTap: () {
                setState(() => selectedFilter = "Categoria");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 253, 245, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Rotas",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: openFilterMenu,
            icon: const Icon(Icons.filter_list, color: Colors.black),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final r = routes[index];
            return RouteCard(
              title: r["title"],
              createdBy: r["createdBy"],
              imagePath: r["image"],
              onTap: () {
                // Você coloca sua navegação aqui depois
              },
              onFavorite: () {
                // lógica futura para favoritar
              },
            );
          },
        ),
      ),
    );
  }
}
