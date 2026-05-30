import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/route_creation_controller.dart';
import '../../models/destination_model.dart';
import '../widgets/confirm_exit_dialog.dart';
import 'new_destination_page.dart';

class NewRoutePage extends StatefulWidget {
  const NewRoutePage({super.key});

  @override
  State<NewRoutePage> createState() => _NewRoutePageState();
}

class _NewRoutePageState extends State<NewRoutePage> {
  final TextEditingController _searchController = TextEditingController();
  List<DestinationModel> _searchResults = [];

  bool _temDados(RouteCreationController c) =>
      c.newRoute.name.isNotEmpty ||
      c.categoriasSelecionadas.isNotEmpty ||
      c.cidadeSelecionada.isNotEmpty ||
      c.DestinationsSelecionados.isNotEmpty ||
      c.fotos.isNotEmpty ||
      c.urlFotoCapaManual.isNotEmpty;

  Future<bool> _confirmarSaida(RouteCreationController controller) async {
    if (!_temDados(controller)) return true;
    final sair = await ConfirmExitDialog.show(context);
    if (sair) controller.resetar();
    return sair;
  }

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

    return WillPopScope(
      onWillPop: () => _confirmarSaida(controller),
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            if (await _confirmarSaida(controller)) Navigator.pop(context);
          },
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
            _buildBuscaDestinations(controller),
            const SizedBox(height: 8),
            _buildDestinationsAdicionados(controller),
            const SizedBox(height: 30),
            _buildActionButtons(context, controller),
            const SizedBox(height: 80),
          ],
        ),
      ),
    ));
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
    final temDestinos = controller.DestinationsSelecionados.isNotEmpty;

    return GestureDetector(
      onTap: temDestinos ? () => _mostrarPopupCidadeBloqueada(context) : null,
      child: AbsorbPointer(
        absorbing: temDestinos,
        child: DropdownButtonFormField<String>(
          value: controller.cidadeSelecionada.isEmpty
              ? null
              : controller.cidadeSelecionada,
          decoration: InputDecoration(
            hintText: "Selecione a cidade",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(
              Icons.location_city,
              color: temDestinos ? Colors.grey : Colors.orangeAccent,
              size: 22,
            ),
            suffixIcon: temDestinos
                ? const Icon(Icons.lock_outline, color: Colors.grey, size: 20)
                : null,
            filled: true,
            fillColor: temDestinos ? Colors.grey.shade100 : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: temDestinos ? Colors.grey.shade300 : Colors.grey,
                  width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: temDestinos ? Colors.grey.shade300 : Colors.black12,
                  width: 1),
            ),
          ),
          items: _cidadesDisponiveis
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: temDestinos
              ? null
              : (v) { if (v != null) controller.setCidade(v); },
        ),
      ),
    );
  }

  void _mostrarPopupCidadeBloqueada(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orangeAccent, size: 22),
            SizedBox(width: 8),
            Text('Cidade bloqueada',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Você já adicionou destinos desta cidade à rota.\n\n'
          'Para trocar a cidade, remova todos os destinos adicionados primeiro.',
          style: TextStyle(
              color: Colors.black54, fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Entendi',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── BUSCA DE DESTINOS ─────────────────────────────────────────────────────

  Widget _buildBuscaDestinations(RouteCreationController controller) {
    final cidadeSelecionada = controller.cidadeSelecionada.isNotEmpty;
    return Column(
      children: [
        // Campo bloqueado se cidade não selecionada
        Opacity(
          opacity: cidadeSelecionada ? 1.0 : 0.5,
          child: AbsorbPointer(
            absorbing: !cidadeSelecionada,
            child: TextField(
              controller: _searchController,
              decoration: _inputStyle(
                cidadeSelecionada
                    ? "Buscar Destino pelo nome..."
                    : "Selecione a cidade primeiro",
                Icons.search,
              ),
              onChanged: (val) async {
                if (val.length > 2) {
                  final resultados = await controller.pesquisarDestinations(val);
                  setState(() => _searchResults = resultados);
                } else {
                  setState(() => _searchResults = []);
                }
              },
            ),
          ),
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
              children: _searchResults.map((Destination) {
                return _buildSearchResultItem(Destination, controller);
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
              label: const Text("Criar novo Destino",
                  style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.orangeAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _abrirCriarNovoDestination(context),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResultItem(DestinationModel Destination, RouteCreationController controller) {
    return InkWell(
      onTap: () {
        controller.addDestination(Destination);
        _searchController.clear();
        setState(() => _searchResults = []);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Destination.coverPhoto.isNotEmpty
                  ? Image.network(Destination.coverPhoto,
                      width: 52, height: 52, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _iconePlaceholder())
                  : _iconePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Destination.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  if (Destination.categories.isNotEmpty)
                    Text(Destination.categories.join(', '),
                        style: const TextStyle(fontSize: 12, color: Colors.orangeAccent)),
                  Text(Destination.local,
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

  // ── DESTINOS ADICIONADOS — reordenável ───────────────────────────────────

  Widget _buildDestinationsAdicionados(RouteCreationController controller) {
    if (controller.DestinationsSelecionados.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            "${controller.DestinationsSelecionados.length} Destino(s) — arraste para reordenar",
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false, // ← desativa handle automático da direita
          itemCount: controller.DestinationsSelecionados.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            controller.reordenarDestination(oldIndex, newIndex);
          },
          itemBuilder: (_, index) {
            final Destination = controller.DestinationsSelecionados[index];
            return _buildDestinationCard(Destination, index, controller,
                key: ValueKey(Destination.name));
          },
        ),
      ],
    );
  }

  Widget _buildDestinationCard(DestinationModel Destination, int index,
      RouteCreationController controller, {Key? key}) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Número fora do card ───────────────────────────────────────────
        SizedBox(
          width: 28,
          child: Text(
            "${index + 1}",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 6),

        // ── Card ──────────────────────────────────────────────────────────
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
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
                // Handle de drag — envolto em ReorderableDragStartListener
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    width: 36,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.drag_handle,
                        color: Colors.grey, size: 22),
                  ),
                ),

                // Imagem
                ClipRRect(
                  child: Destination.coverPhoto.isNotEmpty
                      ? Image.network(Destination.coverPhoto,
                          width: 80, height: 90, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _cardImagePlaceholder())
                      : _cardImagePlaceholder(),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Destination.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        if (Destination.categories.isNotEmpty)
                          Text(Destination.categories.join(', '),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orangeAccent)),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(Destination.local,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Botão remover — separado do drag
                IconButton(
                  onPressed: () => controller.removeDestination(index),
                  icon: const Icon(Icons.close,
                      color: Colors.red, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                      minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cardImagePlaceholder() {
    return Container(
      width: 90, height: 90,
      color: const Color(0xFFFFF9E7),
      child: const Icon(Icons.image_outlined, color: Colors.orangeAccent, size: 32),
    );
  }

  // ── POPUP — Criar novo Destino ────────────────────────────────────────────

  void _abrirCriarNovoDestination(BuildContext context) {
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
            const Text("Criar novo Destino",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text("Este Destino não existe ainda. Deseja cadastrá-lo?",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt, color: Colors.black),
                label: const Text("Ir para cadastro de Destino",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context); // fecha o bottomsheet

                  // Navega para criar Destino e aguarda o retorno
                  final destinationCriado = await Navigator.push<DestinationModel>(
                    context,
                    MaterialPageRoute(builder: (_) => const NewDestinationPage()),
                  );

                  // Se voltou com Destino criado, adiciona na rota automaticamente
                  if (destinationCriado != null && context.mounted) {
                    final controller = Provider.of<RouteCreationController>(
                        context, listen: false);
                    controller.addDestination(destinationCriado);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("📍 ${destinationCriado.name} adicionado à rota!"),
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
    return Column(
      children: [
        // Chips de validação
        if (!controller.isValid)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (controller.newRoute.name.isEmpty)
                  _chip("Título obrigatório"),
                if (controller.categoriasSelecionadas.isEmpty)
                  _chip("Categoria obrigatória"),
                if (controller.cidadeSelecionada.isEmpty)
                  _chip("Cidade obrigatória"),
                if (controller.DestinationsSelecionados.length < 3)
                  _chip("Mínimo 3 Destinos (${controller.DestinationsSelecionados.length}/3)"),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  if (await _confirmarSaida(controller)) Navigator.pop(context);
                },
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
                              content: Text("⚠️ Verifique os campos obrigatórios."),
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
        ),
      ],
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
    );
  }
}