import 'package:flutter/material.dart';

class NewPlacePage extends StatefulWidget {
  const NewPlacePage({super.key});

  @override
  State<NewPlacePage> createState() => _NewPlacePageState();
}

class _NewPlacePageState extends State<NewPlacePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final List<String> photos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Local"),
        backgroundColor: Colors.orange,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------
            // FOTOS DO LOCAL
            // --------------------------
            const Text(
              "Fotos",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Botão adicionar foto
                  GestureDetector(
                    onTap: () {
                      // TODO: implementar picker de imagem
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(Icons.add_a_photo, size: 32),
                    ),
                  ),

                  // Fotos já adicionadas
                  ...photos.map(
                    (img) => Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: AssetImage(img),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------
            // NOME DO LOCAL
            // --------------------------
            const Text("Nome do local"),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              decoration: customInput("Ex: Restaurante Lua Cheia"),
            ),

            const SizedBox(height: 20),

            // --------------------------
            // CATEGORIA
            // --------------------------
            const Text("Categoria"),
            const SizedBox(height: 6),
            TextField(
              controller: categoryController,
              decoration: customInput("Ex: Restaurante, Museu, Ponto turístico"),
            ),

            const SizedBox(height: 20),

            // --------------------------
            // HORÁRIO DE FUNCIONAMENTO
            // --------------------------
            const Text("Horário de funcionamento"),
            const SizedBox(height: 6),
            TextField(
              controller: openHoursController,
              decoration: customInput("Ex: 08:00 às 18:00"),
            ),

            const SizedBox(height: 20),

            // --------------------------
            // ENDEREÇO (Geoapify pode ser usado)
            // --------------------------
            const Text("Endereço"),
            const SizedBox(height: 6),
            TextField(
              controller: addressController,
              decoration: customInput("Buscar endereço..."),
              onTap: () {
                /// 🔥 Aqui você chama o autocomplete do Geoapify
                ///
                /// Exemplo:
                /// Navigator.push(context, MaterialPageRoute(
                ///   builder: (_) => AddressSearchPage(),
                /// ));
              },
            ),

            const SizedBox(height: 20),

            // --------------------------
            // CONTATO
            // --------------------------
            const Text("Contato"),
            const SizedBox(height: 6),
            TextField(
              controller: contactController,
              decoration: customInput("Ex: (87) 99999-9999"),
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 40),

            // --------------------------
            // BOTÕES
            // --------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Salvar
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: salvar local no controller
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Salvar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  InputDecoration customInput(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
