import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:boranemobile/controllers/auth_controller.dart';
import 'package:boranemobile/view/pages/home_page.dart';
import 'package:boranemobile/view/pages/user_profile_page.dart';

class LoginPage extends StatefulWidget {
  /// true  → veio do onboarding (mostra botão Convidado + sem botão voltar)
  /// false → aberto dentro do app  (só Google + botão voltar no topo)
  final bool fromOnboarding;

  const LoginPage({super.key, this.fromOnboarding = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final topHeight = screenHeight * 0.62;
    const chevronHeight = 50.0;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [

          // ── Área superior clara com chevron ────────────────────────────
          SizedBox(
            height: topHeight,
            width: double.infinity,
            child: Stack(
              children: [
                // Borda amarela do chevron
                ClipPath(
                  clipper: _ChevronClipper(
                      chevronHeight: chevronHeight, inset: 0),
                  child: Container(
                    color: const Color(0xFFEBB22F),
                    width: double.infinity,
                    height: topHeight,
                  ),
                ),
                // Área branca principal
                ClipPath(
                  clipper: _ChevronClipper(
                      chevronHeight: chevronHeight, inset: 10),
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: topHeight,
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Botão voltar — só quando aberto de dentro do app
                          if (!widget.fromOnboarding)
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black),
                                onPressed: () => Navigator.pop(context),
                              ),
                            )
                          else
                            const SizedBox(height: 16),

                          // Logo
                          Image.asset(
                            'assets/images/LOGO_V2_1.png',
                            height: 40,
                          ),

                          // Ilustração
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  32,
                                  8,
                                  32,
                                  chevronHeight + (widget.fromOnboarding ? 8 : 4)),
                              child: Image.asset(
                                'assets/images/LOGIN.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox(),
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
          ),

          // ── Área inferior escura ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Botão Google
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              try {
                                final res = await auth.signInWithGoogle();
                                if (res != null && mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const UserProfilePage()),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Erro no login: $e')),
                                  );
                                }
                              } finally {
                                if (mounted)
                                  setState(() => _isLoading = false);
                              }
                            },
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black54))
                          : const FaIcon(FontAwesomeIcons.google,
                              size: 18, color: Colors.black87),
                      label: Text(
                        _isLoading ? 'Carregando...' : 'Entrar com Google',
                        style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                    ),
                  ),

                  // Botão Convidado — só no onboarding
                  if (widget.fromOnboarding) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HomePage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Convidado',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Texto descritivo
                  const Text(
                    'Faça login para guardar destinos, criar\nroteiros e viver o Nordeste do seu jeito.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6),
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

// ── Clipper reutilizado do onboard_base ───────────────────────────────────────

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

// SocialButton mantido para compatibilidade com outros usos
class SocialButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final dynamic icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    if (icon is FaIconData) {
      leading = FaIcon(icon, color: textColor, size: 20);
    } else if (icon is IconData) {
      leading = Icon(icon, color: textColor, size: 20);
    } else {
      leading = const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor)))
            : leading,
        label: Text(isLoading ? 'Carregando...' : text,
            style: TextStyle(color: textColor, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          disabledBackgroundColor:
              color.withAlpha((color.alpha * 0.6).toInt()),
        ),
      ),
    );
  }
}