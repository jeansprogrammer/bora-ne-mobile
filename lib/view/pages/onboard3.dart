import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard3 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Onboard3({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/VIVA.png',
      title: 'Viva',
      subtitle: 'Acompanhe eventos, festivais,\nsabores e cultura local\nem tempo real.',
      showBack: true,
      onNext: onNext,
      onBack: onBack,
    );
  }
}