import 'package:boranemobile/view/pages/onboard3.dart';
import 'package:flutter/material.dart';
import 'onboard2.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: const [
        Onboard1(),
        Onboard2(),
        Onboard3(),
      ],
    );
  }
}

class Onboard1 extends StatelessWidget {
  const Onboard1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Planeje.\nExplore. Viva\nPernambuco.",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEBB22F),
                ),
              ),
            ),

            const SizedBox(height: 40),


            Image.asset("../assets/images/menina-dancado.png", height: 400),

            const Spacer(),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Onboard2()),
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