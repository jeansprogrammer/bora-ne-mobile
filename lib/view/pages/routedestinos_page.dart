import 'package:boranemobile/controllers/destination_creation_controller.dart';
import 'package:boranemobile/controllers/route_creation_controller.dart';
import 'package:boranemobile/view/widgets/destination_card.dart';
import 'package:boranemobile/view/widgets/route_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color kPrimaryGold = Color(0xFFEDA200);

class RouteDestinosPage extends StatefulWidget {
  const RouteDestinosPage({super.key});

  @override
  State<RouteDestinosPage> createState() => _RouteDestinosPageState();
}

class _RouteDestinosPageState extends State<RouteDestinosPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "BoraNE",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: "Rotas",
                      selected: selectedIndex == 0,
                      onTap: () => setState(() => selectedIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton(
                      title: "Destinos",
                      selected: selectedIndex == 1,
                      onTap: () => setState(() => selectedIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: selectedIndex == 0
                    ? const RotasWidget()
                    : const DestinosWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kPrimaryGold : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: kPrimaryGold, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : kPrimaryGold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class RotasWidget extends StatefulWidget {
  const RotasWidget({super.key});

  @override
  State<RotasWidget> createState() => _RotasWidgetState();
}

class _RotasWidgetState extends State<RotasWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RouteCreationController>().carregarRotas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'usuario_teste';

    return Consumer<RouteCreationController>(
      builder: (context, controller, child) {
        if (controller.isSearching) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryGold),
          );
        }

        if (controller.rotas.isEmpty) {
          return const Center(child: Text("Nenhuma rota encontrada"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.rotas.length,
          itemBuilder: (context, index) {
            final rota = controller.rotas[index];

            return RouteCard(
              
              id: rota['id'] ?? '',
              data: rota,
              currentUid: uid,
              onTap: () {
                
              },
            );
          },
        );
      },
    );
  }
}

class DestinosWidget extends StatefulWidget {
  const DestinosWidget({super.key});

  @override
  State<DestinosWidget> createState() => _DestinosWidgetState();
}

class _DestinosWidgetState extends State<DestinosWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DestinationCreationController>().carregarDestinos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'usuario_teste';

    return Consumer<DestinationCreationController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryGold),
          );
        }

        if (controller.destinos.isEmpty) {
          return const Center(child: Text('Nenhum destino encontrado'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.destinos.length,
          itemBuilder: (context, index) {
            final destino = controller.destinos[index];

            return DestinationCard(
              
              id: destino.id ?? '',
              data: destino.toMap(),
              currentUid: uid,
              onTap: () {
                
              },
            );
          },
        );
      },
    );
  }
}