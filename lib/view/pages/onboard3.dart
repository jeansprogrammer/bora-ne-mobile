import 'package:flutter/material.dart';
import 'login_page.dart';

class Onboard3 extends StatelessWidget {
  const Onboard3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mais que viagem\né vivência.",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEBB22F),
                  ),
                ),
              ),
          
              const SizedBox(height: 40),
          
          
              Image.asset("assets/images/casal-viagem.png", height: 400),
          
              const Spacer(),
          
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEBB22F),
                  ),
                  child: const Icon(Icons.check, size: 32),
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