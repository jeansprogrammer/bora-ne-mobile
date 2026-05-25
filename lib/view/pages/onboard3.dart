import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard3 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Onboard3({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/image_on3.png',
      dark: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 30, color: Colors.black, height: 1.3),
          children: [
            TextSpan(text: 'A '),
            TextSpan(
              text: 'cultura\n',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEBB22F),
              ),
            ),
            TextSpan(text: 'acontece agora.'),
          ],
        ),
      ),
      subtitle: 'Descubra shows, feiras e festivais que\nsó quem é local conhece.',
      bottomAction: OnboardNavRow(onBack: onBack, onNext: onNext),
    );
  }
}