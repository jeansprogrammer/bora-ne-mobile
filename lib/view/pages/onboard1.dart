import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard1 extends StatelessWidget {
  final VoidCallback onNext;

  const Onboard1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/image_on1.png',
      dark: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 30, color: Colors.black, height: 1.3),
          children: [
            TextSpan(text: 'Planeje.\nExplore. Viva\n'),
            TextSpan(
              text: 'Pernambuco.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEBB22F),
              ),
            ),
          ],
        ),
      ),
      bottomAction: OnboardNavRow(onNext: onNext),
    );
  }
}