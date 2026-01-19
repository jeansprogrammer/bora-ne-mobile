import 'package:flutter/material.dart';
import '../widgets/arrow_button.dart';

class Onboard2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Onboard2({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      body: Stack(
        children: [
          _decorativeCurve(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 28, color: Colors.white),
                      children: [
                        TextSpan(text: "Seu mapa de\n"),
                        TextSpan(
                          text: "descobertas.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEBB22F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      "assets/images/garoto-celular.png",
                      height: 340,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ArrowButton(
                        icon: Icons.arrow_back_ios,
                        onTap: onBack,
                      ),
                      ArrowButton(
                        icon: Icons.arrow_forward_ios,
                        onTap: onNext,
                      ),
                    ],
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
