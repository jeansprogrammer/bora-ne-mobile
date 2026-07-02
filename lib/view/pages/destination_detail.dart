import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/view/widgets/photo_carousel.dart';
import 'package:flutter/material.dart';
import 'package:boranemobile/view/widgets/comments_bottom_sheet.dart';

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

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.comment_outlined),
                            label: const Text(
                              'Comentários',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              print("BOTÃO COMENTÁRIOS PRESSIONADO");
                              print("ID DO DESTINO: ${widget.id}");

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => CommentsBottomSheet(
                                  destinationId: widget.id,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

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
                            onPressed: () {},
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
