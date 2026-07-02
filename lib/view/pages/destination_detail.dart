import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/services/destination_service.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/view/pages/mapa_page.dart';
import 'package:boranemobile/view/pages/new_destination_page.dart';
import 'package:boranemobile/controllers/favorites_controller.dart';
import 'package:boranemobile/services/favorites_service.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/photo_carousel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class DestinationDetail extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const DestinationDetail({super.key, required this.id, required this.data});

  @override
  State<DestinationDetail> createState() => _DestinationDetailState();
}

class _DestinationDetailState extends State<DestinationDetail> {
  bool _isFavorited = false;

  // Estado mutável: permite atualizar a tela após uma edição
  late Map<String, dynamic> _data;
  late String _id;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data);
    _id = widget.id;
    // Ao abrir, busca a versão mais recente do destino no Firestore.
    // Isso garante que, mesmo aberto a partir do "retrato" embutido numa rota,
    // a tela mostre os dados atuais (refletindo edições feitas antes).
    _sincronizarComFirestore();
  }

  // Resolve o id real do destino (usa o id recebido ou busca por nome + cidade)
  Future<String> _resolverId() async {
    if (_id.isNotEmpty) return _id;

    final String nome = (_data['name'] ?? '').toString();
    final String cidade = (_data['city'] ?? '').toString();
    if (nome.isEmpty || cidade.isEmpty) return '';

    try {
      final encontrados = await DestinationService()
          .buscarDestinationsPorNomeECidade(nome, cidade);
      if (encontrados.isNotEmpty) {
        final match = encontrados.firstWhere(
          (d) => d.name.toLowerCase() == nome.toLowerCase(),
          orElse: () => encontrados.first,
        );
        return match.id ?? '';
      }
    } catch (_) {
      // silencioso
    }
    return '';
  }

  // Recarrega o destino canônico do Firestore e atualiza a tela
  Future<void> _sincronizarComFirestore() async {
    final id = await _resolverId();
    if (id.isEmpty) return;

    final atual = await DestinationService().getDestinationById(id);
    if (!mounted) return;
    if (atual != null) {
      setState(() {
        _data = atual.toMap();
        _id = id;
      });
    }
  }

  // ── Abre a tela de edição levando os dados salvos do destino ──────────────
  Future<void> _editarDestino(BuildContext context) async {
    final String idParaEditar = await _resolverId();

    if (!mounted) return;

    if (idParaEditar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Não foi possível identificar este destino para edição.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final alterado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NewDestinationPage(
          destinoParaEditar: _data,
          destinoId: idParaEditar,
        ),
      ),
    );

    // Se foi editado, recarrega o destino do Firestore e atualiza a tela
    if (alterado == true && mounted) {
      await _sincronizarComFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nome = _data['name'] ?? 'Sem título';
    final String descricao =
        _data['description'] ?? 'Sem descrição disponível.';
    final String coverPhoto = _data['coverPhoto'] ?? '';
    final List<String> photos = List<String>.from(_data['photos'] ?? []);
    final List<String> categories = List<String>.from(
      _data['categories'] ?? [],
    );
    final String neighborhood = _data['neighborhood'] ?? '';
    final String city = _data['city'] ?? '';
    final String state = _data['state'] ?? '';

    final String local =
        '${neighborhood.isNotEmpty ? '$neighborhood, ' : ''}$city - $state';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: const CustomBottomNav(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── TOPO FIXO: Logo ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Center(
                    child: Image(
                      image: const AssetImage('assets/images/LOGO_V2_1.png'),
                      height: 32,
                    ),
                  ),
                ),

                // ── CONTEÚDO SCROLLÁVEL ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto (card arredondado com margem)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: PhotoCarousel(
                            coverPhoto: coverPhoto,
                            photos: photos,
                            height: 300,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Card de informações (título + local + categorias)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Linha do título + botão favorito (canto direito)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nome,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => setState(
                                        () => _isFavorited = !_isFavorited),
                                        child: Icon(
                                          _isFavorited
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: _isFavorited
                                              ? Colors.red
                                              : Colors.black87,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    local,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  if (categories.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: categories.map((c) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDEDED),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            c,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                    // ── Descrição ────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Descrição',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // ── BOTÃO EDITAR (preto, ao lado de "Descrição") ──
                              TextButton.icon(
                                onPressed: () => _editarDestino(context),
                                icon: const Icon(Icons.edit_outlined,
                                    color: Colors.black, size: 18),
                                label: const Text(
                                  'Editar',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            descricao,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                        const SizedBox(height: 24),

                        // ── Botão "Ver no mapa" ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1B81A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () async {
                                // 1. Feedback visual de carregamento
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  ),
                                );

                                // 2. Busca a posição do GPS
                                LocationService locationService =
                                    LocationService();
                                var posicao =
                                    await locationService.obterPosicaoAtual();

                                // 3. Fecha o dialog de carregamento
                                if (context.mounted) Navigator.pop(context);

                                LatLng localizacaoFinal;

                                if (posicao != null) {
                                  localizacaoFinal = LatLng(
                                    posicao.latitude,
                                    posicao.longitude,
                                  );
                                } else {
                                  // Backup: coordenada padrão de Garanhuns
                                  localizacaoFinal =
                                      const LatLng(-8.8908, -36.4969);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Não foi possível obter sua localização. Usando localização padrão.',
                                        ),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }

                            DestinationModel destinoModel =
                                DestinationModel.fromMap(
                              _data,
                              id: _id,
                            );

                                // 4. Navega para a Tela do Mapa
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaMapa(
                                        destino: destinoModel,
                                        userLocation: localizacaoFinal,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Ver no mapa',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── BOTÃO VOLTAR (único overlay) ──────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
