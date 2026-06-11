import 'package:flutter/material.dart';
import '../widgets/onboard_base.dart';

class Onboard1 extends StatelessWidget {
  final VoidCallback onNext;

  const Onboard1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardBase(
      imagePath: 'assets/images/DESCUBRA.png',
      title: 'Descubra',
      subtitle: 'Encontre lugares incríveis\ne experiências autênticas\npelo Nordeste.',
      showBack: false,
      onNext: onNext,
    );
  }
}