import 'package:flutter/material.dart';
import 'home_page.dart';
import '../widgets/onboard_base.dart';

class Onboard4 extends StatelessWidget {
  final VoidCallback onBack;

  const Onboard4({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/image_on4.png',
      dark: false,
      title: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 30, color: Colors.black, height: 1.3),
          children: [
            TextSpan(
              text: 'Conecte-se ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEBB22F),
              ),
            ),
            TextSpan(text: 'e\nfortaleça o local.'),
          ],
        ),
      ),
      subtitle: 'Valorize pequenos empreendedores e\nviva experiências autênticas.',
      bottomAction: OnboardNavRow(
        onBack: onBack,
        isLast: true,
        onNext: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      ),
    );
  }
}
