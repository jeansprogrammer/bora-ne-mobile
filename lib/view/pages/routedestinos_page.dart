import 'package:flutter/material.dart';

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
/// Substitua pelo seu widget real depois.
///
class RotasWidget extends StatelessWidget {
  const RotasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "WIDGET DE ROTAS",
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}

///
/// WIDGET DE DESTINOS
/// Substitua pelo seu widget real depois.
///
class DestinosWidget extends StatelessWidget {
  const DestinosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "WIDGET DE DESTINOS",
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}