import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SafeArea(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Descubra rotas e\nexperiências de forma\nrápida e dinâmica.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEBB22F),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                "assets/images/garoto-celular.png",
                height: 400,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: _arrowButton(Icons.arrow_back),
                  ),
                  GestureDetector(
                    onTap: onNext,
                    child: _arrowButton(Icons.arrow_right_alt_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _arrowButton(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFEBB22F),
    ),
    child: Icon(icon, size: 32),
  );
}
