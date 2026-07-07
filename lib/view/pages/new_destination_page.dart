import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/destination_creation_controller.dart';
import '../widgets/confirm_exit_dialog.dart';
import '../widgets/confirm_delete_destination_dialog.dart';
import '../../data/category_data.dart';
import '../../data/nordeste_data.dart';

class NewDestinationPage extends StatefulWidget {
  // Quando != null, a página abre em modo EDIÇÃO (só título, categorias e descrição).
  final Map<String, dynamic>? destinoParaEditar;
  final String? destinoId;

  const NewDestinationPage({
    super.key,
    this.destinoParaEditar,
    this.destinoId,
  });

  @override
  State<NewDestinationPage> createState() => _NewDestinationPageState();
}

class _NewDestinationPageState extends State<NewDestinationPage> {
  // Controller criado no State para ter acesso direto sem depender do Consumer
  late final DestinationCreationController _controller;

  // Controllers de texto dos campos editáveis (permitem pré-preencher na edição)
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  bool get _editando => widget.destinoParaEditar != null;

  @override
  void initState() {
    super.initState();
    _controller = DestinationCreationController();

    // Modo edição: carrega os dados salvos e pré-preenche os campos
    if (_editando) {
      _controller.carregarParaEdicao(
        widget.destinoParaEditar!,
        id: widget.destinoId,
      );
      _nomeController.text = _controller.nome;
      _descricaoController.text = _controller.descricao;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _controller.dispose();
    _cepController.dispose();
    super.dispose();
  }

  bool _temDados() =>
      _controller.nome.isNotEmpty ||
      _controller.categoriasSelecionadas.isNotEmpty ||
      _controller.city.isNotEmpty ||
      _controller.fotos.isNotEmpty ||
      _controller.urlImagemManual.isNotEmpty;

  Future<bool> _confirmarSaida() async {
    if (!_temDados()) return true;
    final sair = await ConfirmExitDialog.show(context);
    if (sair) _controller.resetar();
    return sair;
  }

 final categorias = nomesCategorias;

  // Controller do CEP — separado pois não é gerenciado pelo controller MVC
  final TextEditingController _cepController = TextEditingController();

  // ── Estilos ──────────────────────────────────────────────────────────────

  InputDecoration _inputStyle(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.orangeAccent, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5),
      ),
    );
  }

  // Campo preenchido automaticamente (read-only visual diferenciado)
  InputDecoration _inputAutoStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.green, size: 20),
      suffixIcon: const Icon(
        Icons.auto_fix_high,
        color: Colors.green,
        size: 16,
      ),
      filled: true,
      fillColor: const Color(0xFFF0FFF4), // verde bem clarinho
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DestinationCreationController>.value(
      value: _controller,
      child: Consumer<DestinationCreationController>(
        builder: (context, controller, _) {
          return WillPopScope(
            onWillPop: _confirmarSaida,
            child: Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: (controller.isSaving ||
                      controller.isBuscandoCoordenadas)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.orangeAccent,
                          minHeight: 4,
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            controller.isBuscandoCoordenadas
                                ? 'Verificando endereço...'
                                : 'Fazendo upload das imagens...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ],
                    )
                  : null,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () async {
                    if (await _confirmarSaida()) Navigator.pop(context);
                  },
                ),
                title: Center(
                  child: Image.asset(
                    'assets/images/LOGO_V2_1.png',
                    height: 40,
                  ),
                ),
                actions: [const SizedBox(width: 48)],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (!_editando) ...[
                      _buildFotos(controller),
                      const SizedBox(height: 24),
                    ] else ...[
                      const Text(
                        'Editar destino',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Você pode alterar as fotos, o título, as categorias e a descrição.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      _buildFotosExistentes(controller),
                      _buildFotos(controller),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _sectionTitle("Nome do Destino")),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (controller.nome.isEmpty) _chip("Nome obrigatório"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _nomeController,
                      onChanged: controller.setNome,
                      decoration: _inputStyle(
                        "Ex: Restaurante Lua Cheia",
                        Icons.place_outlined,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle("Descrição"),
                    TextField(
                      controller: _descricaoController,
                      onChanged: controller.setDescricao,
                      maxLines: 3,
                      maxLength: 300,
                      decoration: _inputStyle(
                        "Descreva brevemente o Destino...",
                        Icons.edit_outlined,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _sectionTitle("Categorias")),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 220),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (controller.categoriasSelecionadas.isEmpty) _chip("Categoria obrigatória"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildCategoriasField(controller),
                    const SizedBox(height: 20),
                    if (!_editando) ...[
                      const Divider(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _sectionTitle(
                              "Endereço",
                              subtitle: "Digite o CEP para preencher automaticamente",
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  if (controller.city.isEmpty) _chip("Cidade obrigatória"),
                                  if (controller.uf.isEmpty) _chip("UF obrigatória"),
                                  if (controller.latitude == 0.0) _chip("Localização obrigatória"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildEndereco(controller),
                      const SizedBox(height: 30),
                    ] else
                      const SizedBox(height: 10),
                    _buildActionButtons(context, controller),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── FOTOS EXISTENTES (modo edição) ───────────────────────────────────────

  Widget _buildFotosExistentes(DestinationCreationController controller) {
    final fotosUrls = controller.photosExistentes;
    if (fotosUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          "Fotos atuais",
          subtitle: "Toque para definir como capa",
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fotosUrls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, index) {
            final url = fotosUrls[index];
            final isCapa = !controller.capaEhNova && url == controller.coverExistente;
            return GestureDetector(
              onTap: () => controller.definirCapaExistente(index),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFF9E7),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "CAPA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => controller.removerFotoExistente(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── FOTOS ────────────────────────────────────────────────────────────────

  Widget _buildFotos(DestinationCreationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          "Fotos do Destino",
          subtitle: "Toque em uma foto para definir como capa",
        ),
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
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 40,
                  color: Colors.orangeAccent,
                ),
                SizedBox(height: 8),
                Text(
                  "Adicionar fotos",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  "Toque para selecionar do dispositivo",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (controller.fotos.isNotEmpty) ...[
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
              final isCapa = (!_editando || controller.capaEhNova) &&
                  index == controller.indiceFotoCapa;
              return GestureDetector(
                onTap: () => controller.definirFotoCapa(index),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        controller.fotos[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (isCapa)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.orangeAccent,
                            width: 3,
                          ),
                          color: Colors.orangeAccent.withOpacity(0.15),
                        ),
                        alignment: Alignment.topLeft,
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "CAPA",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.removerFoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          const Text(
            "Toque na foto para defini-la como capa",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // ── CATEGORIAS ───────────────────────────────────────────────────────────

  Widget _buildCategoriasField(DestinationCreationController controller) {
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
            const Icon(
              Icons.grid_view_rounded,
              color: Colors.orangeAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: selecionadas.isEmpty
                  ? const Text(
                      "Selecione as categorias",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: selecionadas
                          .map(
                            (cat) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _abrirPopupCategorias(
    BuildContext context,
    DestinationCreationController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Selecione as categorias",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Você pode selecionar mais de uma",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categorias.map((cat) {
                  final sel = controller.categoriasSelecionadas.contains(cat);
                  return GestureDetector(
                    onTap: () {
                      controller.toggleCategoria(cat);
                      setModal(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? Colors.orangeAccent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? Colors.orangeAccent : Colors.black12,
                        ),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                  color: Colors.orangeAccent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sel)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: sel ? Colors.white : Colors.black87,
                            ),
                          ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    controller.categoriasSelecionadas.isEmpty
                        ? "Confirmar"
                        : "Confirmar (${controller.categoriasSelecionadas.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ENDEREÇO ─────────────────────────────────────────────────────────────

  Widget _buildEndereco(DestinationCreationController controller) {
    final cidades = controller.uf.isNotEmpty
        ? cidadesDoEstado(controller.uf)
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── CEP ───────────────────────────────────────────────────────────
        const SizedBox(height: 6),
        TextField(
          controller: _cepController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          onChanged: (val) {
            if (val.length == 8) controller.buscarCep(val);
          },
          decoration: _inputStyle(
            'CEP (opcional)',
            Icons.markunread_mailbox_outlined,
            suffix: controller.isBuscandoCep
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.orangeAccent),
                    ))
                : controller.erroCep != null
                    ? const Icon(Icons.error_outline, color: Colors.red)
                    : controller.rua.isNotEmpty
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
          ),
        ),
        if (controller.erroCep != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(children: [
              const Icon(Icons.error_outline, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(controller.erroCep!,
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
            ]),
          ),
        const SizedBox(height: 12),

        // ── Rua + Número ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 4,
              child: TextField(
                controller: controller.ruaController,
                onChanged: controller.setRua,
                decoration: controller.rua.isNotEmpty
                    ? _inputAutoStyle('Rua / Av.', Icons.signpost_outlined)
                    : _inputStyle('Rua / Av.', Icons.signpost_outlined),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: TextField(
                onChanged: controller.setNumero,
                keyboardType: TextInputType.number,
                decoration: _inputStyle('Nº', Icons.tag),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Bairro ────────────────────────────────────────────────────────
        TextField(
          controller: controller.bairroController,
          onChanged: controller.setBairro,
          decoration: controller.bairro.isNotEmpty
              ? _inputAutoStyle('Bairro', Icons.location_city_outlined)
              : _inputStyle('Bairro', Icons.location_city_outlined),
        ),
        const SizedBox(height: 12),

        // ── Cidade + UF ───────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Opacity(
                opacity: controller.uf.isEmpty ? 0.4 : 1.0,
                child: AbsorbPointer(
                  absorbing: controller.uf.isEmpty,
                  child: DropdownButtonFormField<String>(
                    value: controller.city.isEmpty ? null : controller.city,
                    isExpanded: true,
                    decoration: _inputStyle(
                      controller.uf.isEmpty
                          ? 'Selecione o UF primeiro'
                          : 'Cidade',
                      Icons.location_on_outlined,
                    ),
                    items: cidades.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      );
                    }).toList(),
                    onChanged: (v) { if (v != null) controller.setCidade(v); },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: controller.uf.isEmpty ? null : controller.uf,
                isExpanded: true,
                decoration: _inputStyle('UF', Icons.map_outlined),
                items: siglaEstados.map((uf) {
                  return DropdownMenuItem(value: uf, child: Text(uf));
                }).toList(),
                onChanged: (v) { if (v != null) controller.setUf(v); },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  // ── BOTÕES ───────────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext context,
    DestinationCreationController controller,
  ) {
    return Column(
      children: [
        if (controller.erroMensagem != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.erroMensagem!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  if (await _confirmarSaida()) Navigator.pop(context);
                },
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
                icon: controller.isSaving || controller.isBuscandoCoordenadas
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.check_circle_outline, color: Colors.black),
                label: Text(
                  controller.isBuscandoCoordenadas
                      ? 'Verificando endereço...'
                      : controller.isSaving
                          ? 'Salvando...'
                          : (_editando ? 'Salvar' : 'Criar Destino'),
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: (controller.isSaving ||
                        controller.isBuscandoCoordenadas ||
                        !controller.isValid)
                    ? null
                    : () async {
                        // ── MODO EDIÇÃO: salva direto (sem reverificar endereço) ──
                        if (_editando) {
                          final sucesso = await controller.salvarEdicao();
                          if (!mounted) return;
                          if (sucesso) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('✅ Destino atualizado com sucesso!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.erroMensagem ??
                                    '⚠️ Erro ao atualizar destino.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                          return;
                        }

                        // 1. Verifica o endereço primeiro
                        await controller.buscarCoordenadas();
                        if (!mounted) return;

                        if (!controller.enderecoVerificado) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(controller.erroEndereco ??
                                  '⚠️ Endereço não encontrado. Verifique os dados.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return; // não salva se endereço inválido
                        }

                        // 2. Salva o destino
                        final sucesso = await controller.salvar();
                        if (!mounted) return;
                        if (sucesso) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Destino criado com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(controller.erroMensagem ??
                                  '⚠️ Erro ao salvar destino.'),
                              backgroundColor: Colors.red,
                            ),
                          );
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
        ),
        // ── Botão EXCLUIR — visível apenas no modo edição ──────────────────
        if (_editando) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Excluir destino',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: controller.isSaving
                  ? null
                  : () => _confirmarExclusao(context, controller),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmarExclusao(
      BuildContext context, DestinationCreationController controller) async {
    final confirmar = await ConfirmDeleteDestinationDialog.show(context);
    if (!confirmar || !context.mounted) return;

    final ok = await controller.deleteDestination();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Destino excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Não foi possível excluir o destino.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
      ),
    );
  }
}