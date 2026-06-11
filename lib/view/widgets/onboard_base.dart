import 'package:flutter/material.dart';

class OnboardBase extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool showBack;
  final bool isLast;

  const OnboardBase({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onNext,
    this.onBack,
    this.showBack = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.55;
    const chevronHeight = 50.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // ── Área superior com ClipPath em chevron ──
          SizedBox(
            height: topHeight,
            width: double.infinity,
            child: Stack(
              children: [
                // Camada amarela (borda do chevron)
                ClipPath(
                  clipper: _ChevronClipper(
                    chevronHeight: chevronHeight,
                    inset: 0,
                  ),
                  child: Container(
                    color: const Color(0xEFEFEFEF),
                    width: double.infinity,
                    height: topHeight,
                  ),
                ),
                // Camada clara (área principal + miolo do chevron)
                ClipPath(
                  clipper: _ChevronClipper(
                    chevronHeight: chevronHeight,
                    inset: 10,
                  ),
                  child: Container(
                    color: const Color(0xFFF2F2F2),
                    width: double.infinity,
                    height: topHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 48,
                        left: 24,
                        right: 24,
                        bottom: chevronHeight + 10,
                      ),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Área inferior escura ──
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFF2F2F2),
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  showBack
                      ? Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: onBack,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEBB22F),
                                    side: const BorderSide(
                                      color: Color(0xFFEBB22F),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Voltar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: onNext,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEBB22F),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isLast ? 'Começar' : 'Avançar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEBB22F),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Avançar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChevronClipper extends CustomClipper<Path> {
  final double chevronHeight;
  final double inset;

  const _ChevronClipper({required this.chevronHeight, required this.inset});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - chevronHeight)
      ..lineTo(w / 2, h - inset)
      ..lineTo(0, h - chevronHeight)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ChevronClipper old) =>
      old.chevronHeight != chevronHeight || old.inset != inset;
}
