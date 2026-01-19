import 'package:flutter/material.dart';

class OnboardBase extends StatelessWidget {
  final Widget image;
  final RichText title;
  final Widget bottomAction;
  final bool dark;

  const OnboardBase({
    super.key,
    required this.image,
    required this.title,
    required this.bottomAction,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF1C1C1C) : Colors.white,
      body: Stack(
        children: [
          Positioned(
            right: -80,
            top: -40,
            bottom: -40,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                border: Border.all(
                  color: const Color(0xFFEBB22F),
                  width: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  title,
                  const SizedBox(height: 40),
                  Center(child: image),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: bottomAction,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
