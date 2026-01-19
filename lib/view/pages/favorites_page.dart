import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FavoriteCard(
            title: 'Relógio de Flores',
            rating: 4,
            favoritesCount: 307,
          ),
          FavoriteCard(
            title: 'Fazenda Lago São Francisco',
            rating: 5,
            favoritesCount: 307,
          ),
          FavoriteCard(
            title: 'Santuário Mãe Rainha',
            rating: 5,
            favoritesCount: 307,
          ),
          FavoriteCard(
            title: 'Mosteiro de São Bento',
            rating: 4,
            favoritesCount: 307,
          ),
          FavoriteCard(
            title: 'Mirante Cristo do Magano',
            rating: 4,
            favoritesCount: 307,
          ),
        ],
      ),
    );
  }
}

class FavoriteCard extends StatefulWidget {
  final String title;
  final int rating;
  final int favoritesCount;

  const FavoriteCard({
    super.key,
    required this.title,
    required this.rating,
    required this.favoritesCount,
  });

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  bool isFavorited = true; // começa favoritado

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGEM (placeholder)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1.2,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < widget.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${widget.favoritesCount} Favoritos',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // botão coração 
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isFavorited = !isFavorited;
              });
            },
          ),
        ],
      ),
    );
  }
}
