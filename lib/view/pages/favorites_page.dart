import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/login_page.dart';
import 'package:boranemobile/view/pages/profile_page.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/controllers/auth_controller.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.favoritos),
      body: Column(
        children: [
          // Top curved dark bar
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E), // Dark charcoal/black color
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 18,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFC107), // Gold/yellow color
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Image.asset(
                  'assets/images/logo_bora_ne.png',
                  height: 44,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Favoritos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // List of Favorites
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                FavoriteCard(
                  title: 'Seminário São José',
                  rating: 4,
                  favoritesCount: 307,
                  imagePath: 'assets/images/seminario.jpg',
                ),
                FavoriteCard(
                  title: 'Catedral Santo Antônio',
                  rating: 3,
                  favoritesCount: 267,
                  imagePath: 'assets/images/catedral.jpg',
                ),
                FavoriteCard(
                  title: 'Relógio de Flores',
                  rating: 4,
                  favoritesCount: 332,
                  imagePath:
                      'https://s2-g1.glbimg.com/Gc8yY5gNjdY30Dx4tJI5ZPZf8Mg=/0x0:2048x1536/984x0/smart/filters:strip_icc()/s.glbimg.com/jo/g1/f/original/2016/07/14/relogio-de-flores_-_garanhuns_pernambuco_brazil.jpg',
                ),
                FavoriteCard(
                  title: 'Parque Euclides Dourado',
                  rating: 5,
                  favoritesCount: 412,
                  imagePath:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLTuu1bP2pd20wyH8taidVu92LtkqcjM__vA&s',
                ),
                FavoriteCard(
                  title: 'Parque Ruber Van Der Linden',
                  rating: 2,
                  favoritesCount: 201,
                  imagePath:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLWzeJ7tAT3r4Z-LjmkPdwVp6FalFW6Lpo1A&s',
                ),
                FavoriteCard(
                  title: 'Santuário Mãe Rainha',
                  rating: 4,
                  favoritesCount: 314,
                  imagePath: 'assets/images/santuario.jpg',
                ),
              ],
            ),
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
  final String imagePath;

  const FavoriteCard({
    super.key,
    required this.title,
    required this.rating,
    required this.favoritesCount,
    required this.imagePath,
  });

  @override
  State<FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  bool isFavorited = true; // Starts as favorited

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.imagePath.startsWith('http')
                ? Image.network(
                    widget.imagePath,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  )
                : Image.asset(
                    widget.imagePath,
                    width: 90,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Title and Stars (Middle column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < widget.rating ? Icons.star : Icons.star_border,
                      color: index < widget.rating ? Colors.amber : Colors.grey.shade300,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Heart icon and count (Right column)
          SizedBox(
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isFavorited = !isFavorited;
                    });
                  },
                  child: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                ),
                Text(
                  '${widget.favoritesCount} Favoritos',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
