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

  // Estilo padrão mantido
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
          child: Image.asset('assets/images/logo_bora_ne.png', height: 40),
        ),
        actions: [const SizedBox(width: 48)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildPhotoUploadArea(controller),
            const SizedBox(height: 24),
            _buildSectionTitle("Nome da rota"),
            TextField(
              onChanged: controller.setName,
              decoration: _inputStyle(
                "Ex: Rota Gastronômica",
                Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Categoria"),
            DropdownButtonFormField<String>(
              decoration: _inputStyle(
                "Selecione a categoria",
                Icons.grid_view_rounded,
              ),
              items: [
                "Religioso",
                "Lazer",
                "Gastronomia",
                "Aventura",
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => controller.setCategory(v!),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Descrição"),
            TextField(
              onChanged: controller.setDescription,
              maxLines: 4,
              maxLength: 500,
              decoration: _inputStyle(
                "Descreva sua rota...",
                Icons.edit_outlined,
              ),
            ),
            const Divider(height: 32),
            _buildSectionTitle("Adicionar locais (máx. 10)"),
            _buildSearchField(controller),
            const SizedBox(height: 8),
            _buildAddedPlacesList(controller),
            const SizedBox(height: 30),
            _buildActionButtons(context, controller),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA MANTER O BUILD LIMPO ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildPhotoUploadArea(RouteCreationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ÁREA DE CLIQUE PARA UPLOAD
        InkWell(
          onTap: () => controller.selecionarFotos(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
            ),
            child: Column(
              children: const [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: Colors.orangeAccent,
                ),
                SizedBox(height: 12),
                Text(
                  "Adicionar fotos da rota",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "Toque para fazer upload",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ),

        // LISTA DE MINIATURAS (Só aparece se houver fotos)
        if (controller.fotosSelecionadas.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.fotosSelecionadas.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(controller.fotosSelecionadas[index]),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    // BOTÃO PARA REMOVER A FOTO
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => controller.removerFoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(RouteCreationController controller) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: _inputStyle(
            "Buscar local...",
            Icons.location_on_outlined,
          ),
          onChanged: (val) async {
            if (val.length > 2) {
              // Chamada real ao Firestore via Controller
              final resultados = await controller.pesquisarLocais(val);
              setState(() {
                searchResults = resultados;
              });
            } else {
              setState(() => searchResults = []);
            }
          },
        ),
        if (searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black12),
              ],
            ),
            child: Column(
              children: searchResults
                  .map(
                    (place) => ListTile(
                      leading: const Icon(
                        Icons.place,
                        color: Colors.orangeAccent,
                      ),
                      title: Text(place["name"]),
                      onTap: () {
                        controller.addPlace(
                          place["name"],
                          place["lat"],
                          place["lon"],
                        );
                        _searchController.clear();
                        setState(() => searchResults = []);
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAddedPlacesList(RouteCreationController controller) {
    return Column(
      children: controller.newRoute.places
          .asMap()
          .entries
          .map(
            (entry) => Card(
              margin: const EdgeInsets.only(top: 10),
              child: ListTile(
                leading: const Icon(Icons.drag_indicator, color: Colors.grey),
                title: Text(entry.value.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () => controller.removePlace(entry.key),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RouteCreationController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: controller.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.map_outlined, color: Colors.black),
            label: Text(
              controller.isSaving ? "Salvando..." : "Salvar rota",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: (controller.isSaving || !controller.isValid)
                ? null
                : () async {
                    if (await controller.saveRoute()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Rota salva com sucesso!"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
