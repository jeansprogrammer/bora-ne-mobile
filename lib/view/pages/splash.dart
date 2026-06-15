import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boranemobile/services/location_service.dart';
import 'package:boranemobile/services/geoapify_service.dart';
import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _cidadeDetectada;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    // Detecta localização + aguarda mínimo 2s em paralelo
    await Future.wait([
      _detectarLocalizacao(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingConcluido = prefs.getBool('onboarding_concluido') ?? false;

    if (onboardingConcluido) {
      // Já viu o onboarding → home com cidade pré-carregada
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(cidadeInicial: _cidadeDetectada),
        ),
      );
    } else {
      // Primeira vez → onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
  }

  Future<void> _detectarLocalizacao() async {
    try {
      final pos = await LocationService().obterPosicaoAtual();
      if (pos != null) {
        _cidadeDetectada = await GeoapifyService()
            .obterCidadePorCoordenadas(pos.latitude, pos.longitude);
      }
    } catch (e) {
      print('Splash: erro ao detectar localização: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/LOGO_V2_1.png', height: 44),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Color(0xFFEBB22F),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}