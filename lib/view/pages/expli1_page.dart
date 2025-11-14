import 'package:flutter/material.dart';

class TelaIntro extends StatelessWidget {
  const TelaIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2B544), // cor amarela
      body: SafeArea(
        child: Stack(
          children: [
            // --------------------------
            // CIRCULO SUPERIOR
            // --------------------------
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),

            // --------------------------
            // CIRCULO INFERIOR
            // --------------------------
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(200),
                ),
              ),
            ),

            // --------------------------
            // CONTEÚDO CENTRAL
            // --------------------------
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --------------------------------------------
                // AQUI VAI A SUA IMAGEM (turista / hotel / etc)
                // --------------------------------------------
                SizedBox(
                  height: 260,
                  child: Image.asset(
                    "assets/turista.png", // <-- COLOQUE SUA IMAGEM AQUI
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Planeje. Explore.\nViva Pernambuco.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // --------------------------
            // BOTÃO DE SETA (próxima página)
            // --------------------------
            Positioned(
              bottom: 30,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  // COLOQUE AQUI A NAVEGAÇÃO PARA A PRÓXIMA PÁGINA
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProximaTela(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_right_alt,
                  size: 45,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProximaTela extends StatelessWidget {
  const ProximaTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Próxima tela!", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}