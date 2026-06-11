import 'package:readmore/readmore.dart';
import 'package:boranemobile/view/pages/destination_detail.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/photo_carousel.dart';
import 'package:flutter/material.dart';

class RouteDetailPage extends StatefulWidget {
  final Map<String, dynamic>? rota; // Permitindo nulo para evitar que o app quebre

  const RouteDetailPage({super.key, this.rota});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  int _currentIndex = 0; 

  @override
  Widget build(BuildContext context) {
    // ── 1. VERIFICAÇÃO DE SEGURANÇA: Se a rota for nula ─────────────────
    if (widget.rota == null) {
      return const Scaffold(
        body: Center(child: Text('Erro: O mapa da rota veio nulo!')),
      );
    }

    // Extraindo as informações básicas da Rota Principal
    final String nomeRota = widget.rota!['name'] ?? 'Sem título';
    final String coverPhotoRota = widget.rota!['coverPhoto'] ?? '';
    // Suporte a dados antigos onde photos era String
    final rawPhotos = widget.rota!['photos'];
    final List<String> photosRota = rawPhotos == null
        ? []
        : rawPhotos is List
            ? List<String>.from(rawPhotos)
            : (rawPhotos as String).isNotEmpty
                ? [rawPhotos as String]
                : [];
    final String descricaoRota = widget.rota!['description'] ?? 'Sem descrição disponível.';
    final List<dynamic> destinosRaw = widget.rota!['destinations'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fundo levemente cinza do mockup
      body: SafeArea(
        child: Column(
          children: [
            // ── TOPO FIXO: Botão Voltar e Logo ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Image(
                      image:   AssetImage('assets/images/LOGO_V2_1.png'), 
                      height: 32),
                    ),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
            ),

            // ── CONTEÚDO SCROLLÁVEL ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título Principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        nomeRota,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Card Principal (Imagem + Descrição)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            PhotoCarousel(
                              coverPhoto: coverPhotoRota,
                              photos: photosRota,
                              height: 200,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            
                            // ── ALTERAÇÃO FEITA AQUI ─────────────────────────
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ReadMoreText(
                                descricaoRota,
                                trimLines: 3, // Mostra 3 linhas e depois corta
                                trimMode: TrimMode.Line,
                                trimCollapsedText: ' ver mais',
                                trimExpandedText: ' ver menos',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                moreStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF1B81A), // Usando o amarelo da sua identidade visual
                                ),
                                lessStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF1B81A),
                                ),
                              ),
                            ),
                            // ────────────────────────────────────────────────
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Título do Itinerário
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Roteiro da experiência',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── LISTA DO ITINERÁRIO (TIMELINE) ───────────────────────
                    if (destinosRaw.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                        child: Text(
                          'Nenhum ponto turístico encontrado no banco de dados para esta rota.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: destinosRaw.length,
                        itemBuilder: (context, index) {
                          final item = destinosRaw[index] as Map<String, dynamic>;

                          final String nomeDestino = item['name'] ?? 'Destino sem nome';
                          final String cidadeDestino = item['city'] ?? 'Garanhuns - PE';
                          final String descricaoDestino = item['description'] ?? 'Sem descrição.';

                          final List<dynamic> fotosDestino = item['photos'] ?? [];
                          final String imagemDestino = item['coverPhoto'] ??
                              (fotosDestino.isNotEmpty ? fotosDestino.first : '');

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Linha do tempo
                                  _buildTimeline(index, destinosRaw.length),
                                  
                                  const SizedBox(width: 16),

                                  // Card Lateral
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DestinationDetail(
                                            id: item['id'] ?? '',
                                            data: item,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        height: 110, // Forçando tamanho fixo para evitar que suma
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: const Color(0xFFEFEFEF)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.02),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Row(
                                          children: [
                                            if (imagemDestino.isNotEmpty)
                                              Image.network(
                                                imagemDestino,
                                                width: 110,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => Container(width: 110, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                                              ),
                                            
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      nomeDestino,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      descricaoDestino,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      cidadeDestino,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey.shade400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── BARRA DE MENU INFERIOR ─────────────────────────────────────────────
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildTimeline(int index, int totalItems) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFF1B81A), 
            shape: BoxShape.circle,
          ),
        ),
        if (index != totalItems - 1)
          Expanded(
            child: CustomPaint(
              size: const Size(2, double.infinity),
              painter: DashedLinePainter(),
            ),
          ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = const Color(0xFFF1B81A).withOpacity(0.6)
      ..strokeWidth = 2;
    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY), Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}