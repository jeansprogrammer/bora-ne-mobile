import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/route_creation_controller.dart';

class NewRoutePage extends StatefulWidget {
  const NewRoutePage({super.key});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  // Estilo padrão para os campos de entrada conforme a imagem
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RouteCreationController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Image.asset('assets/images/logo_bora_ne.png', height: 40), // Substitua pelo seu asset de logo
        ),
        actions: [const SizedBox(width: 48)], // Para centralizar a logo
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // ÁREA DE UPLOAD DE FOTOS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.orangeAccent),
                  const SizedBox(height: 12),
                  const Text("Adicionar fotos da rota", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text("Toque para fazer upload", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // NOME DA ROTA
            const Text("Nome da rota", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.setName,
              decoration: _inputStyle("Ex: Rota Gastronômica", Icons.location_on_outlined),
            ),
            const SizedBox(height: 20),

            // CATEGORIA
            const Text("Category", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: _inputStyle("Selecione a categoria", Icons.grid_view_rounded),
              icon: const Icon(Icons.arrow_drop_down),
              items: ["Religioso", "Lazer", "Gastronomia", "Aventura"]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => controller.setCategory(v!),
            ),
            const SizedBox(height: 20),

            // DESCRIÇÃO
            const Text("Descrição", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.setDescription,
              maxLines: 4,
              maxLength: 500,
              decoration: _inputStyle("Descreva sua rota...", Icons.edit_outlined),
            ),
            
            const Divider(height: 32),

            // BUSCAR LOCAL
            const Text("Adicionar locais (máx. 10)", style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: _inputStyle("Buscar local...", Icons.location_on_outlined),
              onChanged: (val) {
                // Simulação de busca para preencher a lista
                if (val.length > 2) {
                  setState(() {
                    searchResults = [
                      {"name": "Pelourinho, Salvador", "lat": -12.97, "lon": -38.51},
                      {"name": "Marco Zero, Recife", "lat": -8.06, "lon": -34.87},
                    ];
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            const Text("ⓘ Adicione até 10 locais para compor sua rota.", 
              style: TextStyle(color: Colors.grey, fontSize: 11)),

            // RESULTADOS DA BUSCA (Aparecem flutuando ou abaixo)
            if (searchResults.isNotEmpty)
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [const BoxShadow(blurRadius: 4, color: Colors.black12)]),
                child: Column(
                  children: searchResults.map((place) => ListTile(
                    title: Text(place["name"]),
                    onTap: () {
                      controller.addPlace(place["name"], place["lat"], place["lon"]);
                      _searchController.clear();
                      setState(() => searchResults = []);
                    },
                  )).toList(),
                ),
              ),

            // LISTA DE ITINERÁRIO (Locais já adicionados)
            ...controller.newRoute.places.asMap().entries.map((entry) => Card(
              margin: const EdgeInsets.only(top: 10),
              child: ListTile(
                leading: const Icon(Icons.drag_indicator, color: Colors.grey),
                title: Text(entry.value.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () => controller.removePlace(entry.key),
                ),
              ),
            )),

            const SizedBox(height: 30),

            // BOTÕES DE AÇÃO (CANCELAR / SALVAR)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.black45),
                    ),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.map_outlined, color: Colors.black),
                    label: const Text("Salvar rota", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    onPressed: (controller.isSaving || !controller.isValid) ? null : () async {
                      if (await controller.saveRoute()) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Espaço para a BottomNavigationBar
          ],
        ),
      ),
    );
  }
}