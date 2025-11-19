import 'package:boranemobile/view/widgets/category_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('../assets/logo_bora_ne.png', width: 80, height: 80),
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
                text: "Entrar com Google",
                color: Colors.white,
                textColor: Colors.black87,
                icon: FontAwesomeIcons.google,
                onPressed: () {},
              ),

              const SizedBox(height: 16),

              SocialButton(
                text: "Entrar com Facebook",
                color: const Color(0xFF1877F2),
                textColor: Colors.white,
                icon: FontAwesomeIcons.facebookF,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => CategoryWidget(
                      imagePath: '../assets/logo_google.webp',
                      title: "Due Fratelli",
                      rating: 4.7,
                      category: "Pizzaria",
                      distance: "0.4 km",
                      time: "25-35 min",
                      deliveryPrice: "R\$ 80,99",
                    ),
                  ),
                ),
              ),
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
  final IconData icon;
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: FaIcon(icon, color: textColor, size: 20),
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
