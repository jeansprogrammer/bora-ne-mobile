import 'package:flutter/material.dart';
import '../widgets/arrow_button.dart';

class Onboard1 extends StatelessWidget {
  final VoidCallback onNext;

  const Onboard1({super.key, required this.onNext});

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
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 28, color: Colors.black),
                      children: [
                        TextSpan(text: "Planeje.\nExplore. Viva\n"),
                        TextSpan(
                          text: "Pernambuco.",
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
                      "assets/images/menina-dancado.png",
                      height: 340,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ArrowButton(
                      icon: Icons.arrow_forward_ios,
                      onTap: onNext,
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
