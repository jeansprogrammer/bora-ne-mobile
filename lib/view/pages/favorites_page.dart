import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boranemobile/view/widgets/custom_bottom_nav.dart';
import 'package:boranemobile/controllers/auth_controller.dart';
import 'package:boranemobile/controllers/favorites_controller.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/route_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int _selectedTab = 0; // 0 = Rotas, 1 = Destinos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      final String uid = auth.user?.uid ?? 'usuario_teste';
      Provider.of<FavoritesController>(context, listen: false).fetchFavorites(uid);
    });
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7B119) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF7B119),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFF7B119),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final String currentUid = auth.user?.uid ?? 'usuario_teste';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Very clean off-white background
      bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.favoritos),
      body: Column(
        children: [
          // Top clean bar
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 12,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/LOGO_V2_1.png',
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'Bora NE',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Title & Subtitle
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meus favoritos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aqui estão os roteiros e locais que você salvou para não perder depois.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom Tab Selector (Rotas on left, Destinos on right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    title: 'Rotas',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTabButton(
                    title: 'Destinos',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab View Body (Conditional Render)
          Expanded(
            child: Consumer<FavoritesController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                    ),
                  );
                }

                if (controller.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                return _selectedTab == 0
                    ? _buildRoutesTab(controller, currentUid)
                    : _buildDestinationsTab(controller, currentUid);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationsTab(FavoritesController controller, String currentUid) {
    final destinations = controller.destinosFavoritos;

    if (destinations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border_outlined,
        title: 'Nenhum destino favoritado',
        message: 'Explore locais no app e clique no coração para adicioná-los aqui.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destino = destinations[index];
        return DestinationCard(
          id: destino.id ?? '',
          data: destino.toMap(),
          currentUid: currentUid,
        );
      },
    );
  }

  Widget _buildRoutesTab(FavoritesController controller, String currentUid) {
    final routes = controller.rotasFavoritas;

    if (routes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.alt_route_outlined,
        title: 'Nenhuma rota favoritada',
        message: 'Descubra rotas incríveis pelo Nordeste e salve as suas favoritas.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final rota = routes[index];
        final id = rota.id ?? rota.name;
        return RouteCard(
          id: id,
          data: rota.toMap(),
          currentUid: currentUid,
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
