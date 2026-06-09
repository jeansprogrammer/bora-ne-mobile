import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DestinationCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final String currentUid;
  final VoidCallback? onTap;

  const DestinationCard({
    super.key,
    required this.id,
    required this.data,
    this.currentUid = 'usuario_teste',
    this.onTap,
  });

  Future<void> _toggleFavorito(List<String> favoritedBy) async {
    final ref = FirebaseFirestore.instance.collection('destinations').doc(id);
    final lista = List<String>.from(favoritedBy);
    if (lista.contains(currentUid)) {
      lista.remove(currentUid);
    } else {
      lista.add(currentUid);
    }
    await ref.update({'favoritedBy': lista});
  }

  @override
  Widget build(BuildContext context) {
    final nome        = data['name']         ?? 'Sem título';
    final descricao   = data['description']  ?? '';
    final coverPhoto  = data['coverPhoto']   ?? '';
    final categories  = List<String>.from(data['categories'] ?? []);
    final neighborhood = data['neighborhood'] ?? '';
    final city        = data['city']         ?? '';
    final state       = data['state']        ?? '';
    final local =
        '${neighborhood.isNotEmpty ? '$neighborhood, ' : ''}$city – $state';

    final favoritedBy = List<String>.from(data['favoritedBy'] ?? []);
    final isFavorito  = favoritedBy.contains(currentUid);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // ── Imagem ──────────────────────────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: coverPhoto.isNotEmpty
                      ? Image.network(
                          coverPhoto,
                          width: 100,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),

                // ── Info ──────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 36, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (categories.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            categories.join(', '),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          descricao,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: Colors.grey),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                local,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Coração no topo direito ──────────────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleFavorito(favoritedBy),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorito ? Icons.favorite : Icons.favorite_border,
                    color: isFavorito ? Colors.red : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 100,
      height: 110,
      color: const Color(0xFFFFF9E7),
      child: const Icon(Icons.image_outlined,
          color: Colors.orangeAccent, size: 32),
    );
  }
}