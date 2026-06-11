import 'package:flutter/material.dart';
import 'package:boranemobile/view/pages/home_page.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      final String uid = auth.user?.uid ?? 'usuario_teste';
      Provider.of<FavoritesController>(context, listen: false).fetchFavorites(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final String currentUid = auth.user?.uid ?? 'usuario_teste';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light gray background
        bottomNavigationBar: const CustomBottomNav(activeTab: BottomNavTab.favoritos),
        body: Column(
          children: [
            // Top curved dark bar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
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
                        color: Colors.orangeAccent,
                        size: 28,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                            settings: const RouteSettings(name: '/home'),
                          ),
                        );
                      },
                    ),
                  ),
                  Image.asset(
                    'assets/images/LOGO_V2_1.png', // matches HomePage logo
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'Bora NE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Colors.orangeAccent,
                    width: 3,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 40),
                ),
                labelColor: Colors.orangeAccent,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
                tabs: [
                  Tab(text: 'Destinos'),
                  Tab(text: 'Rotas'),
                ],
              ),
            ),

            // Tab View Body
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

                  return TabBarView(
                    children: [
                      // TAB 1: Destinos
                      _buildDestinationsTab(controller, currentUid),

                      // TAB 2: Rotas
                      _buildRoutesTab(controller, currentUid),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
