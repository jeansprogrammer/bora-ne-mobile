import 'package:flutter/material.dart';
import 'onboard3.dart';

class Onboard2 extends StatelessWidget {
  const Onboard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Seu mapa de\ndescobertas.",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEBB22F),
                ),
              ),
            ),

            const SizedBox(height: 40),


            Image.asset("../assets/images/garoto-celular.png", height: 400),

            const Spacer(),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Onboard3()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEBB22F),
                ),
                child: const Icon(Icons.arrow_right_alt_rounded, size: 32),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}