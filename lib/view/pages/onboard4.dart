import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';
import 'login_page.dart';

class Onboard4 extends StatelessWidget {
  final VoidCallback onBack;

  const Onboard4({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/FORTALECA.png',
        title: 'Fortaleça',
      subtitle: 'Acompanhe eventos, festivais,\nsabores e cultura local\nem tempo real.',
      showBack: true,
      isLast: true,
      onBack: onBack,
      onNext: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
    );
  }
}