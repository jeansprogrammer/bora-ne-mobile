import 'package:flutter/material.dart';
import 'onboard1.dart';
import 'onboard2.dart';
import 'onboard3.dart';
import 'onboard4.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void nextPage() {
    if (_currentPage < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        children: [
          Onboard1(onNext: nextPage),
          Onboard2(onNext: nextPage, onBack: previousPage),
          Onboard3(onNext: nextPage, onBack: previousPage),
          const Onboard4(),
        ],
      ),
    );
  }
}
