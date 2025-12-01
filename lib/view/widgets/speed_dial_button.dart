import 'package:boranemobile/view/pages/new_place_page.dart';
import 'package:boranemobile/view/pages/new_route_page.dart';
import 'package:flutter/material.dart';

class SpeedDialButton extends StatefulWidget {
  const SpeedDialButton({super.key});

  @override
  State<SpeedDialButton> createState() => _SpeedDialButtonState();
}

class _SpeedDialButtonState extends State<SpeedDialButton>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
      isOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        /// ---- Botão: Nova Rota ----
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 130, right: 10),
            child: _SpeedDialOption(
              icon: Icons.alt_route,
              label: "Nova rota",
              onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewRoutePage()),
                          );
                        },
            ),
          ),

        /// ---- Botão: Adicionar Local ----
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 70, right: 10),
            child: _SpeedDialOption(
              icon: Icons.place,
              label: "Adicionar local",
              onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NewPlacePage()),
                          );
                        },
            ),
          ),

        /// ---- Botão Principal ----
        FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: toggleMenu,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------
/// WIDGET INTERNO PARA ITENS DO MENU
/// ---------------------------------------------------------------

class _SpeedDialOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SpeedDialOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.orange, size: 26),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
