import 'package:boranemobile/controllers/destination_controller.dart';
import 'package:boranemobile/controllers/destination_creation_controller.dart';
import 'package:boranemobile/controllers/route_creation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
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

            // Botões Rotas e Destinos
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    title: "ROTAS",
                    selected: selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        selectedIndex = 0;
                      });
                    },
                  ),
                ),

                Container(
                  width: 1,
                  height: 60,
                  color: Colors.black26,
                ),

                Expanded(
                  child: _buildTabButton(
                    title: "DESTINOS",
                    selected: selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        selectedIndex = 1;
                      });
                    },
                  ),
                ),
              ],
            ),

            const Divider(
              height: 1,
              color: Colors.black26,
            ),

            // Conteúdo
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
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? const Color(0xFFD89C00)
                  : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFD89C00)
                  : Colors.black,
              fontSize: 20,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

///
/// WIDGET DE ROTAS
/// Substituir pelo widget
///
///

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
    return Consumer<RouteCreationController>(
      builder: (context, controller, child) {
        if (controller.isSearching) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.rotas.isEmpty) {
          return const Center(
            child: Text("Nenhuma rota encontrada"),
          );
        }

        return ListView.builder(
          itemCount: controller.rotas.length,
          itemBuilder: (context, index) {
            final rota = controller.rotas[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: rota['fotoCapa'] != null
                    ? Image.network(
                        rota['fotoCapa'],
                        width: 60,
                        fit: BoxFit.cover,
                      )
                    : null,
                title: Text(
                  rota['name'] ?? 'Sem nome',
                ),
                subtitle: Text(
                  rota['description'] ?? '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}


///
/// WIDGET DE DESTINOS
/// Substituir pelo widget
///
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
    return Consumer<DestinationCreationController>(
      builder: (context, controller, child) {

        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.destinos.isEmpty) {
          return const Center(
            child: Text('Nenhum destino encontrado'),
          );
        }

        return ListView.builder(
          itemCount: controller.destinos.length,
          itemBuilder: (context, index) {

            final destino = controller.destinos[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: destino.coverPhoto.isNotEmpty
                    ? Image.network(
                        destino.coverPhoto,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : null,

                title: Text(destino.name),

                subtitle: Text(
                  '${destino.city} - ${destino.state}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}