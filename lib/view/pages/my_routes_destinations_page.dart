import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:boranemobile/services/new_route_service.dart';
import 'package:boranemobile/services/destination_service.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/route_card.dart';

/// Lista as rotas e destinos criados pelo próprio usuário logado.
class MyRoutesDestinationsPage extends StatefulWidget {
  final int initialTab;

  const MyRoutesDestinationsPage({super.key, this.initialTab = 0});

  @override
  State<MyRoutesDestinationsPage> createState() =>
      _MyRoutesDestinationsPageState();
}

class _MyRoutesDestinationsPageState extends State<MyRoutesDestinationsPage> {
  late int _selectedTab = widget.initialTab;
  bool _isLoading = true;
  List<Map<String, dynamic>> _minhasRotas = [];
  List<Map<String, dynamic>> _meusDestinos = [];

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (_uid.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    final rotas = await NewRouteService().getRoutesByCreator(_uid);
    final destinos = await DestinationService().getDestinationsByCreator(_uid);

    if (!mounted) return;
    setState(() {
      _minhasRotas = rotas;
      _meusDestinos = destinos.map((d) => d.toMap()).toList();
      _isLoading = false;
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
          border: Border.all(color: const Color(0xFFF7B119), width: 2),
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildRotasTab() {
    if (_minhasRotas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.alt_route_outlined,
        title: 'Nenhuma rota criada',
        message: 'As rotas que você criar aparecerão aqui.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _minhasRotas.length,
      itemBuilder: (context, index) {
        final rota = _minhasRotas[index];
        return RouteCard(
          id: rota['id'] ?? '',
          data: rota,
          currentUid: _uid,
        );
      },
    );
  }

  Widget _buildDestinosTab() {
    if (_meusDestinos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.place_outlined,
        title: 'Nenhum destino criado',
        message: 'Os destinos que você criar aparecerão aqui.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _meusDestinos.length,
      itemBuilder: (context, index) {
        final destino = _meusDestinos[index];
        return DestinationCard(
          id: destino['id'] ?? '',
          data: destino,
          currentUid: _uid,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Minhas rotas e destinos',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent))
          : RefreshIndicator(
              onRefresh: _carregar,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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
                  Expanded(
                    child: _selectedTab == 0
                        ? _buildRotasTab()
                        : _buildDestinosTab(),
                  ),
                ],
              ),
            ),
    );
  }
}
