import 'package:flutter/material.dart';
import 'package:boranemobile/utils/app_colors.dart';
import 'package:boranemobile/utils/app_images.dart';

/// Tela de Login com opções de Google, Facebook e Convidado
class Login2Screen extends StatelessWidget {
  const Login2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Onda decorativa superior direita
          Positioned(
            top: -50,
            right: -50,
            child: CustomPaint(
              size: const Size(200, 300),
              painter: TopWavePainter(),
            ),
          ),
          
          // Onda decorativa inferior esquerda
          Positioned(
            bottom: -50,
            left: -50,
            child: CustomPaint(
              size: const Size(200, 300),
              painter: BottomWavePainter(),
            ),
          ),

          // Conteúdo principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      AppImages.logoSemFundo,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 60),

                    // Botão Google
                    _SocialLoginButton(
                      icon: AppImages.logoGoogle,
                      text: 'Entrar com Google',
                      backgroundColor: Colors.white,
                      textColor: const Color(0xFF1F1F1F),
                      onPressed: () {
                        // TODO: Implementar login com Google
                        print('Login com Google');
                      },
                    ),

                    const SizedBox(height: 16),

                    // Botão Facebook
                    _SocialLoginButton(
                      icon: AppImages.logoFacebook,
                      text: 'Entrar com Facebook',
                      backgroundColor: const Color(0xFF1877F2),
                      textColor: Colors.white,
                      onPressed: () {
                        // TODO: Implementar login com Facebook
                        print('Login com Facebook');
                      },
                    ),

                    const SizedBox(height: 24),

                    // Link "Entrar como convidado"
                    TextButton(
                      onPressed: () {
                        // TODO: Navegar para home como convidado
                        print('Entrar como convidado');
                      },
                      child: const Text(
                        'Entrar como convidado',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão customizado para login social
class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          children: [
            // Ícone
            Image.asset(
              icon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            
            // Espaçamento
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Espaço vazio para balancear o ícone
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

/// Painter para a onda decorativa superior
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // Curva ondulada
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.5, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4,
      size.width, size.height * 0.3,
    );

    canvas.drawPath(path, paint);

    // Segunda curva (paralela)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.5);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.4,
      size.width * 0.5, size.height * 0.5,
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.6,
      size.width, size.height * 0.5,
    );

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter para a onda decorativa inferior
class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    
    // Curva ondulada
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.6,
      size.width * 0.5, size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.4,
      size.width, size.height * 0.5,
    );

    canvas.drawPath(path, paint);

    // Segunda curva (paralela)
    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.8,
      size.width * 0.5, size.height * 0.7,
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.6,
      size.width, size.height * 0.7,
    );

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}