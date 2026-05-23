import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/route_creation_controller.dart';
import '../../../models/destino_model.dart';
import 'new_place_page.dart';

class NewRoutePage extends StatefulWidget {
  const NewRoutePage({super.key});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DestinoModel> _searchResults = [];

  final List<String> _categoriasDisponiveis = [
    'Religioso', 'Lazer', 'Gastronomia', 'Aventura',
    'Cultural', 'Histórico', 'Natural', 'Compras',
  ];

  final List<String> _cidadesDisponiveis = [
    'Recife', 'Caruaru', 'Garanhuns', 'Fortaleza', 'Salvador',
    'Natal', 'João Pessoa', 'Maceió', 'Aracaju', 'Teresina',
    'São Luís', 'Campina Grande', 'Mossoró', 'Petrolina', 'Juazeiro do Norte',
  ];

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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
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
            _buildFotoCapa(controller),
            const SizedBox(height: 24),
            _buildSectionTitle("Título da rota"),
            TextField(
              onChanged: controller.setName,
              decoration: _inputStyle("Ex: Rota Gastronômica de Caruaru", Icons.route_outlined),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Descrição"),
            TextField(
              onChanged: controller.setDescription,
              maxLines: 4,
              maxLength: 500,
              decoration: _inputStyle("Descreva brevemente sua rota...", Icons.edit_outlined),
            ),
            const SizedBox(height: 4),
            _buildSectionTitle("Categorias"),
            _buildCategoriasField(controller),
            const SizedBox(height: 20),
            _buildSectionTitle("Cidade"),
            _buildCidadeDropdown(controller),
            const SizedBox(height: 20),
            const Divider(height: 32),
            _buildSectionTitle("Destinos (máx. 10)"),
            _buildBuscaDestinos(controller),
            const SizedBox(height: 8),
            _buildDestinosAdicionados(controller),
            const SizedBox(height: 30),
            _buildActionButtons(context, controller),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── FOTO CAPA — idêntico ao new_place_page ────────────────────────────────

  Widget _buildFotoCapa(RouteCreationController controller) {
    final temUrl = controller.urlFotoCapaManual.isNotEmpty;
    final temArquivo = controller.fotos.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Foto de capa"),
        Text("Toque para selecionar do dispositivo",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),

        // Preview da URL
        if (temUrl && !temArquivo) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              controller.urlFotoCapaManual,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Center(
                  child: Text("URL inválida ou imagem não encontrada",
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ),
          ),
        ],

        // Botão de upload
        GestureDetector(
          onTap: controller.selecionarFotos,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 40, color: Colors.orangeAccent),
                SizedBox(height: 8),
                Text("Selecionar do dispositivo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 2),
                Text("Requer Firebase Storage (plano pago)",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),

        // Grid de fotos selecionadas
        if (temArquivo) ...[
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.fotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, index) {
              final isCapa = index == controller.indiceFotoCapa;
              return GestureDetector(
                onTap: () => controller.definirFotoCapa(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(controller.fotos[index], fit: BoxFit.cover),
                    ),
                    if (isCapa)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orangeAccent, width: 3),
                          color: Colors.orangeAccent.withOpacity(0.15),
                        ),
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("CAPA",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removerFoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text("Toque na foto para defini-la como capa",
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ],
    );
  }

  // ── CATEGORIAS ────────────────────────────────────────────────────────────

  Widget _buildCategoriasField(RouteCreationController controller) {
    final selecionadas = controller.categoriasSelecionadas;

    return GestureDetector(
      onTap: () => _abrirPopupCategorias(context, controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionadas.isEmpty ? Colors.black12 : Colors.orangeAccent,
            width: selecionadas.isEmpty ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: Colors.orangeAccent, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: selecionadas.isEmpty
                  ? const Text("Selecione as categorias",
                      style: TextStyle(color: Colors.grey, fontSize: 14))
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: selecionadas.map((cat) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(cat,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _abrirPopupCategorias(BuildContext context, RouteCreationController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Selecione as categorias",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Você pode selecionar mais de uma",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _categoriasDisponiveis.map((cat) {
                  final sel = controller.categoriasSelecionadas.contains(cat);
                  return GestureDetector(
                    onTap: () { controller.toggleCategoria(cat); setModal(() {}); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? Colors.orangeAccent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? Colors.orangeAccent : Colors.black12),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.3),
                                blurRadius: 6, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sel)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          Text(cat,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? Colors.white : Colors.black87)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    controller.categoriasSelecionadas.isEmpty
                        ? "Confirmar"
                        : "Confirmar (${controller.categoriasSelecionadas.length})",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CIDADE ────────────────────────────────────────────────────────────────

  Widget _buildCidadeDropdown(RouteCreationController controller) {
    return DropdownButtonFormField<String>(
      value: controller.cidadeSelecionada.isEmpty ? null : controller.cidadeSelecionada,
      decoration: _inputStyle("Selecione a cidade", Icons.location_city),
      items: _cidadesDisponiveis
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) { if (v != null) controller.setCidade(v); },
    );
  }

  // ── BUSCA DE DESTINOS ─────────────────────────────────────────────────────

  Widget _buildBuscaDestinos(RouteCreationController controller) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: _inputStyle("Buscar destino pelo nome...", Icons.search),
          onChanged: (val) async {
            if (val.length > 2) {
              final resultados = await controller.pesquisarDestinos(val);
              setState(() => _searchResults = resultados);
            } else {
              setState(() => _searchResults = []);
            }
          },
        ),

        if (controller.isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              color: Colors.orangeAccent,
              backgroundColor: Color(0xFFFFF9E7),
            ),
          ),

        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
            ),
            child: Column(
              children: _searchResults.map((destino) {
                return _buildSearchResultItem(destino, controller);
              }).toList(),
            ),
          ),

        if (_searchResults.isEmpty &&
            _searchController.text.length > 2 &&
            !controller.isSearching)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_location_alt_outlined, color: Colors.orangeAccent),
              label: const Text("Criar novo destino",
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.orangeAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _abrirCriarNovoDestino(context),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResultItem(DestinoModel destino, RouteCreationController controller) {
    return InkWell(
      onTap: () {
        controller.addDestino(destino);
        _searchController.clear();
        setState(() => _searchResults = []);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: destino.fotoCapa.isNotEmpty
                  ? Image.network(destino.fotoCapa,
                      width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconePlaceholder())
                  : _iconePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destino.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  if (destino.categorias.isNotEmpty)
                    Text(destino.categorias.join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.orangeAccent)),
                  Text(destino.local,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline, color: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _iconePlaceholder() {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.orangeAccent),
    );
  }

  // ── DESTINOS ADICIONADOS ──────────────────────────────────────────────────

  Widget _buildDestinosAdicionados(RouteCreationController controller) {
    if (controller.destinosSelecionados.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "${controller.destinosSelecionados.length} destino(s) adicionado(s)",
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        ...controller.destinosSelecionados.asMap().entries.map((entry) {
          return _buildDestinoCard(entry.value, entry.key, controller);
        }),
      ],
    );
  }

  Widget _buildDestinoCard(DestinoModel destino, int index, RouteCreationController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: destino.fotoCapa.isNotEmpty
                ? Image.network(destino.fotoCapa,
                    width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _cardImagePlaceholder())
                : _cardImagePlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(destino.nome,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (destino.categorias.isNotEmpty)
                    Text(destino.categorias.join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.orangeAccent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(destino.local,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => controller.removeDestino(index),
          ),
        ],
      ),
    );
  }

  Widget _cardImagePlaceholder() {
    return Container(
      width: 90, height: 90,
      color: const Color(0xFFFFF9E7),
      child: const Icon(Icons.image_outlined, color: Colors.orangeAccent, size: 32),
    );
  }

  // ── POPUP — Criar novo destino ────────────────────────────────────────────

  void _abrirCriarNovoDestino(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Criar novo destino",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Este destino não existe ainda. Deseja cadastrá-lo?",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt, color: Colors.black),
                label: const Text("Ir para cadastro de destino",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
  Navigator.pop(context); // fecha o bottomsheet
  
  // Navega para criar destino e aguarda o retorno
  final destinoCriado = await Navigator.push<DestinoModel>(
    context,
    MaterialPageRoute(builder: (_) => const NewPlacePage()),
  );

  // Se voltou com destino criado, adiciona na rota automaticamente
  if (destinoCriado != null && context.mounted) {
    final controller = Provider.of<RouteCreationController>(
        context, listen: false);
    controller.addDestino(destinoCriado);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("📍 ${destinoCriado.nome} adicionado à rota!"),
        backgroundColor: Colors.green,
      ),
    );
  }
},
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTÕES DE AÇÃO ────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, RouteCreationController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: controller.isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.map_outlined, color: Colors.black),
            label: Text(
              controller.isSaving ? "Salvando..." : "Criar rota",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            onPressed: (controller.isSaving || !controller.isValid)
                ? null
                : () async {
                    if (await controller.saveRoute()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ Rota criada com sucesso!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("⚠️ Preencha nome, categoria e pelo menos um destino."),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}