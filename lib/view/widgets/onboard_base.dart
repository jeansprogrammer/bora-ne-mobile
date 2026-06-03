import 'package:flutter/material.dart';
import '../widgets/arrow_button.dart';

class OnboardBase extends StatelessWidget {
  final String imagePath;
  final Widget title;
  final String? subtitle;
  final bool dark;
  final Widget bottomAction;

  const OnboardBase({
    super.key,
    required this.imagePath,
    required this.title,
    required this.bottomAction,
    this.subtitle,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = dark ? const Color(0xFF1C1C1C) : Colors.white;
    final curveColor = const Color(0xFFEBB22F);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Curva decorativa direita (imagem back.png) ────────────────────
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/back.png',
              fit: BoxFit.fitHeight,
              color: dark ? curveColor.withOpacity(0.6) : null,
            ),
          ),

          // ── Conteúdo ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Título
                  title,

                  // Subtítulo opcional
                  if (subtitle != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: dark ? Colors.white70 : Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Imagem centralizada
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Ações (botões de navegação)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: bottomAction,
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

// ── Widget reutilizável de navegação ──────────────────────────────────────────

class OnboardNavRow extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final bool isLast;

  const OnboardNavRow({
    super.key,
    this.onBack,
    required this.onNext,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: onBack != null
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        if (onBack != null)
          ArrowButton(icon: Icons.arrow_back_ios, onTap: onBack!),
        if (isLast)
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEBB22F),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text(
              'Bora!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        else
          ArrowButton(icon: Icons.arrow_forward_ios, onTap: onNext),
      ],
    );
  }
}