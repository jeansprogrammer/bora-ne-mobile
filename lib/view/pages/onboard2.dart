import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Onboard2({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/image_on2.png',
      dark: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 30, color: Colors.black, height: 1.3),
          children: [
            TextSpan(text: 'Seu mapa de\n'),
            TextSpan(
              text: 'descobertas.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEBB22F),
              ),
            ),
          ],
        ),
      ),
      bottomAction: OnboardNavRow(onBack: onBack, onNext: onNext),
    );
  }
}