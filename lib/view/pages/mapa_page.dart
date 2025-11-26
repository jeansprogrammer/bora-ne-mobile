import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 530,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: MapLibreMap(
                    styleString:
                        "https://maps.geoapify.com/v1/styles/osm-bright/style.json?apiKey=6257076878834395a36b96b113242568",
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-8.8908, -36.4969), // Garanhuns
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      // salvar o controller:
                      // _mapController = controller;
                    },
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "O que você está procurando?",
                            ),
                          ),
                        ),
                        const Icon(Icons.search, size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Relógio das Flores",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star, color: Colors.orange, size: 20),
                        Icon(Icons.star_half,
                            color: Colors.orange, size: 20),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Praça Tavares Corrêa, 157 - Heliópolis, Garanhuns - PE, 55296-300",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 90,
                          color: Colors.grey[300],
                          child: const Center(child: Text("IMAGEM 1")),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 90,
                          color: Colors.grey[300],
                          child: const Center(child: Text("IMAGEM 2")),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.home, size: 28), Text("Início")],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.favorite_border, size: 28), Text("Favoritos")],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none, size: 28),
                Text("Notificações")
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.person_outline, size: 28), Text("Perfil")],
            ),
          ],
        ),
      ),
    );
  }
}
