import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:boranemobile/controllers/auth_controller.dart';
import 'package:boranemobile/view/pages/profile_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_bora_ne.png', width: 80, height: 80),
              const SizedBox(height: 20),

              Text(
                "Bem-vindo!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 30),

              SocialButton(
                text: 'Entrar com Google',
                color: Colors.white,
                textColor: Colors.black87,
                icon: FontAwesomeIcons.google,
                onPressed: () async {
                  try {
                    final res = await auth.signInWithGoogle();
                    if (res != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro no login: $e')),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              /*SocialButton(
                text: 'Entrar com Facebook',
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                icon: FontAwesomeIcons.facebookF,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}


class SocialButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final dynamic icon;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
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
        onPressed: onPressed,
        icon: leading,
        label: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
        ),
      ),
    );
  }
}