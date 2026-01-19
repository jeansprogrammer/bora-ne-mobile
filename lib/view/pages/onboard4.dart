import 'package:flutter/material.dart';
import 'home_page.dart';

class Onboard4 extends StatelessWidget {
  const Onboard4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _decorativeCurve(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tudo pronto!\nComece agora sua\njornada com o BoraNE.",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEBB22F),
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// 🔥 NOVA IMAGEM
                  Center(
                    child: Image.asset(
                      "assets/images/Diving-rafiki 1.png",
                      height: 320,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBB22F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Começar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _decorativeCurve() {
  return Positioned(
    right: -80,
    top: -40,
    bottom: -40,
    child: Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        border: Border.all(
          color: const Color(0xFFEBB22F),
          width: 2,
        ),
      ),
    ),
  );
}
