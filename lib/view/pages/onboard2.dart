import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Onboard2({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/PLANEJE.png',
      title: 'Planeje',
      subtitle: 'Crie roteiros personalizados\ne organize sua viagem\ndo seu jeito.',
      showBack: true,
      onNext: onNext,
      onBack: onBack,
    );
  }
}