import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      onNext: () async {
        // Marca que o onboarding foi concluído para nunca mais aparecer
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_concluido', true);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const LoginPage(fromOnboarding: true)),
          );
        }
      },
    );
  }
}