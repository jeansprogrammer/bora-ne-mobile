import 'package:boranemobile/models/destination_model.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/view/pages/mapa_page.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/photo_carousel.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class DestinationDetail extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const DestinationDetail({super.key, required this.id, required this.data});

  

  @override
  State<DestinationDetail> createState() => _DestinationDetailState();
}

class _DestinationDetailState extends State<DestinationDetail> {
  bool _isFavorited = false;


  @override
  Widget build(BuildContext context) {
    final String nome = widget.data['name'] ?? 'Sem título';
    final String descricao =
        widget.data['description'] ?? 'Sem descrição disponível.';
    final String coverPhoto = widget.data['coverPhoto'] ?? '';
    final List<String> photos = List<String>.from(widget.data['photos'] ?? []);
    final List<String> categories = List<String>.from(
      widget.data['categories'] ?? [],
    );
    final String neighborhood = widget.data['neighborhood'] ?? '';
    final String city = widget.data['city'] ?? '';
    final String state = widget.data['state'] ?? '';

    final String local =
        '${neighborhood.isNotEmpty ? '$neighborhood, ' : ''}$city - $state';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: const CustomBottomNav(),
      body: Stack(
        children: [
          // ── SCROLL PRINCIPAL ──────────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // Foto — dentro do scroll, nada sobreposto
                PhotoCarousel(
                  coverPhoto: coverPhoto,
                  photos: photos,
                  height: 340,
                ),

                // Card branco com conteúdo
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                nome,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorited
                                    ? Colors.red
                                    : Colors.black87,
                                size: 30,
                              ),
                              onPressed: () =>
                                  setState(() => _isFavorited = !_isFavorited),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                local,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (categories.isNotEmpty)
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
                                  color: const Color(0xFFF1F3F5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 24),

                        const Text(
                          'Descrição',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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

                        const SizedBox(height: 24),

                        // ── Botão Ver no mapa dentro do scroll ─────────────
                        SizedBox(
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
                              // 1. Mostra um feedback visual de carregamento (Opcional, mas altamente recomendado)
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue, // ou a cor do seu app
                                  ),
                                ),
                              );

                              // 2. Instancia o seu serviço e busca a posição do GPS
                              LocationService locationService =
                                  LocationService();
                              var posicao = await locationService
                                  .obterPosicaoAtual();

                              // 3. Fecha o dialog de carregamento
                              if (context.mounted) Navigator.pop(context);

                              LatLng localizacaoFinal;

                              if (posicao != null) {
                                // Se o GPS funcionou, converte Position (do Geolocator) para LatLng (do latlong2)
                                localizacaoFinal = LatLng(
                                  posicao.latitude,
                                  posicao.longitude,
                                );
                              } else {
                                // CASO DE BACKUP: Se o usuário negar a permissão ou o GPS falhar,
                                // usamos a coordenada padrão de Garanhuns para o app não quebrar.
                                localizacaoFinal = const LatLng(
                                  -8.8908,
                                  -36.4969,
                                );

                                // Alerta amigável avisando que usou o local padrão
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

                              DestinationModel destinoModel = DestinationModel.fromMap(
                                widget.data, 
                                id: widget.id,
                              );

                              // 4. Navega para a Tela do Mapa com os dados dinâmicos
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TelaMapa(
                                      destino:
                                          destinoModel, // Seu objeto vindo do Firebase
                                      userLocation:
                                          localizacaoFinal, // Localização real capturada!
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

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFFFF9E7),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFFF1B81A), size: 48),
      ),
    );
  }
}
