import 'package:flutter/material.dart';
import 'package:boranemobile/utils/app_colors.dart';
import 'package:boranemobile/utils/app_images.dart';
import 'package:boranemobile/utils/app_routes.dart';

/// Tela inicial de splash com a logo do Bora Né
/// Exibe a logo por 3 segundos antes de navegar para login2
class Login1Screen extends StatefulWidget {
  const Login1Screen({super.key});

  @override
  State<Login1Screen> createState() => _Login1ScreenState();
}

class _Login1ScreenState extends State<Login1Screen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin2();
  }

  /// Navega para a próxima tela após 3 segundos
  Future<void> _navigateToLogin2() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          AppImages.logoSemFundo,
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}