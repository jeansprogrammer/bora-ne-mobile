import 'package:flutter/material.dart';

class Onboard1 extends StatelessWidget {
  final VoidCallback onNext;

  const Onboard1({super.key, required this.onNext});

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
                  "Seja bem-vindo ao\nBoraNE.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEBB22F),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                "assets/images/menina-dancado.png",
                height: 400,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onNext,
                  child: _arrowButton(Icons.arrow_right_alt_rounded),
                ),
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
