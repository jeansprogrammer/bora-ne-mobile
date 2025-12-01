import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/route_creation_controller.dart';
import '../../../models/route_creation_model.dart';

class NewRoutePage extends StatefulWidget {
  const NewRoutePage({super.key});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RouteCreationController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar nova rota"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotos
            const Text("Fotos da rota"),
            const SizedBox(height: 6),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text("Upload de fotos (placeholder)"),
              ),
            ),

            const SizedBox(height: 20),

            // Nome
            const Text("Nome da rota"),
            TextField(
              onChanged: controller.setName,
              decoration: const InputDecoration(
                hintText: "Ex: Rota Gastronômica",
              ),
            ),

            const SizedBox(height: 20),

            // Categoria
            const Text("Categoria"),
            DropdownButtonFormField<String>(
              value: controller.newRoute.category.isEmpty
                  ? null
                  : controller.newRoute.category,
              items: const [
                DropdownMenuItem(value: "Religioso", child: Text("Religioso")),
                DropdownMenuItem(value: "Gastronômico", child: Text("Gastronômico")),
                DropdownMenuItem(value: "Histórico", child: Text("Histórico")),
                DropdownMenuItem(value: "Aventura", child: Text("Aventura")),
              ],
              onChanged: (value) => controller.setCategory(value!),
              decoration: const InputDecoration(hintText: "Selecione a categoria"),
            ),

            const SizedBox(height: 20),

            // Descrição
            const Text("Descrição"),
            TextField(
              onChanged: controller.setDescription,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Descreva sua rota...",
              ),
            ),

            const SizedBox(height: 25),

            // Buscar local
            const Text("Adicionar locais (máx. 10)"),
            const SizedBox(height: 6),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar local...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final results = await controller.searchPlace(_searchController.text);
                    setState(() => searchResults = results);
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Lista de resultados
            ...searchResults.map((place) {
              return ListTile(
                title: Text(place["name"]),
                trailing: controller.canAddMorePlaces
                    ? const Icon(Icons.add)
                    : const Icon(Icons.block, color: Colors.red),
                onTap: () {
                  if (!controller.canAddMorePlaces) return;

                  controller.addPlace(
                    PlaceModel(
                      name: place["name"],
                      position: controller.geoapify.convertToLatLng(
                        place["lat"],
                        place["lon"],
                      ),
                    ),
                  );

                  _searchController.clear();
                  setState(() => searchResults.clear());
                },
              );
            }),

            const SizedBox(height: 20),

            // Locais adicionados
            if (controller.newRoute.places.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Locais adicionados:"),
                  const SizedBox(height: 10),

                  ...controller.newRoute.places.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final place = entry.value;

                      return Card(
                        child: ListTile(
                          title: Text(place.name),
                          subtitle: Text(
                              "Lat: ${place.position.latitude}, Lon: ${place.position.longitude}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removePlace(index),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 40),

            // Botões finais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.saveRoute();
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar rota"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
